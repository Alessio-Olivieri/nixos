{ config, pkgs, lib, inputs, ... }:
{   
    options = {
    gnome.enable = lib.mkEnableOption "Enables Gnome Nix settings";
    };


    config = lib.mkIf config.gnome.enable {
        services.xserver.enable = true;
        services.xserver.displayManager.gdm.enable = true;
        services.xserver.desktopManager.gnome.enable = true;

        environment.systemPackages = with pkgs.gnomeExtensions; [
            blur-my-shell
            paperwm
            gsconnect
        ];

        # environment.sessionVariables.NIXOS_OZONE_WL = "1";

        environment.gnome.excludePackages = (with pkgs; [
            gnome-tour
            epiphany # web browser
        ]) ++ (with pkgs.gnome; [
        ]);
        
    };
}