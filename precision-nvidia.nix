{ config, pkgs, lib, ... }:

let
  # Fetches the hardware repo exactly once. Instantly faster rebuilds, no --impure!
  nixos-hardware = builtins.fetchTarball {
    url="https://github.com/NixOS/nixos-hardware/archive/master.tar.gz";
    sha256="sha256:1qhzdprp5nshf98gd3afm8j0241m9gbaxwcf3ynrmvls9y4wzyyc";
  };
in
{
  networking.hostName = lib.mkForce "precision7560";

  imports =[
    "${nixos-hardware}/common/cpu/intel"
    "${nixos-hardware}/common/gpu/intel/tiger-lake"
    
    # We import turing so we get the base community Nvidia fixes (via its ../. import)
    "${nixos-hardware}/common/gpu/nvidia/ampere"
    
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

    # --- Dell Battery Health Charging ---
    pkgs.libsmbios 
        # We extract the extension's native script and put it in the system path
    (pkgs.writeShellScriptBin "batteryhealthchargingctl" (builtins.readFile "${pkgs.gnomeExtensions.battery-health-charging}/share/gnome-shell/extensions/Battery-Health-Charging@maniacx.github.com/resources/batteryhealthchargingctl"))
  ];
    systemd.tmpfiles.rules = [
    "d /usr/sbin 0755 root root -"
    "L+ /usr/sbin/smbios-battery-ctl - - - - ${pkgs.libsmbios}/sbin/smbios-battery-ctl"
  ];
      # Polkit rules for GNOME extensions
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.policykit.exec" &&
          (action.lookup("program") == "/usr/sbin/smbios-battery-ctl" ||
           action.lookup("program") == "${pkgs.libsmbios}/sbin/smbios-battery-ctl" ||
           action.lookup("program") == "/run/current-system/sw/bin/smbios-battery-ctl") &&
          subject.local && subject.active) {
        return polkit.Result.YES;
      }
    });
  '';

  services.tlp = {
    enable = true;
    settings = {

      USB_AUTOSUSPEND = 1;
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0; # Turns off Turbo Boost on Battery
      CPU_HWP_DYN_BOOST_ON_AC = 1;
      CPU_HWP_DYN_BOOST_ON_BAT = 0;
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_DRIVER_OPMODE_ON_AC = "guided";
      CPU_DRIVER_OPMODE_ON_BAT = "active";
      MEM_SLEEP_ON_AC="s2idle";
      MEM_SLEEP_ON_BAT="s2idle";
      
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
      
      # Put PCIe devices in extreme low power modes actively
      PCIE_ASPM_ON_BAT = "powersupersave";
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

      [BATTERY]
      Update_Rate_s: 30
      # Power Limits (ThrottleStop PL1 / PL2) in Watts
      PL1_Tdp_W: 5
      PL1_Duration_s: 28
      PL2_Tdp_W: 10
      PL2_Duration_S: 0.002
      Trip_Temp_C: 65

      [AC]
      Update_Rate_s: 5
      # Higher Power Limits for AC
      PL1_Tdp_W: 40
      PL1_Duration_s: 28
      PL2_Tdp_W: 44
      PL2_Duration_S: 0.002
      Trip_Temp_C: 85

      [UNDERVOLT.BATTERY]
      # Mirroring your stable -80mV undervolt
      CORE: -70
      CACHE: -70
      GPU: -40
      UNCORE: 0
      ANALOGIO: 0

      [UNDERVOLT.AC]
      CORE: -70
      CACHE: -70
      GPU: -40
      UNCORE: 0
      ANALOGIO: 0

      [ICCMAX.BATTERY]
      # Adjust IccMax limit specifically for battery (in Amps)


      [ICCMAX.AC]
      # Leaving this blank falls back to your hardware's default high IccMax
    '';
  };
  # Ensure the kernel module required to write to CPU registers is loaded
  boot.kernelModules = [ "msr" ];


# 8c=24 (15)
# 7c=24 (15)
# 6c=25 (22->16)
# 5c=27 (24->18)
# 4c=30 (27->1B)
# 3c=33 (30->1E)
# 2c=36 (33->21)
# 1c=38 (35->23)

  # Create a systemd service to inject the Turbo Ratios automatically
  systemd.services.apply-turbo-ratios = {
    description = "Apply Custom Turbo Ratio Limits via MSR 0x1AD";
    
    # Run on boot and after the system wakes up from sleep
    wantedBy = [ "multi-user.target" "post-resume.target" ];
    after = [ "systemd-modules-load.service" "suspend.target" "hibernate.target" ];
    
    serviceConfig = {
      Type = "oneshot";
      # -a applies it to all logical processors
      ExecStart = "${pkgs.msr-tools}/bin/wrmsr -a 0x1AD 0x151516181B1E2123";
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
    
    package = config.boot.kernelPackages.nvidiaPackages.legacy_535;
    
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
  "pcie_aspm=force"
  "i915.enable_psr=1"
  "i915.enable_fbc=1"
  "initcall_blacklist=idma64_platform_driver_init"
  # "acpi_mask_gpe=0x6E"
  "nvme.noacpi=1"

  ];
  boot.extraModprobeConfig = ''
    # Put the Intel audio chip to sleep after 1 second of no sound to allow PC10
    options snd_hda_intel power_save=1 power_save_controller=y
  '';
  boot.blacklistedKernelModules = [ 
    "rtsx_pci" "rtsx_pci_sdmmc" "rtsx_pci_ms" #Disable to use Card reader 
   ]; 

services.udev.extraRules = ''
    # 1. Stops GNOME's Mutter and systemd-logind from polling the NVIDIA GPU and keeping it awake.
    # We use ATTRS{vendor}=="0x10de" to target the hardware directly, preventing boot race conditions.
    ACTION=="add", SUBSYSTEM=="drm", KERNEL=="card*", SUBSYSTEMS=="pci", ATTRS{vendor}=="0x10de", ENV{MUTTER_HINTS}="ignore-device", TAG-="seat", TAG-="master-of-seat"

    # 2. Force PCI power management "auto" for the NVIDIA GPU
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030000", ATTR{power/control}="auto"
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030200", ATTR{power/control}="auto"
  '';
}