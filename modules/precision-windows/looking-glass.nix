{ pkgs }:
# Pinned matching IDD/client release: virtual monitor without a physical dummy
# plug. This is an upstream development snapshot, not the stable B7 release.
pkgs.looking-glass-client.overrideAttrs (old: {
  version = "B7-826-236efcb1";
  src = pkgs.fetchzip {
    name = "source";
    url = "https://looking-glass.io/artifact/B7-826-236efcb1/source";
    extension = "tar.gz";
    hash = "sha256-5OnYi9V5pHMkv/9BRw/f5TcUzCPIlKAktZffvkPrkrM=";
  };
  # The release archive includes its exact upstream submodule revisions.
  patches = [];
  postUnpack = ''
    export sourceRoot="source/client"
  '';
  buildInputs = old.buildInputs ++ [ pkgs.fuse3 pkgs.libunwind pkgs.elfutils pkgs.libdecor pkgs.usbredir ];
  postInstall = "";
})
