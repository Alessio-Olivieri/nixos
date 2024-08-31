{ config, pkgs, lib, inputs, ... }:
{   
    options = {
    gnome.enable = lib.mkEnableOption "Enables KDE Nix settings";
    };


    config = lib.mkIf config.gnome.enable {
        services.xserver.enable = true;
        services.xserver.displayManager.gdm.enable = true;
        services.xserver.desktopManager.gnome.enable = true;

        environment.systemPackages = with pkgs.gnomeExtensions; [
            blur-my-shell
            pop-shell
        ]
    };
}