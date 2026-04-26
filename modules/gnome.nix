{ config, pkgs, lib, inputs, ... }:
{   
    options = {
    gnome.enable = lib.mkEnableOption "Enables Gnome Nix settings";
    };


    config = lib.mkIf config.gnome.enable {
        services.xserver.displayManager.gdm.enable = true;
        services.xserver.desktopManager.gnome.enable = true;

        environment.gnome.excludePackages = (with pkgs; [
            # baobab # diskmanager
            # decibels #audioplayer
            # totem #videoplayer
            # loupe imageplager
            # nautilus
            # snapshot
            #gnome-calculator
            #gnome-calendar
            # gnome-font-viewer
            # gnome-logs
            epiphany 
            gnome-text-editor
            gnome-characters
            gnome-clocks
            gnome-console
            # gnome-contacts
            gnome-maps
            gnome-music
            # gnome-system-monitor
            # gnome-weather
            # gnome-connections
            simple-scan
            yelp


            gnome-tour
            xterm
            gedit
            evince
            seahorse
            geary
            #gnome-font-viewer
            gnome-characters
        ]) ++ (with pkgs.gnome; [
        ]);
        
    };
}
