{ pkgs, lib, config, ... }:
{
    options = {
        steam-module.enable = lib.mkEnableOption "Enables steam";
    };

    config = lib.mkIf config.steam-module.enable {
    };
}