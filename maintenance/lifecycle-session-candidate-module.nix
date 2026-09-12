# Build-only lifecycle candidate. No new logout/reboot or GPU transfer grant.
{ lib, ... }:
{
  imports = [ ./scanout-cpu-session-candidate-module.nix ];
  nixpkgs.overlays = lib.mkAfter [
    (_final: previous: {
      mutter = previous.mutter.overrideAttrs (old: {
        patches = old.patches ++ [ ./mutter-scanout-lifecycle.patch ];
      });
    })
  ];
}
