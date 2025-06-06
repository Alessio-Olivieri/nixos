{ pkgs, lib, config, ... }:
{
    options = {
        kitty-module.enable = lib.mkEnableOption "Enables kitty";
    };

    config = lib.mkIf config.kitty-module.enable {
          # basic configuration of kitty, please change to your own

        xdg.configFile = {
            "kitty/dark-theme.auto.conf".source = ./sub/kitty-themes/dark-theme.auto.conf;
            "kitty/light-theme.auto.conf".source = ./sub/kitty-themes/light-theme.auto.conf;
            "kitty/no-preference-theme.auto.conf".source = ./sub/kitty-themes/no-preference-theme.auto.conf;
          };
            programs.kitty = {
                enable = true;
                settings = {
                   confirm_os_window_close = "-1";
                   hide_window_decorations = true;
                   tab_bar_edge = "top";
                   tab_bar_style = "custom";
                };
                font = {
                    name = "JetBrainsMono Nerd Font";
                    size = 10;
                };
            };
    };
}