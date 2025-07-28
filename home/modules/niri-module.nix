{ pkgs, lib, config, ... }:
{
    options = {
        niri-module.enable = lib.mkEnableOption "Enables niri";
    };

    config = lib.mkIf config.niri-module.enable {
        home.packages = with pkgs;[
            networkmanager
            networkmanagerapplet
        ];
    };
}