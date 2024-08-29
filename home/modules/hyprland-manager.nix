{ pkgs, lib, config, ... }:
{
    options = {
        hyprland-manager.enable = lib.mkEnableOption "Enables hyprland";
    };

    config = lib.mkIf config.hyprland-manager.enable {
        wayland.windowManager.hyprland = {
            enable = true;
        };
    };
}