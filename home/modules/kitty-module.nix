{ pkgs, lib, config, ... }:
{
    options = {
        kitty-module.enable = lib.mkEnableOption "Enables kitty";
    };

    config = lib.mkIf config.kitty-module.enable {
          # basic configuration of kitty, please change to your own
            programs.kitty = {
                enable = true;
                settings = {
                   confirm_os_window_close = "-1";
                   hide_window_decorations = true;
                   tab_bar_edge = "top";
                   tab_bar_style = "custom";
                };
            };
    };
}