{ config, pkgs, lib, inputs, ... }:
{   
      options = {
        kde.enable = lib.mkEnableOption "Enables KDE Nix settings";
    };


    config = lib.mkIf config.kde.enable {
    environment.plasma6.excludePackages = [
        pkgs.kdePackages.elisa
        pkgs.kdePackages.kate
    ];
    };
}