{ pkgs, ... }:

let
  userName = "lexyo";
  userUnitNames = [
    "syncthing"
    "localsearch-3"
  ];
  userUnits = map (name: "${name}.service") userUnitNames;
  userUnitArgs = builtins.concatStringsSep " " userUnits;
  acOnlyUserServices = builtins.listToAttrs (map (name: {
    inherit name;
    value = {
      overrideStrategy = "asDropin";
      unitConfig.ConditionACPower = true;
    };
  }) userUnitNames);
in
{
  systemd.user.services = acOnlyUserServices;

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

      $userctl unmask --runtime ${userUnitArgs} || true
      $userctl daemon-reload || true

      if [ "$ac_online" = "1" ]; then
        $userctl reset-failed ${userUnitArgs} || true
        $userctl start ${userUnitArgs} || true
      else
        $userctl stop ${userUnitArgs} || true
        $userctl reset-failed ${userUnitArgs} || true
      fi
    '';
  };

  services.udev.extraRules = ''
    SUBSYSTEM=="power_supply", KERNEL=="AC", TAG+="systemd", ENV{SYSTEMD_WANTS}+="battery-background-policy.service"
  '';
}
