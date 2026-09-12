# Display-only baseline: physical HDMI/Intel/CUDA tested, GPU return FAILED.
# Base for the lifecycle repair and historical comparison tests, not safe alone.
{ pkgs }:
(import ./mutter-scanout-candidate.nix { inherit pkgs; }).overrideAttrs (old: {
  patches = old.patches ++ [ ./mutter-scanout-cpu-copy.patch ];
})
