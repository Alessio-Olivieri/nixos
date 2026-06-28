{ pkgs, ... }:

let
  userName = "lexyo";
  userUnits = [
    "syncthing.service"
    "localsearch-3.service"
  ];
  userUnitArgs = builtins.concatStringsSep " " userUnits;
in
{
  systemd.services.battery-background-policy = {
    description = "Stop background user services while on battery";
    after = [ "systemd-machined.service" ];
    wantedBy = [ "multi-user.target" ];

    path = [
      pkgs.coreutils
      pkgs.systemd
    ];

    serviceConfig = {
      Type = "oneshot";
    };

    script = ''
      ac_online="$(cat /sys/class/power_supply/AC/online 2>/dev/null || echo 1)"

      if ! systemctl --user -M ${userName}@.host is-active dbus-broker.service >/dev/null 2>&1; then
        exit 0
      fi

      if [ "$ac_online" = "1" ]; then
        systemctl --user -M ${userName}@.host unmask --runtime ${userUnitArgs} || true
        systemctl --user -M ${userName}@.host start ${userUnitArgs} || true
      else
        systemctl --user -M ${userName}@.host stop ${userUnitArgs} || true
        systemctl --user -M ${userName}@.host mask --runtime ${userUnitArgs} || true
      fi
    '';
  };

  services.udev.extraRules = ''
    SUBSYSTEM=="power_supply", KERNEL=="AC", TAG+="systemd", ENV{SYSTEMD_WANTS}+="battery-background-policy.service"
  '';
}
