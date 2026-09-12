{ lib, ... }:
{
  services.precision-windows.gamingEnabled = lib.mkDefault false;
  services.precision-windows.useHostCompositorBaseline = lib.mkForce false;
  nixpkgs.overlays = [
    (_final: previous: {
      mutter = import ./mutter-hdmi-candidate.nix { pkgs = previous; };
    })
  ];

  # Activation must not end the current desktop. A separately authorized,
  # one-shot test controller restarts GDM only after normal user logout.
  systemd.services.display-manager = {
    restartIfChanged = false;
    stopIfChanged = false;
  };
}
