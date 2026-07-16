{ pkgs, ... }:

let
  userName = "lexyo";
  batteryStoppedUserUnitNames = [
    "syncthing"
    "localsearch-3"
  ];
  acStartedUserUnitNames = [
    "syncthing"
  ];
  batteryStoppedUserUnits = map (name: "${name}.service") batteryStoppedUserUnitNames;
  acStartedUserUnits = map (name: "${name}.service") acStartedUserUnitNames;
  batteryStoppedUserUnitArgs = builtins.concatStringsSep " " batteryStoppedUserUnits;
  acStartedUserUnitArgs = builtins.concatStringsSep " " acStartedUserUnits;
  acOnlyUserServices = builtins.listToAttrs (map (name: {
    inherit name;
    value = {
      overrideStrategy = "asDropin";
      unitConfig.ConditionACPower = true;
    };
  }) batteryStoppedUserUnitNames);
in
{
  systemd.user.services = acOnlyUserServices // {
    localsearch-3 = {
      overrideStrategy = "asDropin";
      unitConfig.ConditionACPower = true;
      serviceConfig = {
        CPUQuota = "25%";
        CPUWeight = 10;
        IOSchedulingClass = "idle";
        Nice = 19;
      };
    };
  };

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
      userctl="systemctl --user -M ${userName}@.host"
      ac_online="$(cat /sys/class/power_supply/AC/online 2>/dev/null || echo 1)"

      if ! $userctl is-active dbus-broker.service >/dev/null 2>&1; then
        exit 0
      fi

      $userctl unmask --runtime ${batteryStoppedUserUnitArgs} || true
      $userctl daemon-reload || true

      if [ "$ac_online" = "1" ]; then
        $userctl reset-failed ${batteryStoppedUserUnitArgs} || true
        $userctl start ${acStartedUserUnitArgs} || true
      else
        $userctl stop ${batteryStoppedUserUnitArgs} || true
        $userctl reset-failed ${batteryStoppedUserUnitArgs} || true
      fi
    '';
  };

  services.udev.extraRules = ''
    SUBSYSTEM=="power_supply", KERNEL=="AC", TAG+="systemd", ENV{SYSTEMD_WANTS}+="battery-background-policy.service"
  '';
}
