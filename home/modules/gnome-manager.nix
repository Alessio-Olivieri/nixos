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
  mochaTheme = "${catppuccin-mocha}/share/themes/${mochaName}";
  latteTheme = "${catppuccin-latte}/share/themes/${latteName}";
  mochaGtk3 = "${mochaTheme}/gtk-3.0";
  latteGtk3 = "${latteTheme}/gtk-3.0";
  mochaGtk4 = "${mochaTheme}/gtk-4.0";
  latteGtk4 = "${latteTheme}/gtk-4.0";

  # --- Updated Script ---
  switch-theme = pkgs.writeShellScriptBin "switch-theme" ''
    set -euo pipefail

    MODE=''${1:?Usage: switch-theme dark|light}
    GTK3_DIR="$HOME/.config/gtk-3.0"
    GTK4_DIR="$HOME/.config/gtk-4.0"
    mkdir -p "$GTK3_DIR"
    mkdir -p "$GTK4_DIR"

    prepare_dir() {
      local dir="$1"
      chmod -R u+w "$dir/assets" "$dir/gtk.css" "$dir/gtk-dark.css" 2>/dev/null || true
    }

    keep_writable() {
      local dir="$1"
      chmod -R u+w "$dir/assets" "$dir/gtk.css" "$dir/gtk-dark.css" 2>/dev/null || true
    }

    apply_theme() {
      local gtk3_src="$1"
      local gtk4_src="$2"
      local theme_name="$3"
      local prefer_dark="$4"

      prepare_dir "$GTK3_DIR"
      rm -rf "$GTK3_DIR/assets" "$GTK3_DIR/gtk.css" "$GTK3_DIR/gtk-dark.css"
      cp -rL "$gtk3_src/assets" "$GTK3_DIR/assets"
      cp -L "$gtk3_src/gtk.css" "$GTK3_DIR/gtk.css"
      cp -L "$gtk3_src/gtk-dark.css" "$GTK3_DIR/gtk-dark.css"
      cat > "$GTK3_DIR/settings.ini" <<EOF
[Settings]
gtk-theme-name=$theme_name
gtk-application-prefer-dark-theme=$prefer_dark
EOF
      keep_writable "$GTK3_DIR"

      prepare_dir "$GTK4_DIR"
      rm -rf "$GTK4_DIR/assets" "$GTK4_DIR/gtk.css" "$GTK4_DIR/gtk-dark.css"
      cp -rL "$gtk4_src/assets" "$GTK4_DIR/assets"
      cp -L "$gtk4_src/gtk.css" "$GTK4_DIR/gtk.css"
      cp -L "$gtk4_src/gtk-dark.css" "$GTK4_DIR/gtk-dark.css"
      keep_writable "$GTK4_DIR"
    }

    # Force kill apps to make them reload assets
    restart_apps() {
       # 'killall' is often more effective than pkill for exact names
       ${pkgs.psmisc}/bin/killall nautilus || true
       ${pkgs.psmisc}/bin/killall gnome-calculator || true
    }

    if [ "$MODE" == "dark" ]; then
      apply_theme "${mochaGtk3}" "${mochaGtk4}" "${mochaName}" "1"
      
      # Cursor switching disabled to prevent invisible mouse
      # ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface cursor-theme 'Catppuccin-Mocha-Lavender-Cursors'
      
      restart_apps
      sleep 0.5  # Increased sleep slightly to ensure apps close
      
      ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface gtk-theme '${mochaName}'
      ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
      
    else
      apply_theme "${latteGtk3}" "${latteGtk4}" "${latteName}" "0"
      
      # Cursor switching disabled
      # ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface cursor-theme 'Catppuccin-Latte-Lavender-Cursors'
      
      restart_apps
      sleep 0.5

      ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface gtk-theme '${latteName}'
      ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface color-scheme 'default'
    fi
  '';

  batteryHealthChargingPatched = pkgs.gnomeExtensions.battery-health-charging.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      # Replace hardcoded /usr/local/bin path with NixOS system path
      substituteInPlace lib/driver.js \
        --replace-fail '/usr/local/bin/batteryhealthchargingctl-''${user}' \
                       '/run/current-system/sw/bin/batteryhealthchargingctl' \
        --replace-fail 'const [status] = await execCheck(argv);' \
                       'const [status] = [exitCode.SUCCESS];'
    '';
  });

    overlap-shell-theme = pkgs.stdenv.mkDerivation {
    name = "overlap-shell-theme";
    src = pkgs.emptyDirectory;
    installPhase = ''
      mkdir -p $out/share/themes/OverlapShell/gnome-shell
      cat > $out/share/themes/OverlapShell/gnome-shell/gnome-shell.css << 'EOF'
      @import url("resource:///org/gnome/shell/theme/gnome-shell.css");

      /* This is the magic line that lets windows overlap the panel area */
      #panelBox {
        height: 0px !important;
      }

      /* Pull the panel back into view (adjust the 23px if your JustPerfection panel-size is different) */
      #panel {
        margin-top: -23px !important; 
      }
      EOF
    '';
  };
  
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
      # gnomeExtensions.tophat
      gnomeExtensions.headsetcontrol
      gnomeExtensions.quick-settings-audio-panel
      gnomeExtensions.appindicator #Needed for jdownloader
      gnomeExtensions.gsconnect
      gnomeExtensions.blur-my-shell
      gnomeExtensions.caffeine
      batteryHealthChargingPatched
    ];

    xdg.dataFile."gnome-shell/extensions/${batteryHealthChargingPatched.extensionUuid}" = {
      source = "${batteryHealthChargingPatched}/share/gnome-shell/extensions/${batteryHealthChargingPatched.extensionUuid}";
      force = true;
    };

    xdg.dataFile."themes/${mochaName}".source = mochaTheme;
    xdg.dataFile."themes/${latteName}".source = latteTheme;

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
              # pkgs.gnomeExtensions.tophat.extensionUuid
              pkgs.gnomeExtensions.headsetcontrol.extensionUuid
              pkgs.gnomeExtensions.quick-settings-audio-panel.extensionUuid
              pkgs.gnomeExtensions.night-theme-switcher.extensionUuid 
              pkgs.gnomeExtensions.appindicator.extensionUuid 
              pkgs.gnomeExtensions.gsconnect.extensionUuid
              pkgs.gnomeExtensions.blur-my-shell.extensionUuid
              batteryHealthChargingPatched.extensionUuid
              pkgs.gnomeExtensions.caffeine.extensionUuid
          ];
        };

            # Stop GNOME from indexing files and draining battery when unplugged
        "org/freedesktop/Tracker3/Miner/Files" = {
          index-on-battery = false;
        };
        
        # --- THE MAGIC FIX: TELL THE EXTENSION POLKIT IS ALREADY INSTALLED ---
        "org/gnome/shell/extensions/Battery-Health-Charging" = {
          polkit-status = "installed";
          configuration-mode = "sysfs";
          charging-mode = "bal";
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
