{ pkgs, candidate }:
let
  config = pkgs.writeText "precision-hdmi-session-test.json" (builtins.toJSON {
    inherit candidate;
    baseline = "/nix/store/zkvp6nbpf6swkm281sfpanvwkm2bhn3k-nixos-system-precision7560-26.05.20260611.a037402";
    old_shell_pid = 23329;
    old_shell_identity = [ "ec89b2a7-35c8-44cc-8ee9-0ccb1419e153" "465804" ];
    old_agent_pid = 24815;
    old_agent_identity = [ "ec89b2a7-35c8-44cc-8ee9-0ccb1419e153" "469484" ];
    thread = "01a09263-e6f0-7983-b528-09146e982e9f";
    codex = "/nix/store/i0p1gqyr0mq8fg76566p62lqhk4kc1bw-codex-0.153.4/bin/codex";
    kitty = "${pkgs.kitty}/bin/kitty";
    systemctl = "${pkgs.systemd}/bin/systemctl";
  });
  scripts = pkgs.runCommand "precision-hdmi-session-test-tools" {} ''
    mkdir -p $out/bin
    cp ${./session-test-control.py} $out/bin/precision-hdmi-session-control
    cp ${./session-test-resume.py} $out/bin/precision-hdmi-resume-once
    for script in $out/bin/*; do
      substituteInPlace "$script" \
        --replace-fail '#!/usr/bin/env python3' '#!${pkgs.python3}/bin/python3 -I' \
        --replace-fail '@config@' '${config}'
      chmod +x "$script"
    done
  '';
  access = pkgs.writeShellScriptBin "precision-hdmi-test-access" ''
    set -eu
    test "$(id -u)" = 0
    test "''${SUDO_UID:-}" = 1001
    test "$#" = 0
    exec ${pkgs.systemd}/bin/systemd-run --collect \
      --unit=precision-hdmi-session-test \
      --description='One approved HDMI compositor test; no reboots' \
      --property=Type=exec --property=Restart=no \
      --property=RuntimeDirectory=precision-hdmi-session-test \
      --property=RuntimeDirectoryMode=0711 --property=RuntimeMaxSec=3600 \
      --property=TimeoutStopSec=60 \
      ${scripts}/bin/precision-hdmi-session-control serve
  '';
in pkgs.symlinkJoin {
  name = "precision-hdmi-session-test";
  paths = [ scripts access ];
}
