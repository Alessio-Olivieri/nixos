{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [tlp powertop];
  # Enable powertop
  powerManagement.powertop.enable = true;
  boot.kernelParams = [ "usbcore.autosuspend=120" ];

  # Disable GNOMEs power management
  services.power-profiles-daemon.enable = false;
  # Better scheduling for CPU cycles - thanks System76!!!
  services.system76-scheduler.settings.cfsProfiles.enable = true;
  # Enable thermald (only necessary if on Intel CPUs)
  services.thermald.enable = false;

  # Enable TLP (better than gnomes internal power manager)
  services.tlp = {
    enable = true;
    settings = {
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_DRIVER_OPMODE_ON_AC = "guided"; #the processor chooses the operating frequencies within the hardware’s limits, based on the current workload.
      CPU_DRIVER_OPMODE_ON_BAT = "active"; #the processor selects the operating frequencies within the hardware’s min/max limits, based on the energy performance preference
      MEM_SLEEP_ON_AC="s2idle";
      MEM_SLEEP_ON_BAT="deep";
    };
  };
}