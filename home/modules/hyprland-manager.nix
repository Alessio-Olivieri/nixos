{ pkgs, lib, config, ... }:
{
    options = {
        hyprland-manager.enable = lib.mkEnableOption "Enables hyprland";
    };

    config = lib.mkIf config.hyprland-manager.enable {
        wayland.windowManager.hyprland = {
            enable = true;
            xwayland.enable = true;
            systemd.enable = true; # startup

            settings = {
                decoration = {
                shadow_offset = "0 5";
                "col.shadow" = "rgba(00000099)";
                };

                "$mod" = "SUPER";

                bindm = [
                # mouse movements
                "$mod, mouse:272, movewindow"
                "$mod, mouse:273, resizewindow"
                "$mod ALT, mouse:272, resizewindow"
                ];
            };
            
        };
        
        home.packages = with pkgs; [
            (pkgs.waybar.overrideAttrs (oldAttrs: {
                mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
            })
            )
            # notifications
            mako 
            libnotify
            
            rofi-wayland
        ];
    };
} 