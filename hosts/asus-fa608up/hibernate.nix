# Installation layout: LUKS cryptroot contains the nixos/root and nixos/swap LVs.
{ lib, ... }: {
  # Verified with lsblk on this installation: LUKS2 below the LVM PV.
  # Use filesystem identity rather than enumeration order of NVMe devices.
  boot.initrd.luks.devices.cryptroot.device = lib.mkDefault
    "/dev/disk/by-uuid/5e8fae2d-7786-4440-9adf-bf1fce62b3e7";
  boot.initrd.services.lvm.enable = true;
  boot.resumeDevice = "/dev/mapper/nixos-swap";
  swapDevices = lib.mkForce [
    { device = "/dev/mapper/nixos-swap"; }
  ];

  # Use the Italian console layout when unlocking the disk in the initrd.
  console.earlySetup = true;

  # The first real test exhausted snapshot RAM before image creation, despite
  # an empty 20 GiB resume LV. Ask the kernel to reclaim toward its smallest
  # possible image. This is best effort; a successful restore still needs a
  # separate test, particularly after GPU recovery from an aborted attempt.
  systemd.tmpfiles.rules = [ "w /sys/power/image_size - - - - 0" ];

  # Keep NVIDIA's video-memory backup on the encrypted root filesystem.
  hardware.nvidia.moduleParams.nvidia.NVreg_TemporaryFilePath = "/var/tmp";
}
