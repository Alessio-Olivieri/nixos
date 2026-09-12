# BUILD-ONLY candidate. Not imported by the system configuration and not a
# complete GPU detach/re-add implementation. Requires independent validation.
{ pkgs }:
assert pkgs.mutter.version == "50.1";
pkgs.mutter.overrideAttrs (old: {
  patches = (old.patches or []) ++ [ ./mutter-gpu-add-monitor.patch ];
})
