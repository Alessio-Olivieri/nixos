{ config, pkgs, lib, inputs, ... }:
{   
      options = {
        kde.enable = lib.mkEnableOption "Enables KDE Nix settings";
    };


    config = lib.mkIf config.kde.enable {
    
    services.xserver.displayManager.lightdm.enable = true; 
    services.desktopManager.plasma6.enable = true;
    environment.plasma6.excludePackages = [
        pkgs.kdePackages.elisa
        pkgs.kdePackages.kate
    ];

    environment.systemPackages = with pkgs; [
        libsForQt5.polonium
    ];


    };
}