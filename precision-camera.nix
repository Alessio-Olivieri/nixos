{ config, pkgs, inputs, lib, ... }:
{

environment.systemPackages = [
  pkgs.v4l-utils
  pkgs.linux-enable-ir-emitter
];


services.howdy = {
    enable = true;
    settings = {
      core = {
        device_path = "/dev/video2";
        ignore_closed_lids = false;
        
        # Turn confirmation BACK ON so we can see the text when it succeeds.
        no_confirmation = false; 
        
        # Keep workarounds OFF. They crash the module on NixOS.
        workaround = "off"; 
      };
      video = {
        timeout = 2;
      };
    };
  };

  # Explicitly force Howdy to be a "sufficient" bypass
  security.pam.services = {
    sudo.howdy = {
      enable = true;
      control = "sufficient";
    };
    login.howdy = {
      enable = true;
      control = "sufficient";
    };
    gdm.howdy = {
      enable = true;
      control = "sufficient";
    };
  };

  # FORCE Howdy to execute BEFORE the standard password prompt in the PAM stack
  security.pam.services.sudo.rules.auth.howdy.order = config.security.pam.services.sudo.rules.auth.unix.order - 10;
  security.pam.services.login.rules.auth.howdy.order = config.security.pam.services.login.rules.auth.unix.order - 10;
  security.pam.services.gdm.rules.auth.howdy.order = config.security.pam.services.gdm.rules.auth.unix.order - 10;
  boot.extraModprobeConfig = ''
  options uvcvideo nodrop=1
  '';
}