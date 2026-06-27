{ config, pkgs, lib, ... }:

{
  # Abilita il passthrough USB per la calcolatrice TI-Nspire
  virtualisation.spiceUSBRedirection.enable = true;
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };
  security.lsm = lib.mkForce [ ]; # otherwise distrobox doesn't work

  # Abilita il demone SPICE per condividere la clipboard tra NixOS e la VM
  services.spice-vdagentd.enable = true;

  # Assicurati di essere nel gruppo kvm
  users.users.lexyo = {
    extraGroups = [ "kvm" ];
  };
  environment.systemPackages = [
    pkgs.quickemu
  ];
}