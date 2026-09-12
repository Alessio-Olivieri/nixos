{ pkgs }:
let
  config = pkgs.writeText "precision-lifecycle-session-test.json" (builtins.toJSON {
    candidate = "/nix/store/bd7sxq4vbbya1bhy9q1jlzprfk0qq78v-nixos-system-precision7560-26.05.20260611.a037402";
    baseline = "/nix/store/xh1bs21slny2252ijyjj55w5m3di6rsc-nixos-system-precision7560-26.05.20260611.a037402";
    saved = "/nix/store/xkga9k4w11g6yzbzp0pgwgsfg7p1c5cw-nixos-system-precision7560-26.05.20260611.a037402";
    old_shell_pid = 192901;
    old_shell_identity = [ "ec89b2a7-35c8-44cc-8ee9-0ccb1419e153" "1824213" ];
    old_agent_pid = 193945;
    old_agent_identity = [ "ec89b2a7-35c8-44cc-8ee9-0ccb1419e153" "1825062" ];
    runtime = "/run/precision-lifecycle-session-test";
    record = "/var/lib/precision-lifecycle-session-test-20260912";
    resume_state = "/home/lexyo/.local/state/precision-lifecycle-session-test-20260912";
    restart_gdm = false;
    systemctl = "${pkgs.systemd}/bin/systemctl";
    quit = "${pkgs.gnome-session}/bin/gnome-session-quit";
    codex = "/nix/store/i0p1gqyr0mq8fg76566p62lqhk4kc1bw-codex-0.153.4/bin/codex";
    kitty = "${pkgs.kitty}/bin/kitty";
    thread = "01a09263-e6f0-7983-b528-09146e982e9f";
  });
  core = pkgs.writeText "precision-lifecycle-session-core.py"
    (builtins.replaceStrings [ "@config@" ] [ "${config}" ] (builtins.readFile ./session-test-control.py));
  guard = pkgs.writeText "precision-lifecycle-preview-guard.py"
    (builtins.replaceStrings [ "@config@" ] [ "${config}" ] (builtins.readFile ./apply-component-update.py));
  control = pkgs.runCommand "precision-lifecycle-session-control" {} ''
    mkdir -p $out/bin
    cp ${./scanout-test-control.py} $out/bin/precision-lifecycle-session-control
    substituteInPlace $out/bin/precision-lifecycle-session-control \
      --replace-fail '#!/usr/bin/env python3' '#!${pkgs.python3}/bin/python3 -I' \
      --replace-fail '@core@' '${core}' --replace-fail '@preview_guard@' '${guard}'
    chmod +x $out/bin/precision-lifecycle-session-control
  '';
  actions = pkgs.runCommand "precision-lifecycle-session-actions" {} ''
    mkdir -p $out/bin
    cp ${./lifecycle-session-actions.py} $out/bin/precision-lifecycle-session-actions
    substituteInPlace $out/bin/precision-lifecycle-session-actions \
      --replace-fail '#!/usr/bin/env python3' '#!${pkgs.python3}/bin/python3 -I' \
      --replace-fail '@config@' '${config}' \
      --replace-fail '@control@' '${control}/bin/precision-lifecycle-session-control'
    chmod +x $out/bin/precision-lifecycle-session-actions
  '';
  access = pkgs.writeShellScriptBin "precision-lifecycle-test-access" ''
    set -eu
    test "$(${pkgs.coreutils}/bin/id -u)" = 0
    test "''${SUDO_UID:-}" = 1001
    test "$#" = 0
    exec ${pkgs.systemd}/bin/systemd-run --collect \
      --unit=precision-lifecycle-session-test \
      --description='One approved lifecycle session test; no GDM restart or reboot' \
      --property=Type=exec --property=Restart=no \
      --property=RuntimeDirectory=precision-lifecycle-session-test \
      --property=RuntimeDirectoryMode=0711 --property=RuntimeMaxSec=3600 \
      --property=TimeoutStopSec=60 \
      ${control}/bin/precision-lifecycle-session-control serve
  '';
in pkgs.symlinkJoin {
  name = "precision-lifecycle-session-test";
  paths = [ control actions access ];
}
