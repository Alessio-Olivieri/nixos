{ pkgs, lib, config, ... }:
{
    options = {
        git-module.enable = lib.mkEnableOption "Enables git";
    };

    config = lib.mkIf config.git-module.enable {
          # basic configuration of git, please change to your own
            programs.git = {
                enable = true;
                userName = "Alessio-Olivieri";
                userEmail = "lexyo.2002@gmial.com";
            };
    };
}