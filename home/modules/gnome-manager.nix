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
            pkgs.gnomeExtensions.blur-my-shell.extensionUuid
            
            pkgs.gnomeExtensions.paperwm.extensionUuid

            # Alternatively, you can manually pass UUID as a string.  
            # pkgs.gnomeExtensions.gsconnect.extensionUuid
            # ...
          ];
        };


        # Configure individual extensions
        "org/gnome/shell/extensions/blur-my-shell" = {
          brightness = 0.75;
          noise-amount = 0;
        };
      };

    };
    home.packages = with pkgs; [
      dconf2nix # dconf dump / | dconf2nix > /etc/nixos/home/modules/sub/dconf.nix
      ];

  };

}