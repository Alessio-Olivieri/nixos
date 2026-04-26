{ config, pkgs, lib, ... }:

{
  # 1. Hostname override for the new laptop
  networking.hostName = lib.mkForce "msi-laptop";

  # KEEP THESE: They ensure the GPU is completely idle so we CAN rip it out safely.
  boot.kernelParams =[ 
    "nvidia_drm.fbdev=0" 
    "nvidia.NVreg_EnableGpuFirmware=0"
  ];

  environment.variables = {
    "__EGL_VENDOR_LIBRARY_FILENAMES" = "/run/opengl-driver/share/glvnd/egl_vendor.d/50_mesa.json";
  };

  # =======================================================================
  # THE NUCLEAR OPTION: GPU TOGGLE SCRIPTS
  # =======================================================================
  environment.systemPackages = with pkgs;[
  (writeShellScriptBin "gpu-off" ''
    echo "Disconnecting NVIDIA GPU..."
    # Unload drivers gracefully (Order matters!)
    sudo rmmod nvidia_drm nvidia_modeset nvidia_uvm nvidia || echo "Modules already unloaded"
    
    # Remove the device from the PCI bus (Matches your 0000:01:00.0)
    if [ -d "/sys/bus/pci/devices/0000:01:00.0" ]; then
      echo 1 | sudo tee /sys/bus/pci/devices/0000:01:00.0/remove > /dev/null
      echo "✅ GPU is physically disconnected. Battery saved!"
    else
      echo "✅ GPU is already disconnected."
    fi
  '')

    (writeShellScriptBin "gpu-on" ''
      echo "Waking NVIDIA GPU..."
      # Rescan the PCI bus to find the GPU again
      echo 1 | sudo tee /sys/bus/pci/rescan > /dev/null
      
      # Give the kernel a second to initialize the PCI lane
      sleep 1
      
      # Reload the drivers
      sudo modprobe nvidia_drm
      echo "🎮 GPU is ready for gaming/AI!"
    '')
  ];

  # OPTIONAL: Uncomment this block to run the kill-switch automatically on boot!
  systemd.services.disable-nvidia-on-boot = {
    description = "Disable NVIDIA GPU on boot to save battery";
    wantedBy =[ "multi-user.target" ];
    after = [ "systemd-logind.service" "display-manager.service" ];
    script = ''
      ${pkgs.kmod}/bin/rmmod nvidia_drm nvidia_modeset nvidia_uvm nvidia || true
      if [ -d "/sys/bus/pci/devices/0000:01:00.0" ]; then
        echo 1 > /sys/bus/pci/devices/0000:01:00.0/remove
      fi
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };
  # =======================================================================

  # 3. HIDE THE DEVICE FROM GNOME
  services.udev.extraRules = ''
    ACTION=="add|change", SUBSYSTEM=="drm", KERNEL=="card*", DRIVERS=="nvidia", TAG-="seat", TAG-="master-of-seat", ENV{MUTTER_HINTS}="ignore-device"
  '';

  services.switcherooControl.enable = false;

  # --- Keep the rest of your config exactly as it was below ---
  boot.initrd.systemd.enable = true;
  programs.coolercontrol.enable = true;

  # 4. Limit battery charge to 80% to save lifespan
  systemd.services.battery-charge-threshold = {
      description = "Set battery charge threshold to 80%";
      wantedBy =[ "multi-user.target" "post-resume.target" ];
      after =[ "multi-user.target" "post-resume.target" ];
      path = [ pkgs.coreutils ];
      script = ''
        echo 80 > /sys/class/power_supply/BAT1/charge_control_end_threshold || true
      '';
    };

  # 5. NVIDIA Optimus (PRIME Offload)
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true; 
    open = false; 
    nvidiaSettings = true;
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      intelBusId = "PCI:0:2:0"; 
      nvidiaBusId = "PCI:1:0:0";
    };
  };
}