{ pkgs }:
let
  config = pkgs.writeText "precision-scanout-cpu-session-test.json" (builtins.toJSON {
    candidate = "/nix/store/vzw5risximxbvjwr73s3drxvarf4wlf2-nixos-system-precision7560-26.05.20260611.a037402";
    baseline = "/nix/store/c4d4khxkv2bj5m1k6gvh3v5576hmcpw0-nixos-system-precision7560-26.05.20260611.a037402";
    saved = "/nix/store/xkga9k4w11g6yzbzp0pgwgsfg7p1c5cw-nixos-system-precision7560-26.05.20260611.a037402";
    old_shell_pid = 147739;
    old_shell_identity = [ "ec89b2a7-35c8-44cc-8ee9-0ccb1419e153" "1515021" ];
    runtime = "/run/precision-scanout-cpu-session-test";
    record = "/var/lib/precision-scanout-cpu-session-test-20260912";
    restart_gdm = false;
    systemctl = "${pkgs.systemd}/bin/systemctl";
    udevadm = "${pkgs.systemd}/bin/udevadm";
  });
  core = pkgs.writeText "precision-scanout-cpu-session-core.py"
    (builtins.replaceStrings [ "@config@" ] [ "${config}" ]
      (builtins.readFile ./session-test-control.py));
  guard = pkgs.writeText "precision-scanout-cpu-preview-guard.py"
    (builtins.replaceStrings [ "@config@" ] [ "${config}" ]
      (builtins.readFile ./apply-component-update.py));
  scripts = pkgs.runCommand "precision-scanout-cpu-session-tools" {} ''
    mkdir -p $out/bin
    cp ${./scanout-test-control.py} $out/bin/precision-scanout-cpu-session-control
    substituteInPlace $out/bin/precision-scanout-cpu-session-control \
      --replace-fail '#!/usr/bin/env python3' '#!${pkgs.python3}/bin/python3 -I' \
      --replace-fail '@core@' '${core}' \
      --replace-fail '@preview_guard@' '${guard}'
    chmod +x $out/bin/precision-scanout-cpu-session-control
  '';
  access = pkgs.writeShellScriptBin "precision-scanout-cpu-test-access" ''
    set -eu
    test "$(${pkgs.coreutils}/bin/id -u)" = 0
    test "''${SUDO_UID:-}" = 1001
    test "$#" = 0
    exec ${pkgs.systemd}/bin/systemd-run --collect \
      --unit=precision-scanout-cpu-session-test \
      --description='One approved CPU-copy session test; no GDM restart or reboot' \
      --property=Type=exec --property=Restart=no \
      --property=RuntimeDirectory=precision-scanout-cpu-session-test \
      --property=RuntimeDirectoryMode=0711 --property=RuntimeMaxSec=3600 \
      --property=TimeoutStopSec=60 \
      ${scripts}/bin/precision-scanout-cpu-session-control serve
  '';
in pkgs.symlinkJoin {
  name = "precision-scanout-cpu-session-test";
  paths = [ scripts access ];
}
