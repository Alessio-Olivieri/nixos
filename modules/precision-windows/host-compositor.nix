# Reproduce the lifecycle repair validated by physical Gaming return cycles.
{ config, lib, ... }:
{
  options.services.precision-windows.gamingEnabled = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Permit Gaming only with the configured lifecycle-repaired compositor actually mapped.";
  };
  options.services.precision-windows.useHostCompositorBaseline = lib.mkOption {
    type = lib.types.bool;
    default = true;
    internal = true;
    description = "Use the tested Intel-rendered, CPU-copy HDMI baseline; explicit historical test outputs provide their own compositor.";
  };

  config = lib.mkIf config.services.precision-windows.useHostCompositorBaseline {
    nixpkgs.overlays = [
      (_final: previous: {
        mutter = import ../../maintenance/mutter-lifecycle-candidate.nix {
          pkgs = previous;
        };
      })
    ];
    services.udev.extraRules = lib.mkAfter ''
      ACTION!="remove", SUBSYSTEM=="drm", KERNEL=="card[0-9]*", ENV{ID_PATH}=="pci-0000:01:00.0", ENV{MUTTER_DEVICE_SCANOUT_ONLY}="1"
    '';
    # A rebuild must not terminate an existing graphical session. A changed
    # compositor is loaded only by a subsequent, deliberately started session.
    systemd.services.display-manager = {
      restartIfChanged = false;
      stopIfChanged = false;
    };
  };
}
