# BUILD/ISOLATED-TEST ONLY. Does not change the running compositor or the
# previous single-session test output. Full DRM removal/re-add is separate.
{ pkgs }:
assert pkgs.mutter.version == "50.1";
pkgs.mutter.overrideAttrs (old: {
  patches = (old.patches or []) ++ [
    ./mutter-gpu-add-monitor.patch
    ./mutter-scanout-only.patch
  ];
})
