{ lib, pkgs, ... }: {
  # The shared desktop launcher points to a Quickemu file that does not exist
  # on this machine. Open the available VM manager for installation instead.
  home-manager.users.lexyo.xdg.desktopEntries.Windows = {
    name = lib.mkForce "Windows (VM setup)";
    exec = lib.mkForce "${pkgs.virt-manager}/bin/virt-manager --connect qemu:///system";
    categories = [ "System" ];
  };
  # libvirt's firmware auto-selection uses QEMU's packaged UEFI descriptors.
  # swtpm is enabled by default.nix. Define no VM, disk, GPU reservation or
  # shared-memory device until media, storage and passthrough are validated.
}
