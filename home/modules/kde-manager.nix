{ pkgs, lib, config, inputs, ... }:

let
  # klassy = pkgs.kdePackages.callPackage ../../custom-packages/klassy.nix { };
in
{
  options = {
    kde-manager.enable = lib.mkEnableOption "Enables KDE Nix settings";
  };

  config = lib.mkIf config.kde-manager.enable {

    home.packages = with pkgs; [
        libsForQt5.polonium
    ];

    programs.plasma = {
      enable = true;
      overrideConfig = true;

      panels = [
        {
          location = "right";
          widgets = [

            {
              digitalClock = {
                calendar.firstDayOfWeek = "monday";
                time.format = "24h";
              };
            }
            {
              name = "org.kde.plasma.icontasks";
              config = {
                General = {
                  launchers = [
                    "applications:org.kde.dolphin.desktop"
                    "applications:org.kde.konsole.desktop"
                    "applications:firefox.desktop"
                  ];
                };
              };
            }

            "org.kde.plasma.marginsseparator"

            {
              systemTray.items = {
                # We explicitly show bluetooth and battery
                shown = [
                  "org.kde.plasma.battery"
                  "org.kde.plasma.bluetooth"
                ];
                # And explicitly hide network management and volume
                hidden = [
                  "org.kde.kdeconnect"
                  "org.kde.plasma.volume"
                ];
              };
            }
            {
              name = "org.kde.plasma.kickoff";
              config = {
                General = {
                  icon = "nix-snowflake-black";
                  alphaSort = true;
                };
              };
            }
          ];
        }
      ];

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

      kwin = {
        virtualDesktops = {
          number = 10;
          rows = 1;
        };
      };
    };

  };
}
