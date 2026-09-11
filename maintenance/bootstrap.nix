{ lib, pkgs, ... }:

{
  # Temporary: keep the reboot coordinator alive before graphical login.
  # The final maintenance generation removes this module and restores the
  # baseline (linger disabled).
  users.users.lexyo.linger = lib.mkForce true;

  services.displayManager.autoLogin = {
    enable = lib.mkForce true;
    user = "lexyo";
  };

  environment.etc."xdg/autostart/precision-gpu-maintenance.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Precision maintenance progress
    Exec=${pkgs.kitty}/bin/kitty --title "Precision maintenance progress" ${pkgs.python3}/bin/python3 ${./dashboard.py}
    OnlyShowIn=GNOME;
    X-GNOME-Autostart-enabled=true
    Terminal=false
  '';

  # Temporary, task-scoped elevation. The root-owned helper only accepts the
  # maintenance operations implemented in maintenance/root-helper.
  security.sudo.extraRules = lib.mkAfter [
    {
      users = [ "lexyo" ];
      runAs = "root";
      commands = [
        {
          command = "/var/lib/precision-gpu-maintenance/root-helper *";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  # Keep the reviewed helper synchronized after every activation.  This also
  # lets later helper improvements be deployed through the already restricted
  # rebuild entry point rather than widening sudo.
  system.activationScripts.precisionGpuMaintenanceHelper = lib.stringAfter [ "users" ] ''
    ${pkgs.coreutils}/bin/install -d -m 0755 -o root -g root /var/lib/precision-gpu-maintenance
    ${pkgs.coreutils}/bin/install -m 0755 -o root -g root ${./root-helper} /var/lib/precision-gpu-maintenance/root-helper
  '';

  # A user service cannot acquire a sleep inhibitor before graphical login on
  # this host.  Run the temporary maintenance inhibitor as root instead; this
  # module and service are removed in the final cleanup generation.
  systemd.services.precision-gpu-maintenance-inhibit = {
    description = "Temporarily inhibit sleep during approved Precision GPU maintenance";
    wantedBy = [ "multi-user.target" ];
    unitConfig = {
      StartLimitIntervalSec = 300;
      StartLimitBurst = 3;
    };
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.systemd}/bin/systemd-inhibit --what=sleep:idle --who=Precision-GPU-maintenance --why=Approved-maintenance-goal-is-active --mode=block ${pkgs.coreutils}/bin/sleep infinity";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}
