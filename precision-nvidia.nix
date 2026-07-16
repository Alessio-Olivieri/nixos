{ config, pkgs, lib, inputs, ... }:

let
  cpuTurboRatioLimit = "0x2A2A2A2A2C2C2E2E";
  stellarisCpuAffinity = "0,2,4,6,8,10,12,14";
  batteryHealthChargingCtl = pkgs.writeShellScriptBin "batteryhealthchargingctl" (builtins.readFile "${pkgs.gnomeExtensions.battery-health-charging}/share/gnome-shell/extensions/Battery-Health-Charging@maniacx.github.com/resources/batteryhealthchargingctl");
  stellarisSteamGpu = pkgs.writeShellApplication {
    name = "stellaris-steam-gpu";
    runtimeInputs = with pkgs; [ coreutils glib gnugrep gnused procps util-linux ];
    text = ''
      app_uri="steam://rungameid/281990"
      steam_bin="''${STEAM_BIN:-/run/current-system/sw/bin/steam}"
      profile="''${1:-}"
      stellaris_cpu_affinity="${stellarisCpuAffinity}"

      notify_user() {
        local title="$1"
        local body="$2"

        gdbus call \
          --session \
          --dest org.freedesktop.Notifications \
          --object-path /org/freedesktop/Notifications \
          --method org.freedesktop.Notifications.Notify \
          "Stellaris GPU Launcher" \
          0 \
          "" \
          "$title" \
          "$body" \
          "[]" \
          "{}" \
          8000 >/dev/null 2>&1 || true
      }

      steam_pid() {
        pgrep -u "$(id -u)" -n -x steam 2>/dev/null || true
      }

      steam_profile() {
        local pid="$1"
        local env_text

        if [[ ! -r "/proc/$pid/environ" ]]; then
          echo "unknown"
          return
        fi

        env_text="$(tr '\0' '\n' < "/proc/$pid/environ" 2>/dev/null || true)"

        if printf '%s\n' "$env_text" | grep -q '^MESA_VK_DEVICE_SELECT=8086:9a60$' \
          && printf '%s\n' "$env_text" | grep -q '^VK_.*intel_icd'; then
          echo "integrated"
          return
        fi

        if printf '%s\n' "$env_text" | grep -q '^__NV_PRIME_RENDER_OFFLOAD=1$' \
          || printf '%s\n' "$env_text" | grep -q '^__VK_LAYER_NV_optimus=NVIDIA_only$' \
          || printf '%s\n' "$env_text" | grep -q '^VK_.*nvidia_icd'; then
          echo "dedicated"
          return
        fi

        echo "unknown"
      }

      apply_stellaris_affinity() {
        local deadline pid

        deadline=$((SECONDS + 240))
        while (( SECONDS < deadline )); do
          pid="$(pgrep -u "$(id -u)" -n -x stellaris 2>/dev/null || true)"
          if [[ -n "$pid" ]]; then
            for _ in 1 2 3 4 5; do
              taskset -apc "$stellaris_cpu_affinity" "$pid" >/dev/null 2>&1 || true
              sleep 1
            done
            return 0
          fi
          sleep 1
        done
      }

      tune_stellaris_settings() {
        local settings="''${XDG_DATA_HOME:-$HOME/.local/share}/Paradox Interactive/Stellaris/settings.txt"

        [[ -f "$settings" ]] || return 0

        sed -i \
          -e 's/^\([[:space:]]*refreshCap=\).*/\10/' \
          -e 's/^\([[:space:]]*vsync=\).*/\1no/' \
          -e 's/^\([[:space:]]*fullScreen=\).*/\1yes/' \
          -e 's/^\([[:space:]]*borderless=\).*/\1no/' \
          "$settings" 2>/dev/null || true
      }

      launch_and_tune() {
        tune_stellaris_settings
        "$@" &
        local launcher_pid="$!"

        apply_stellaris_affinity
        disown "$launcher_pid" 2>/dev/null || true
      }

      launch_integrated() {
        launch_and_tune env \
          DRI_PRIME=0 \
          vblank_mode=0 \
          MESA_VK_DEVICE_SELECT=8086:9a60 \
          __NV_PRIME_RENDER_OFFLOAD=0 \
          __GLX_VENDOR_LIBRARY_NAME=mesa \
          __VK_LAYER_NV_optimus=non_NVIDIA_only \
          VK_DRIVER_FILES=/run/opengl-driver/share/vulkan/icd.d/intel_icd.x86_64.json:/run/opengl-driver-32/share/vulkan/icd.d/intel_icd.i686.json \
          VK_ICD_FILENAMES=/run/opengl-driver/share/vulkan/icd.d/intel_icd.x86_64.json:/run/opengl-driver-32/share/vulkan/icd.d/intel_icd.i686.json \
          "$steam_bin" "$app_uri"
      }

      launch_dedicated() {
        if [[ -x /run/current-system/sw/bin/nvidia-offload ]]; then
          launch_and_tune env \
            __GL_SYNC_TO_VBLANK=0 \
            vblank_mode=0 \
            __VK_LAYER_NV_optimus=NVIDIA_only \
            VK_DRIVER_FILES=/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.json:/run/opengl-driver-32/share/vulkan/icd.d/nvidia_icd.json \
            VK_ICD_FILENAMES=/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.json:/run/opengl-driver-32/share/vulkan/icd.d/nvidia_icd.json \
            /run/current-system/sw/bin/nvidia-offload "$steam_bin" "$app_uri"
          return
        fi

        launch_and_tune env \
          __GL_SYNC_TO_VBLANK=0 \
          vblank_mode=0 \
          __NV_PRIME_RENDER_OFFLOAD=1 \
          __GLX_VENDOR_LIBRARY_NAME=nvidia \
          __VK_LAYER_NV_optimus=NVIDIA_only \
          VK_DRIVER_FILES=/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.json:/run/opengl-driver-32/share/vulkan/icd.d/nvidia_icd.json \
          VK_ICD_FILENAMES=/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.json:/run/opengl-driver-32/share/vulkan/icd.d/nvidia_icd.json \
          "$steam_bin" "$app_uri"
      }

      case "$profile" in
        integrated)
          label="Integrated GPU"
          ;;
        dedicated)
          label="Dedicated GPU"
          ;;
        *)
          notify_user "Stellaris GPU Launcher" "Usage: stellaris-steam-gpu integrated|dedicated"
          exit 2
          ;;
      esac

      pid="$(steam_pid)"
      if [[ -n "$pid" ]]; then
        running_profile="$(steam_profile "$pid")"
        if [[ "$running_profile" == "$profile" ]]; then
          launch_and_tune "$steam_bin" "$app_uri"
          exit 0
        fi

        notify_user \
          "Steam is already running" \
          "Steam is already running with GPU profile '$running_profile'. Quit Steam, then open Stellaris ($label) again."
        exit 1
      fi

      case "$profile" in
        integrated)
          launch_integrated
          ;;
        dedicated)
          launch_dedicated
          ;;
      esac
    '';
  };
  stellarisIntegratedDesktop = pkgs.writeTextFile {
    name = "stellaris-integrated-desktop";
    destination = "/share/applications/stellaris-integrated.desktop";
    text = ''
      [Desktop Entry]
      Name=Stellaris (Integrated GPU)
      Comment=Play Stellaris through Steam on the Intel integrated GPU
      Exec=${lib.getExe stellarisSteamGpu} integrated
      Icon=steam_icon_281990
      Terminal=false
      Type=Application
      Categories=Game;
      StartupNotify=false
      X-GNOME-UsesNotifications=true
    '';
  };

  stellarisGpuLaunchers = pkgs.symlinkJoin {
    name = "stellaris-gpu-launchers";
    paths = [
      stellarisSteamGpu
      stellarisIntegratedDesktop
    ];
  };
in
{
  networking.hostName = lib.mkForce "precision7560";

  imports =[
    "${inputs.nixos-hardware}/common/cpu/intel"
    "${inputs.nixos-hardware}/common/gpu/intel/tiger-lake"
    
    # We import turing so we get the base community Nvidia fixes (via its ../. import)
    "${inputs.nixos-hardware}/common/gpu/nvidia/ampere"
    
    # We skip prime.nix because we are explicitly configuring it below.
  ];
  # =========================================================
  # BASIC COOLING & BATTERY MANAGEMENT 
  # =========================================================
  # Essential for the Intel i7 to downclock and stay cool
  services.power-profiles-daemon.enable = false;
  services.thermald.enable = false;
  environment.systemPackages = [
    pkgs.intel-undervolt
    pkgs.msr-tools
    pkgs.s-tui
    pkgs.stress-ng

    # --- Dell Battery Health Charging ---
    pkgs.libsmbios 
        # We extract the extension's native script and put it in the system path
    batteryHealthChargingCtl
    stellarisGpuLaunchers
  ];

  home-manager.users.lexyo.xdg.desktopEntries.Stellaris = {
    name = "Stellaris (GPU)";
    comment = "Play Stellaris through Steam on the NVIDIA GPU";
    exec = "${lib.getExe stellarisSteamGpu} dedicated";
    icon = "steam_icon_281990";
    terminal = false;
    categories = [ "Game" ];
    settings = {
      StartupNotify = "false";
      X-GNOME-UsesNotifications = "true";
    };
  };

    systemd.tmpfiles.rules = [
    "d /usr/sbin 0755 root root -"
    "L+ /usr/sbin/smbios-battery-ctl - - - - ${pkgs.libsmbios}/sbin/smbios-battery-ctl"
  ];
      # Polkit rules for GNOME extensions
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      var program = action.lookup("program");
      if (action.id == "org.freedesktop.policykit.exec" &&
          (program == "/usr/sbin/smbios-battery-ctl" ||
           program == "${pkgs.libsmbios}/bin/smbios-battery-ctl" ||
           program == "${pkgs.libsmbios}/sbin/smbios-battery-ctl" ||
           program == "/run/current-system/sw/bin/smbios-battery-ctl" ||
           program == "/run/current-system/sw/bin/batteryhealthchargingctl" ||
           program == "${batteryHealthChargingCtl}/bin/batteryhealthchargingctl") &&
          subject.user == "lexyo") {
        return polkit.Result.YES;
      }
    });
  '';

  services.tlp = {
    enable = true;
    settings = {

      USB_AUTOSUSPEND = 1;
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;
      CPU_BOOST_ON_AC = 1; #TODO
      CPU_BOOST_ON_BAT = 0; # Turns off Turbo Boost on Battery
      CPU_HWP_DYN_BOOST_ON_AC = 1;
      CPU_HWP_DYN_BOOST_ON_BAT = 0;
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_MAX_PERF_ON_AC = 100;
      CPU_DRIVER_OPMODE_ON_AC = "guided";
      CPU_DRIVER_OPMODE_ON_BAT = "active";
      
      # Turn on Wi-Fi power saving mode
      WIFI_PWR_ON_BAT = "on";
      
      # Power down the audio chip when no sound is playing
      SOUND_POWER_SAVE_ON_BAT = 1;

      # NVMe ASPM power saving
      NVME_PRSNT_ON_BAT = 1;
            # Force Intel's energy preference to favor battery life
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";

      # Limit maximum CPU frequency on battery to save power (optional but highly effective)
      # 3000 MHz (3.0GHz) is plenty fast for UI responsiveness but prevents voltage spikes
      CPU_MAX_PERF_ON_BAT = 60; 
      
      # Put PCIe devices in low power modes actively, even when suspended on AC.
      PCIE_ASPM_ON_AC = "powersave";
      PCIE_ASPM_ON_BAT = "powersupersave";
      RUNTIME_PM_ON_AC = "auto";
      RUNTIME_PM_ON_BAT = "auto";
    };
  };

    # Enable Throttled for Throttlestop-like profiles (PL1/PL2, IccMax, Undervolt)
  services.throttled = {
    enable = true;
    extraConfig = ''
      [GENERAL]
      # Enable or disable the script execution
      Enabled: True
      Sysfs_Power_Path: /sys/class/power_supply/AC*/online
      Autoreload: True

      [AC]
      Update_Rate_s: 5
      PL1_Tdp_W: 55
      PL1_Duration_s: 28
      PL2_Tdp_W: 80
      PL2_Duration_S: 2
      Trip_Temp_C: 90

      [BATTERY]
      Update_Rate_s: 30
      PL1_Tdp_W: 7
      PL1_Duration_s: 28
      PL2_Tdp_W: 15
      PL2_Duration_S: 2
      Trip_Temp_C: 65
    '';
  };

      #   [UNDERVOLT.BATTERY]
      # # # Mirroring your stable -80mV undervolt
      # # CORE: -70
      # # CACHE: -70
      # # GPU: -40
      # # UNCORE: 0
      # # ANALOGIO: 0

      # # [UNDERVOLT.AC]
      # # CORE: -70
      # # CACHE: -70
      # # GPU: -40
      # # UNCORE: 0
      # # ANALOGIO: 0
  # Ensure the kernel module required to write to CPU registers is loaded
  boot.kernelModules = [ "msr" ];


  # IA32_TURBO_RATIO_LIMIT (MSR 0x1AD), encoded as 8C..1C bytes.
  # 1C=46, 2C=46, 3C=44, 4C=44, 5C-8C=42.
  # Bounded by throttled's AC 55 W PL1 / 80 W PL2 limits; no voltage offsets are applied here.

  # Create a systemd service to inject the Turbo Ratios automatically
  systemd.services.apply-turbo-ratios = {
    description = "Apply Custom Turbo Ratio Limits via MSR 0x1AD";
    
    # Run on boot and after the system wakes up from sleep
    wantedBy = [ "multi-user.target" "post-resume.target" ];
    after = [ "systemd-modules-load.service" "suspend.target" "hibernate.target" ];
    
    serviceConfig = {
      Type = "oneshot";
      # -a applies it to all logical processors
      ExecStart = "${pkgs.msr-tools}/bin/wrmsr -a 0x1AD ${cpuTurboRatioLimit}";
    };
  };

  # =========================================================
  # GRAPHICS & NVIDIA OPTIMUS
  # =========================================================
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver # Hardware decoding for Intel Tiger Lake
      intel-vaapi-driver # Fallback for older apps
      libvdpau-va-gl
    ];
  };
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
    
    # Override ampere.nix. 
    open = false; 

    powerManagement = {
      enable = true;
      finegrained = true;
    };

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };

      # Bus IDs (Verify with 'lspci | grep -E "VGA|3D"')
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # Use systemd in initrd – required for TPM
  boot.initrd.systemd.enable = true;
  # Enable TPM2 support in initrd
  boot.initrd.systemd.tpm2.enable = true;
  
    boot.initrd.luks.devices."luks-430e2b02-5f47-43f3-9ae5-1e90a4a91952" = {
    device = "/dev/disk/by-uuid/430e2b02-5f47-43f3-9ae5-1e90a4a91952";
    crypttabExtraOpts = [ "tpm2-device=auto" ];
  };

  # Swap LUKS
  boot.initrd.luks.devices."luks-a5feba67-fcf2-4840-bb72-683c5f436f96" = {
    device = "/dev/disk/by-uuid/a5feba67-fcf2-4840-bb72-683c5f436f96";
    crypttabExtraOpts = [ "tpm2-device=auto" ];
  };
  boot.resumeDevice = "/dev/mapper/luks-a5feba67-fcf2-4840-bb72-683c5f436f96";
  # sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/disk/by-uuid/430e2b02-5f47-43f3-9ae5-1e90a4a91952
  # sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/disk/by-uuid/a5feba67-fcf2-4840-bb72-683c5f436f96
  # sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/nvme0n1p3

# =======================================================================
  # 1. FORCE THE MSI MOTHERBOARD TO ALLOW PCIE SLEEP (ASPM)
  # =======================================================================
  # =======================================================================
  # OVERRIDE NIXOS SOURCE CODE TO KILL THE FRAMEBUFFER LOCK
  # =======================================================================
#   boot.kernelParams = lib.mkAfter[ 
#     "nvidia-drm.fbdev=0" 
#     "nvidia_drm.fbdev=0" 
#     "pcie_port_pm=force" 
#     "pcie_aspm=force" 
#   ];
boot.kernelParams = [ 
  "nmi_watchdog=0"
  # "pcie_aspm=force"
  "i915.enable_psr=1"
  "i915.enable_fbc=1"
  # "acpi_mask_gpe=0x6E"
  # "intel_idle.no_acpi=1"

  ];
  boot.extraModprobeConfig = ''
    # Put the Intel audio chip to sleep after 1 second of no sound to allow PC10
    options snd_hda_intel power_save=1 power_save_controller=y

    # Prefer low-power defaults for the Intel AX210 Wi-Fi stack on battery.
    options iwlwifi power_save=Y power_level=5
    options iwlmvm power_scheme=3
  '';
  boot.blacklistedKernelModules = [ 
    "rtsx_pci" "rtsx_pci_sdmmc" "rtsx_pci_ms" #Disable to use Card reader 
   ]; 

services.udev.extraRules = ''
    # 1. Stops GNOME's Mutter and systemd-logind from polling the NVIDIA GPU and keeping it awake.
    # Apply on change events too, because external monitor hotplug can cause systemd's seat rules
    # to re-tag the NVIDIA DRM node after the initial add event.
    #ACTION!="remove", SUBSYSTEM=="drm", KERNEL=="card*", SUBSYSTEMS=="pci", ATTRS{vendor}=="0x10de", ENV{MUTTER_HINTS}="ignore-device", TAG+="mutter-device-ignore", TAG-="seat", TAG-="master-of-seat"
    ACTION=="add", SUBSYSTEM=="drm", KERNEL=="card*", SUBSYSTEMS=="pci", ATTRS{vendor}=="0x10de", ENV{MUTTER_HINTS}="ignore-device", TAG-="seat", TAG-="master-of-seat"

    # 2. Force PCI power management "auto" for the NVIDIA GPU
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030000", ATTR{power/control}="auto"
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030200", ATTR{power/control}="auto"
  '';
}
