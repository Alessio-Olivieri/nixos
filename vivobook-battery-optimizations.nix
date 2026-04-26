{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [tlp powertop];

  # 1. DISABLE Powertop's auto-tuning. 
  # It conflicts with TLP and tries to force ALL devices to sleep, which we don't want.
  powerManagement.powertop.enable = false;

  # boot.kernelParams = [ "usbcore.autosuspend=120" ]; <--- DELETE OR COMMENT THIS LINE

  # Disable GNOME's power management
  services.power-profiles-daemon.enable = false;
  
  # Better scheduling for CPU cycles
  services.system76-scheduler.settings.cfsProfiles.enable = true;
  
  # Enable thermald (only necessary if on Intel CPUs)
  services.thermald.enable = false;

  services.tlp = {
    enable = true;
    settings = {
      USB_AUTOSUSPEND = 1;
      
# Bluetooth card can't resume from suspend
      USB_DENYLIST = "13d3:3530"; 

      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_DRIVER_OPMODE_ON_AC = "guided";
      CPU_DRIVER_OPMODE_ON_BAT = "active";
      MEM_SLEEP_ON_AC="s2idle";
      MEM_SLEEP_ON_BAT="deep";
    };
  };
}