{ pkgs, lib, config, ... }:
{
    options = {
        hyprland-manager.enable = lib.mkEnableOption "Enables hyprland";
    };

    config = lib.mkIf config.hyprland-manager.enable {
        wayland.windowManager.hyprland.settings = {
            input = {
                kb_layout = "it";
            };
            
        };
          home.file."~/.config/hypr/hyprland.conf".text = ''
        decoration {
        shadow_offset = 0 5
        col.shadow = rgba(00000099)
        }

        input:kb_layout = it

        $mod = SUPER

        bind = ,XF86AudioLowerVolume, exec, pactl -- set-sink-volume 0 -10%
        bind = ,XF86AudioRaiseVolume, exec, pactl -- set-sink-volume 0 +10%
        bind = ,XF86AudioMute, exec, pactl -- set-sink-mute 0 toggle
        bind = ,XF86AudioMicMute, exec, pactl -- set-source-mute 0 toggle
        bind = ,XF86MonBrightnessDown, exec, brightnessctl s 10%-
        bind = ,XF86MonBrightnessUp, exec, brightnessctl s +10%
    '';
        
        home.packages = with pkgs; [
            waybar
            hyprshot
            hyprcursor

            networkmanager
            networkmanagerapplet

            # notifications
            mako 
            libnotify
            
            rofi-wayland
            kitty

            grimblast
            brightnessctl
        ];
    };
} 
