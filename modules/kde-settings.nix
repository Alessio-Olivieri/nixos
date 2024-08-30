{ config, pkgs, lib, config, inputs, ... }:
{
    config = lib.mkIf config.kde-manager.enable {
    environment.plasma6.excludePackages = [
        pkgs.kdePackages.elisa
        pkgs.kdePackages.kate
    ];
    };
}