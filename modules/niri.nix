{ config, pkgs, lib, inputs, ... }:
{   
    options = {
    niri.enable = lib.mkEnableOption "Enables niri settings";
    };


    config = lib.mkIf config.niri.enable {
        services.xserver.enable = true;
        services.xserver.displayManager.gdm.enable = true;
        
    };
}
