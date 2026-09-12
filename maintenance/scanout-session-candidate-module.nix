# Explicit test output only. Not imported by the normal Precision output.
# This removes two handle-retention sources; it is NOT a full hot-unplug fix.
{ lib, ... }:
{
  services.precision-windows.gamingEnabled = lib.mkDefault false;
  services.precision-windows.useHostCompositorBaseline = lib.mkForce false;
  nixpkgs.overlays = [
    (_final: previous: {
      mutter = import ./mutter-scanout-candidate.nix { pkgs = previous; };
    })
  ];
  services.udev.extraRules = lib.mkAfter ''
    ACTION!="remove", SUBSYSTEM=="drm", KERNEL=="card[0-9]*", ENV{ID_PATH}=="pci-0000:01:00.0", ENV{MUTTER_DEVICE_SCANOUT_ONLY}="1"
  '';
  systemd.services.display-manager = {
    restartIfChanged = false;
    stopIfChanged = false;
  };
}
