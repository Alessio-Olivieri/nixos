# Lifecycle repair: repeated physical GPU-return cycles passed September12.
{ pkgs }:
(import ./mutter-scanout-cpu-candidate.nix { inherit pkgs; }).overrideAttrs (old: {
  patches = old.patches ++ [ ./mutter-scanout-lifecycle.patch ];
})
