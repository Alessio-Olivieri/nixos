{ pkgs, lib, config, ... }:
{
    options = {
        kitty-module.enable = lib.mkEnableOption "Enables kitty";
    };

    config = lib.mkIf config.kitty-module.enable {
          # basic configuration of kitty, please change to your own

        xdg.configFile = {
            "kitty/dark-theme.auto.conf".source = ./submodules/kitty-themes/dark-theme.auto.conf;
            "kitty/light-theme.auto.conf".source = ./submodules/kitty-themes/light-theme.auto.conf;
            "kitty/no-preference-theme.auto.conf".source = ./submodules/kitty-themes/no-preference-theme.auto.conf;
          };
            programs.kitty = {
                enable = true;
                settings = {
                #     confirm_os_window_close = "-1";
                    hide_window_decorations = true;
                    tab_bar_style = "powerline";
                    tab_powerline_style = "round";
                    notify_on_cmd_finish = "invisible 20";
                    background_opacity = 0.9;
                    scrollback_lines = 1000000;
                    copy_on_select = "yes";
                #     tab_bar_edge = "top";
                #     tab_bar_style = "custom";
                #     remember_window_size = "yes";
                #     initial_window_width = 640;
                #     initial_window_height = 400;
                #     #mouse
                #     mouse_hide_wait = 3;
                    
                };
                font = {
                    name = "JetBrainsMono Nerd Font";
                    size = 10;
                };
            };
    };
}