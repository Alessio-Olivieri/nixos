{ pkgs, lib, config, inputs, ... }:
{

  options = {
    gnome-manager.enable = lib.mkEnableOption "Enables gnome Nix settings";
  };

  config = lib.mkIf config.gnome-manager.enable {
      dconf = {
        enable = true;
        settings = {
          "org/gnome/shell" = {
            disable-user-extensions = false; # enables user extensions
            enabled-extensions = [
              # Put UUIDs of extensions that you want to enable here.
              # If the extension you want to enable is packaged in nixpkgs,
              # you can easily get its UUID by accessing its extensionUuid
              # field (look at the following example).            
              pkgs.gnomeExtensions.paperwm.extensionUuid

              # Alternatively, you can manually pass UUID as a string.  
              # pkgs.gnomeExtensions.gsconnect.extensionUuid
              pkgs.gnomeExtensions.boost-volume.extensionUuid
              # pkgs.gnomeExtensions.bluetooth-battery-indicator.extensionUuid
              pkgs.gnomeExtensions.smile-complementary-extension.extensionUuid
              pkgs.gnomeExtensions.just-perfection.extensionUuid
              pkgs.gnomeExtensions.tophat.extensionUuid
              pkgs.gnomeExtensions.headsetcontrol.extensionUuid
              pkgs.gnomeExtensions.quick-settings-audio-panel.extensionUuid
            ];
          };
        };
    };
    home.file.".config/gtk-4.0/gtk.css".text = ''
      @import 'colors.css';
      * {
          border-radius: 0;
      }
    '';

    home.packages = with pkgs; [
      dconf2nix # dconf dump / | dconf2nix > /etc/nixos/home/modules/sub/dconf.nix
      # dconf dump /org/gnome/shell/extensions/paperwm/ | dconf2nix
      dconf-editor
      gnomeExtensions.paperwm
      gnomeExtensions.boost-volume
      gnomeExtensions.smile-complementary-extension
      gnomeExtensions.just-perfection
      gnomeExtensions.tophat
      gnomeExtensions.headsetcontrol
      pkgs.gnomeExtensions.quick-settings-audio-panel
      ];

  };

}