{ pkgs, lib, config, ... }:
{
    options = {
        yazi-module.enable = lib.mkEnableOption "Enables yazi";
    };

    config = lib.mkIf config.yazi-module.enable {
          # basic configuration of yazi, please change to your own
            programs.yazi = {
                enable = true;
            };
    };
}