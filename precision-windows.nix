{ config, lib, pkgs, ... }:
let
  lookingGlass = import ./modules/precision-windows/looking-glass.nix { inherit pkgs; };
  windows = import ./modules/precision-windows/package.nix {
    inherit lib pkgs lookingGlass;
    gamingEnabled = config.services.precision-windows.gamingEnabled;
    requiredMutter = "${pkgs.mutter}/lib/libmutter-18.so.0.0.0";
  };
in
{
  imports = [
    ./modules/precision-gpu-indicator/module.nix
    ./modules/precision-windows/host-compositor.nix
  ];
  services.gpu-indicator.enable = true;
  services.ollama.package = pkgs.ollama-cuda.override { cudaArches = [ "sm_86" ]; };
  # The console stays on i915; NVIDIA has no host framebuffer to retain it.
  hardware.nvidia.moduleParams.nvidia-drm.fbdev = lib.mkForce 0;

  # Enable DMA isolation without reserving NVIDIA at boot.
  boot.kernelParams = [ "intel_iommu=on" "iommu=pt" ];
  boot.kernelModules = [ "vfio-pci" "kvmfr" ];
  boot.extraModulePackages = [ (config.boot.kernelPackages.kvmfr.override { looking-glass-client = lookingGlass; }) ];
  boot.extraModprobeConfig = "options kvmfr static_size_mb=128\n";
  services.udev.extraRules = lib.mkAfter ''
    # Intel remains the compositor's renderer, including with HDMI connected.
    # NVIDIA is usable for host HDMI while Linux owns it. Gaming first disables
    # that output temporarily, then the root helper requires zero GPU owners.
    # Match ID_PATH, not ATTRS{vendor}: NVIDIA's upstream PCI bridge is Intel!
    ACTION!="remove", SUBSYSTEM=="drm", KERNEL=="card[0-9]*", ENV{ID_PATH}=="pci-0000:00:02.0", TAG+="mutter-device-preferred-primary"
    ACTION!="remove", SUBSYSTEM=="drm", KERNEL=="card[0-9]*", ENV{ID_PATH}=="pci-0000:01:00.0", TAG-="mutter-device-preferred-primary", TAG-="mutter-device-ignore", ENV{MUTTER_HINTS}="", TAG+="seat", TAG+="master-of-seat"
    SUBSYSTEM=="kvmfr", KERNEL=="kvmfr0", OWNER="lexyo", GROUP="kvm", MODE="0600"
  '';
  # Do not force connector off/detect or synthesize HOTPLUG during activation.
  # Those did not repair Mutter's stale GPU-add catalogue in the live test.
  home-manager.users.lexyo.dconf.settings."org/gnome/shell".enabled-extensions = lib.mkAfter [ "gpu-indicator@alessio.local" ];
  environment.systemPackages = [ windows lookingGlass pkgs.virt-viewer ];
  # VFIO pins the 16 GiB guest RAM. Keep the user's ordinary soft limit,
  # but allow the Windows service to request its bounded 20 GiB allowance.
  systemd.services."user@1001" = {
    overrideStrategy = "asDropin";
    restartIfChanged = false;
    stopIfChanged = false;
    serviceConfig.LimitMEMLOCK = "8M:20G";
  };
  security.sudo.extraRules = [{
    users = [ "lexyo" ];
    runAs = "root";
    commands = map (action: {
      command = "/run/current-system/sw/bin/precision-windows-gpu ${action}";
      options = [ "NOPASSWD" ];
    }) [ "inspect" "prepare" "release" ];
  }];
  home-manager.users.lexyo.xdg.desktopEntries = {
    Windows.noDisplay = lib.mkForce true;
    windows-gaming = {
      name = "Windows — Gaming";
      comment = "Use NVIDIA in Windows; closing the viewer requests clean shutdown";
      exec = "${windows}/bin/precision-windows gaming";
      icon = "distributor-logo-windows";
      terminal = false;
      categories = [ "System" ];
    };
    windows-light = {
      name = "Windows — Light";
      comment = "Basic Windows display; NVIDIA stays available to Linux";
      exec = "${windows}/bin/precision-windows light";
      icon = "distributor-logo-windows";
      terminal = false;
      categories = [ "System" ];
    };
    windows-usb = {
      name = "Windows — TI-Nspire USB";
      comment = "Pause or resume automatic TI-Nspire CX II forwarding";
      exec = "${windows}/bin/precision-windows usb";
      icon = "accessories-calculator";
      terminal = false;
      categories = [ "System" ];
    };
  };
}
