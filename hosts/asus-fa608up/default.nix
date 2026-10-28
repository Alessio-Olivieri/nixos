{ config, lib, pkgs, inputs, ... }:
let
  cfg = config.hardware.asus-fa608up;
  pciAddress = lib.types.strMatching "[0-9a-f]{4}:[0-9a-f]{2}:[0-9a-f]{2}\\.[0-7]";
  # Xorg expects decimal PCI components, including the domain.
  busId = address:
    let parts = lib.splitString ":" (builtins.replaceStrings [ "." ] [ ":" ] address);
        decimal = index: toString (lib.fromHexString (builtins.elemAt parts index));
    in "PCI:${decimal 1}@${decimal 0}:${decimal 2}:${decimal 3}";
in {
  imports = [
    ../../configuration.nix
    ./hardware-configuration.nix
    ./machine.nix
    ./graphics.nix
    ./hibernate.nix
    ../../modules/precision-gpu-indicator/module.nix
    "${inputs.nixos-hardware}/common/cpu/amd"
    "${inputs.nixos-hardware}/common/gpu/amd"
    "${inputs.nixos-hardware}/common/pc/laptop"
    "${inputs.nixos-hardware}/common/pc/ssd"
  ];

  options.hardware.asus-fa608up = {
    configured = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether this laptop's disk configuration and GPU addresses have been collected.";
    };
    amdPciAddress = lib.mkOption {
      type = pciAddress;
      default = "0000:00:00.0"; # Inert placeholder; the assertion prevents installation.
      description = "Full AMD display-controller PCI address from this laptop.";
    };
    nvidiaPciAddress = lib.mkOption {
      type = pciAddress;
      default = "0000:00:00.0";
      description = "Full NVIDIA display-controller PCI address from this laptop.";
    };
    irCamera = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Verified IR camera device path for optional Howdy face login.";
    };
  };

  config = {
    assertions = [
      {
        assertion = cfg.configured && cfg.amdPciAddress != cfg.nvidiaPciAddress;
        message = "Run hosts/asus-fa608up/prepare.py on the ASUS before building this profile; see its README.";
      }
    ];

    networking.hostName = lib.mkForce "asus-fa608up";
    services.xserver.xkb = {
      layout = lib.mkForce "it";
      variant = lib.mkForce "";
    };
    console.keyMap = lib.mkForce "it";
    home-manager.users.lexyo = { lib, ... }: {
      # dconf otherwise overrides the system layout with the saved German one.
      dconf.settings."org/gnome/desktop/input-sources" = {
        sources = lib.mkForce [ (lib.hm.gvariant.mkTuple [ "xkb" "it" ]) ];
        mru-sources = lib.mkForce [ (lib.hm.gvariant.mkTuple [ "xkb" "it" ]) ];
        xkb-options = lib.mkForce [ ];
      };
      gnome-manager.batteryHealthCharging = false; # asusd owns charge limits.
      dconf.settings."org/gnome/shell".enabled-extensions =
        lib.mkAfter [ "gpu-indicator@alessio.local" ];
    };

    # Do not inherit another laptop's Windows partition or USB network topology.
    fileSystems."/mnt/shared".enable = false;
    networking.nat.enable = lib.mkForce false;

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    boot.initrd.kernelModules = [ "amdgpu" ];
    boot.kernelModules = [ "kvm-amd" "asus_wmi" "asus_nb_wmi" ];
    boot.kernelParams = [ "amd_pstate=active" ];
    hardware.enableRedistributableFirmware = true;
    boot.initrd.systemd.enable = true;
    boot.initrd.systemd.tpm2.enable = true;
    security.tpm2.enable = true;
    services.fwupd.enable = true;

    # One owner for platform profiles/EPP, fans, keyboard lighting and charging.
    services.asusd.enable = true;
    services.power-profiles-daemon.enable = lib.mkForce false;
    services.tlp.enable = lib.mkForce false;
    services.thermald.enable = lib.mkForce false;
    environment.systemPackages = with pkgs; [
      asusctl # Includes rog-control-center in the pinned nixpkgs.
      s-tui pciutils usbutils
      v4l-utils linux-enable-ir-emitter virt-viewer looking-glass-client
    ];

    hardware.nvidia = {
      open = true; # Blackwell requires NVIDIA's open kernel modules.
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      modesetting.enable = true;
      powerManagement.enable = true;
      powerManagement.finegrained = true;
      prime = {
        amdgpuBusId = busId cfg.amdPciAddress;
        nvidiaBusId = busId cfg.nvidiaPciAddress;
        offload.enable = true;
        offload.enableOffloadCmd = true;
      };
    };
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.graphics = { enable = true; enable32Bit = true; };
    environment.sessionVariables.LIBVA_DRIVER_NAME = lib.mkForce "radeonsi";
    services.udev.extraRules = ''
      ACTION!="remove", SUBSYSTEM=="drm", KERNEL=="card[0-9]*", ENV{ID_PATH}=="pci-${cfg.amdPciAddress}", TAG+="mutter-device-preferred-primary"
    '';
    services.gpu-indicator = {
      enable = true;
      device = cfg.nvidiaPciAddress;
      integratedGpuName = "AMD";
    };

    # Keep CUDA AI, without the Precision A2000's sm_86-only build restriction.
    services.ollama.package = pkgs.ollama-cuda;

    virtualisation.libvirtd = {
      enable = true;
      qemu = { package = pkgs.qemu_kvm; swtpm.enable = true; };
    };
    programs.virt-manager.enable = true;
    users.users.lexyo.extraGroups = [ "libvirtd" "video" "render" ];

    # Reuse the Precision policy with power-supply-name independent detection.
    systemd.services.battery-background-policy.script = lib.mkForce ''
      userctl="systemctl --user -M lexyo@.host"
      $userctl is-active dbus-broker.service >/dev/null 2>&1 || exit 0
      $userctl unmask --runtime syncthing.service localsearch-3.service || true
      $userctl daemon-reload || true
      if ${pkgs.systemd}/bin/systemd-ac-power; then
        $userctl reset-failed syncthing.service localsearch-3.service || true
        $userctl start syncthing.service || true
      else
        $userctl stop syncthing.service localsearch-3.service || true
        $userctl reset-failed syncthing.service localsearch-3.service || true
      fi
    '';
    systemd.timers.battery-background-policy = {
      wantedBy = [ "timers.target" ];
      timerConfig = { OnBootSec = "30s"; OnUnitActiveSec = "60s"; };
    };

    # The IR node is machine-specific; never assume Precision's /dev/video2.
    services.howdy = lib.mkIf (cfg.irCamera != null) {
      enable = true;
      settings = {
        core.workaround = "off";
        video = { device_path = cfg.irCamera; timeout = 2; };
      };
    };
    security.pam.services = lib.mkIf (cfg.irCamera != null)
      (lib.genAttrs [ "sudo" "login" "gdm" ] (name: {
        howdy = { enable = true; control = "sufficient"; };
        rules.auth.howdy.order = config.security.pam.services.${name}.rules.auth.unix.order - 10;
      }));
  };
}
