{ lib, pkgs, ... }:

let
  passthroughGpuIds = [
    "10de:25b8" # NVIDIA RTX A2000 Mobile
    "10de:2291" # NVIDIA GA107 HDMI/DP audio
  ];
  passthroughGpuIdsString = lib.concatStringsSep "," passthroughGpuIds;
in
{
  # VM tooling is available in both boots. The normal boot keeps the RTX on the
  # NVIDIA driver for Linux offload and runtime power management.
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      swtpm.enable = true;
      runAsRoot = true;
    };
  };

  programs.virt-manager.enable = true;
  security.polkit.enable = true;
  security.pam.loginLimits = [
    {
      domain = "@kvm";
      type = "-";
      item = "memlock";
      value = "unlimited";
    }
  ];

  users.users.lexyo.extraGroups = [ "kvm" "libvirtd" ];

  environment.systemPackages = with pkgs; [
    virt-viewer
    looking-glass-client
    pciutils
    (writeShellScriptBin "vfio-status" ''
      set -eu

      echo "Kernel command line:"
      cat /proc/cmdline
      echo

      echo "RTX A2000 devices:"
      lspci -nnk -s 01:00.0 || true
      lspci -nnk -s 01:00.1 || true
      echo

      echo "IOMMU groups:"
      find /sys/kernel/iommu_groups -type l -printf '%h/%f -> %l\n' | sort -V
    '')
  ];

  services.udev.extraRules = ''
    # Allow the logged-in user, via the kvm group, to launch QEMU with VFIO.
    SUBSYSTEM=="vfio", KERNEL=="[0-9]*", GROUP="kvm", MODE="0660"
    SUBSYSTEM=="vfio-dev", GROUP="kvm", MODE="0660"
  '';

  specialisation.vfio.configuration = {
    system.nixos.tags = [ "vfio" ];

    boot.kernelParams = lib.mkAfter [
      "intel_iommu=on"
      "iommu=pt"
      "kvm.ignore_msrs=1"
      "vfio-pci.ids=${passthroughGpuIdsString}"
    ];

    boot.initrd.kernelModules = lib.mkAfter [
      "vfio"
      "vfio_iommu_type1"
      "vfio_pci"
    ];

    boot.blacklistedKernelModules = lib.mkAfter [
      "nouveau"
      "nvidia"
      "nvidia_drm"
      "nvidia_modeset"
      "nvidia_uvm"
    ];

    boot.extraModprobeConfig = lib.mkAfter ''
      options kvm ignore_msrs=1 report_ignored_msrs=0
      options vfio-pci ids=${passthroughGpuIdsString} disable_vga=1
    '';

    services.xserver.videoDrivers = lib.mkForce [ "modesetting" ];

    hardware.nvidia = {
      modesetting.enable = lib.mkForce false;
      powerManagement.enable = lib.mkForce false;
      powerManagement.finegrained = lib.mkForce false;
      prime.offload.enable = lib.mkForce false;
      prime.offload.enableOffloadCmd = lib.mkForce false;
    };

    services.udev.extraRules = lib.mkAfter ''
      # Let the VFIO-bound NVIDIA GPU runtime-suspend when no passthrough VM uses it.
      ACTION=="add|change", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{power/control}="auto"
    '';
  };
}
