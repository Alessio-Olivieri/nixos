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
              # ...
              pkgs.gnomeExtensions.smile-complementary-extension.extensionUuid
            ];
          };
        };
    };
    home.packages = with pkgs; [
      dconf2nix # dconf dump / | dconf2nix > /etc/nixos/home/modules/sub/dconf.nix
      # dconf dump /org/gnome/shell/extensions/paperwm/ | dconf2nix

      ];

  };

}