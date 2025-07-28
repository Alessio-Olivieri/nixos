{ pkgs, lib, config, ... }:
{
    options = {
        niri-module.enable = lib.mkEnableOption "Enables niri";
    };

    config = lib.mkIf config.niri-module.enable {
        xdg.configFile."sub/niri-config.kdl".source = ./sub/niri-config.kdl;
    };
}


