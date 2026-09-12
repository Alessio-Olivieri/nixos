# Build-only follow-up. Does not authorize another activation/session test.
{ lib, ... }:
{
  imports = [ ./scanout-session-candidate-module.nix ];
  nixpkgs.overlays = lib.mkAfter [
    (_final: previous: {
      mutter = previous.mutter.overrideAttrs (old: {
        patches = old.patches ++ [ ./mutter-scanout-cpu-copy.patch ];
      });
    })
  ];
}
