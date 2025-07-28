{ config, pkgs, lib, inputs, ... }:
{   
        nix.settings.experimental-features = [ "nix-command" "flakes" ];
        nixpkgs.config.allowUnfree = true;


        # Bootloader.
        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;
        boot.loader.grub.configurationLimit = 15;

        nix.gc = {
                automatic = true;
                dates = "weekly";
                options = "--delete-older-than 30d";
            };

        zramSwap.enable = true;  

        services.pulseaudio.enable = false;
        security.rtkit.enable = true;
        services.pipewire = {
            enable = true;
            alsa.enable = true;
            alsa.support32Bit = true;
            pulse.enable = true;
            audio.enable = true;
            # If you want to use JACK applications, uncomment this
            # jack.enable = true;

            # use the example session manager (no others are packaged yet so this is enabled by default,
            # no need to redefine it in your config for now)
            #media-session.enable = true;
        };

        hardware.bluetooth.enable = true; # enables support for Bluetooth
        hardware.bluetooth.settings = {
            General = {
                Experimental = true; # To show the battery of connected devices
            };
        };
}
 
 
 
