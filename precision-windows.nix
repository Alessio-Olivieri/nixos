{ config, lib, pkgs, ... }:
let
  lookingGlass = import ./modules/precision-windows/looking-glass.nix { inherit pkgs; };
  windows = import ./modules/precision-windows/package.nix { inherit lib pkgs lookingGlass; };
in
{
  imports = [ ./modules/precision-gpu-indicator/module.nix ];
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
    ACTION!="remove", SUBSYSTEM=="drm", KERNEL=="card[0-9]*", SUBSYSTEMS=="pci", ATTRS{vendor}=="0x10de", TAG+="mutter-device-ignore"
    SUBSYSTEM=="kvmfr", KERNEL=="kvmfr0", OWNER="lexyo", GROUP="kvm", MODE="0600"
  '';
  home-manager.users.lexyo.dconf.settings."org/gnome/shell".enabled-extensions = lib.mkAfter [ "gpu-indicator@alessio.local" ];
  environment.systemPackages = [ windows lookingGlass pkgs.virt-viewer ];
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
  };
}
