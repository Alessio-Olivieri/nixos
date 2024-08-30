{ pkgs, lib, config, inputs, ... }:

let
  klassy = pkgs.kdePackages.callPackage ./path/to/klassy.nix { inherit (inputs) klassy; };
in
{
  options = {
    kde-manager.enable = lib.mkEnableOption "Enables KDE Nix settings";
  };

  config = lib.mkIf config.kde-manager.enable {
    programs.plasma = {
      enable = true;

      desktop.widgets = [
        {
          config = {
            Appearance = {
              showDate = false;
            };
          };
          name = "org.kde.plasma.digitalclock";
          position = {
            horizontal = 51;
            vertical = 100;
          };
          size = {
            height = 250;
            width = 250;
          };
        }
      ];
    };

    # Enable Klassy theme
    environment.systemPackages = [ klassy ];
  };
}
