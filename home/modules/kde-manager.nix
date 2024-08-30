{ pkgs, lib, config, inputs, ... }:

let
#   klassy = pkgs.kdePackages.callPackage ../../custom-packages/klassy.nix { };
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

    # # Enable Klassy theme
    # home.packages = [ klassy ];
  };
}
