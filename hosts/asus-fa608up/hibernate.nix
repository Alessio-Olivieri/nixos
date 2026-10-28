# Installation layout: LUKS cryptroot contains the nixos/root and nixos/swap LVs.
{ lib, ... }: {
  boot.initrd.services.lvm.enable = true;
  boot.resumeDevice = "/dev/mapper/nixos-swap";
  swapDevices = lib.mkForce [
    { device = "/dev/mapper/nixos-swap"; }
  ];

  # Use the Italian console layout when unlocking the disk in the initrd.
  console.earlySetup = true;

  # Keep NVIDIA's video-memory backup on the encrypted root filesystem.
  hardware.nvidia.moduleParams.nvidia.NVreg_TemporaryFilePath = "/var/tmp";
}
