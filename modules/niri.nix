{ config, pkgs, lib, inputs, ... }:
{   
    options = {
    niri.enable = lib.mkEnableOption "Enables niri settings";
    };


    config = lib.mkIf config.niri.enable {
          programs.niri.enable = true;

                    # Portals (installed & wired declaratively)
            xdg.portal = {
                enable = true;
                extraPortals = with pkgs; [
                xdg-desktop-portal-gtk
                xdg-desktop-portal-gnome
                ];
                # The file is written as /etc/xdg/xdg-desktop-portal/niri-portals.conf
                config.niri = {
                # prefer gnome for screencast, fall back to gtk for the rest
                default = [ "gnome" "gtk" ];
                # Secret portal provider:
                "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];

                # Choose ONE of the following for file pickers:

                # 1) Use Nautilus as the file chooser (GNOME ≥47 default):
                "org.freedesktop.impl.portal.FileChooser" = "nautilus";
                };
            };

            # Secret portal backend
            services.gnome.gnome-keyring.enable = true;

            # A graphical Polkit agent is required for privilege prompts.
            security.polkit.enable = true;
            # Easiest agent on NixOS if you’re not running a DE:
            security.soteria.enable = true;

            # Notification daemon
            

            # Useful bits for Wayland
            programs.dconf.enable = true;

            # X11 apps support (Steam/Discord etc.) via xwayland-satellite
            environment.systemPackages = with pkgs; [
                xwayland-satellite
                wl-clipboard
                # If you picked the Nautilus file chooser above, add:
                nautilus
            ];

            # Optional: a display manager (example: greetd + ReGreet)
            services.greetd.enable = true;
            programs.regreet.enable = true;
            services.greetd.settings.default_session.command = "${pkgs.niri}/bin/niri-session";

            # (Optional) If you don't plan on a full Xorg server, you can disable it:
            services.xserver.enable = false;

            programs.waybar = {
                enable = true;
                settings = [{
                    layer = "top";
                    position = "top";
                    modules-left   = [ "niri/workspaces" ];
                    modules-center = [ "clock" ];
                    modules-right  = [ "network" "bluetooth" "pulseaudio" "tray" ];
                    "network" = { interval = 10; };       # optional tuning
                    "bluetooth" = { };                     # works if BlueZ is running
                    "pulseaudio" = { scroll-step = 2; };   # volume control
                    "tray" = { icon-size = 18; spacing = 6; };
                }];
                # programs.waybar.style = '' /* your CSS */ '';
                };
        programs.fuzzel.enable = true;         # app launcher for Mod+D

        # Networking & Bluetooth backends
            networking.networkmanager.enable = true;

            hardware.bluetooth.enable = true;
            services.blueman.enable = true;     # optional GUI

            # Start a connection tray (optional but handy)
            systemd.user.services.nm-applet = {
            Unit = { Description = "nm-applet"; };
            Service = { ExecStart = "${pkgs.networkmanagerapplet}/bin/nm-applet --indicator"; };
            Install = { WantedBy = [ "graphical-session.target" ]; };
            };
    };
}
