{ pkgs, lib, config, ... }:
let
  # --- Theme Definitions ---
  catppuccin-mocha = pkgs.catppuccin-gtk.override {
    accents = [ "lavender" ];
    size = "standard";
    variant = "mocha";
  };

  catppuccin-latte = pkgs.catppuccin-gtk.override {
    accents = [ "lavender" ];
    size = "standard";
    variant = "latte";
  };

  # Exact folder names
  mochaName = "catppuccin-mocha-lavender-standard";
  latteName = "catppuccin-latte-lavender-standard";

  # Paths
  mochaGtk4 = "${catppuccin-mocha}/share/themes/${mochaName}/gtk-4.0";
  latteGtk4 = "${catppuccin-latte}/share/themes/${latteName}/gtk-4.0";

  # --- Updated Script ---
  switch-theme = pkgs.writeShellScriptBin "switch-theme" ''
    MODE=$1
    GTK4_DIR="$HOME/.config/gtk-4.0"
    mkdir -p "$GTK4_DIR"

    apply_theme() {
      local src="$1"
      rm -rf "$GTK4_DIR/assets" "$GTK4_DIR/gtk.css" "$GTK4_DIR/gtk-dark.css"
      cp -rL "$src/assets" "$GTK4_DIR/assets"
      cp -L "$src/gtk.css" "$GTK4_DIR/gtk.css"
      cp -L "$src/gtk-dark.css" "$GTK4_DIR/gtk-dark.css"
    }

    # Force kill apps to make them reload assets
    restart_apps() {
       # 'killall' is often more effective than pkill for exact names
       ${pkgs.psmisc}/bin/killall nautilus || true
       ${pkgs.psmisc}/bin/killall gnome-calculator || true
    }

    if [ "$MODE" == "dark" ]; then
      apply_theme "${mochaGtk4}"
      
      # Cursor switching disabled to prevent invisible mouse
      # ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface cursor-theme 'Catppuccin-Mocha-Lavender-Cursors'
      
      restart_apps
      sleep 0.5  # Increased sleep slightly to ensure apps close
      
      ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
      
    else
      apply_theme "${latteGtk4}"
      
      # Cursor switching disabled
      # ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface cursor-theme 'Catppuccin-Latte-Lavender-Cursors'
      
      restart_apps
      sleep 0.5

      ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface color-scheme 'default'
    fi
  '';
in
{
  options = {
    gnome-manager.enable = lib.mkEnableOption "Enables gnome Nix settings";
  };

  config = lib.mkIf config.gnome-manager.enable {
    fonts.fontconfig.enable = true;

    home.packages = with pkgs; [
      adwaita-icon-theme
      gnome-themes-extra
      cantarell-fonts          
      papirus-icon-theme
      catppuccin-mocha
      catppuccin-latte
      # Removed cursor packages since we are using default to fix the arrow
      
      switch-theme
      dconf2nix
      dconf-editor
      
      # Extensions
      gnomeExtensions.paperwm
      gnomeExtensions.night-theme-switcher
      gnomeExtensions.user-themes 
      gnomeExtensions.boost-volume
      gnomeExtensions.smile-complementary-extension
      gnomeExtensions.just-perfection
      gnomeExtensions.tophat
      gnomeExtensions.headsetcontrol
      gnomeExtensions.quick-settings-audio-panel
      gnomeExtensions.appindicator #Needed for jdownloader
      gnomeExtensions.gsconnect
    ];

    dconf = {
      enable = true;
      settings = {
        "org/gnome/shell" = {
          disable-user-extensions = false;
          enabled-extensions = [
              "nightthemeswitcher@romainvigier.fr"
              "user-theme@gnome-shell-extensions.gcampax.github.com"
              "paperwm@paperwm.github.com"
              pkgs.gnomeExtensions.paperwm.extensionUuid
              pkgs.gnomeExtensions.boost-volume.extensionUuid
              pkgs.gnomeExtensions.smile-complementary-extension.extensionUuid
              pkgs.gnomeExtensions.just-perfection.extensionUuid
              pkgs.gnomeExtensions.tophat.extensionUuid
              pkgs.gnomeExtensions.headsetcontrol.extensionUuid
              pkgs.gnomeExtensions.quick-settings-audio-panel.extensionUuid
              pkgs.gnomeExtensions.night-theme-switcher.extensionUuid 
              pkgs.gnomeExtensions.appindicator.extensionUuid 
              pkgs.gnomeExtensions.gsconnect.extensionUuid

          ];
        };
        
        # Reset Shell Theme to Default (Adwaita) to fix panel overlaps/missing icons
        "org/gnome/shell/extensions/user-theme" = {
          name = "";
        };

        "org/gnome/shell/extensions/nightthemeswitcher/time" = {
          manual-schedule = true;
          nightthemeswitcher-ondemand-keybinding = [ "<Shift><Super>t" ];
        };

        # Legacy Apps
        "org/gnome/shell/extensions/nightthemeswitcher/gtk-variants" = {
          enabled = true;
          day = latteName;
          night = mochaName;
        };

        # Disable Shell Variants (Prevents broken theme from loading)
        "org/gnome/shell/extensions/nightthemeswitcher/shell-variants" = {
          enabled = false;
        };

        # Commands (Now force kills Calculator)
        "org/gnome/shell/extensions/nightthemeswitcher/commands" = {
          enabled = true;
          sunrise = "${switch-theme}/bin/switch-theme light";
          sunset = "${switch-theme}/bin/switch-theme dark";
        };

        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          accent-color = "purple";
          enable-hot-corners = false;
          show-battery-percentage = true;
          # cursor-theme removed! This ensures the arrow (mouse) is always visible.
          icon-theme = "Papirus-Dark"; 
        };
      };
    };
  };
}