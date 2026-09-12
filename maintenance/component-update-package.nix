{ pkgs }:
let
  # Reviewed immutable update, preserving the exact already-running compositor.
  config = pkgs.writeText "precision-component-update.json" (builtins.toJSON {
    baseline = "/nix/store/xl5mdhz28nwnr46ydj85cdyb77d77aqq-nixos-system-precision7560-26.05.20260611.a037402";
    candidate = "/nix/store/c4d4khxkv2bj5m1k6gvh3v5576hmcpw0-nixos-system-precision7560-26.05.20260611.a037402";
    boot = "ec89b2a7-35c8-44cc-8ee9-0ccb1419e153";
    shell_pid = 77549;
    shell_start = "811511";
  });
in pkgs.runCommand "precision-component-update" {} ''
  mkdir -p $out/bin
  cp ${./apply-component-update.py} $out/bin/precision-component-update
  substituteInPlace $out/bin/precision-component-update \
    --replace-fail '#!/usr/bin/env python3' '#!${pkgs.python3}/bin/python3 -I' \
    --replace-fail '@config@' '${config}'
  chmod +x $out/bin/precision-component-update
''
