{ pkgs, lib, config, ... }:
{
    options = {
        ghostty-module.enable = lib.mkEnableOption "Enables ghostty";
    };

    config = lib.mkIf config.ghostty-module.enable {
        programs.ghostty = {
            enable = true;
        };
    };
}