{ config, pkgs, lib, ... }:

{
  # 1. Hostname override for the new laptop
  networking.hostName = lib.mkForce "msi-laptop";

  # 2. Early boot systemd (Required for TPM auto-unlock)
  boot.initrd.systemd.enable = true;

  # 3. CoolerControl (Fan curves)
  programs.coolercontrol.enable = true;

  # 4. Limit battery charge to 80% to save lifespan
  systemd.services.battery-charge-threshold = {
      description = "Set battery charge threshold to 80%";
      wantedBy =[ "multi-user.target" "post-resume.target" ];
      after =[ "multi-user.target" "post-resume.target" ];
      path = [ pkgs.coreutils ];
      script = ''
        # Adjust BAT1 to BAT0 if necessary based on your `ls /sys/class/power_supply/`
        echo 80 > /sys/class/power_supply/BAT1/charge_control_end_threshold || true
      '';
    };

  # 5. NVIDIA Optimus (PRIME Offload)
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true; # Completely powers off GPU when idle
    open = false; # GTX 1650 requires proprietary drivers
    nvidiaSettings = true;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      
      # IMPORTANT: Run `lspci | grep -i vga` and `lspci | grep -i 3d` 
      # on the MSI to get these IDs. Update them below!
      intelBusId = "PCI:0:2:0"; 
      nvidiaBusId = "PCI:1:0:0";
    };
  };
}