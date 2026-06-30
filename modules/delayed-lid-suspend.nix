{ pkgs, ... }:

{
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
  };

  services.acpid = {
    enable = true;
    lidEventCommands = ''
    lid_state="$(${pkgs.coreutils}/bin/cat /proc/acpi/button/lid/LID0/state 2>/dev/null || true)"

    case "$lid_state" in
      *closed*)
        ${pkgs.systemd}/bin/systemctl restart delayed-lid-hibernate.service
        ;;
      *)
        ${pkgs.systemd}/bin/systemctl stop delayed-lid-hibernate.service
        ;;
    esac
    '';
  };

  systemd.services.delayed-lid-hibernate = {
    description = "Hibernate after the lid stays closed for 20 seconds";

    path = [
      pkgs.coreutils
      pkgs.gnugrep
      pkgs.systemd
    ];

    serviceConfig = {
      Type = "oneshot";
      TimeoutStopSec = "1s";
    };

    script = ''
      sleep 20

      if grep -q closed /proc/acpi/button/lid/LID0/state; then
        systemctl hibernate
      fi
    '';
  };
}
