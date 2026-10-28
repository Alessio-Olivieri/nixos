{ lib, pkgs, ... }:
let
  keyboard = pkgs.writeShellApplication {
    name = "asus-keyboard";
    runtimeInputs = [ pkgs.asusctl ];
    text = ''
      case "''${1:-}" in
        off|low|med|high) asusctl leds set "$1" ;;
        colour)
          colour="''${2:-}"
          if [[ ! "$colour" =~ ^[[:xdigit:]]{6}$ ]]; then
            echo "Usage: asus-keyboard colour RRGGBB" >&2
            exit 2
          fi
          asusctl aura effect static -c "$colour"
          asusctl leds set low
          ;;
        calm)
          asusctl aura effect static -c 6699cc
          asusctl leds set low
          asusctl aura power-tuf --awake true --keyboard --boot false --sleep false
          ;;
        *) echo "Usage: asus-keyboard off|low|med|high|colour RRGGBB|calm" >&2; exit 2 ;;
      esac
    '';
  };
in {
  # Upstream's sandbox requires this directory even on first startup; the
  # daemon cannot create it from inside its own mount namespace. Keep its
  # files mutable so CLI/GUI choices persist instead of resetting on rebuild.
  systemd.services.asusd.serviceConfig = {
    ConfigurationDirectory = "asusd";
    ConfigurationDirectoryMode = "0755";
  };
  environment.systemPackages = [ keyboard pkgs.mesa-demos pkgs.brightnessctl ];
  home-manager.users.lexyo.dconf.settings = {
    # Kernel asus-nb-wmi maps Aura (0xb3 / KEY_PROG4) to XF86Launch4.
    # Keep the existing Control-comma shortcut and GNOME's native keyboard
    # brightness bindings. No effect cycling: only Static is advertised here.
    "org/gnome/settings-daemon/plugins/media-keys".custom-keybindings =
      lib.mkAfter [ "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/asus-aura/" ];
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/asus-aura" = {
      name = "ASUS lighting and power controls";
      binding = "XF86Launch4";
      command = "${pkgs.asusctl}/bin/rog-control-center";
    };
  };

  # Keep the firmware-selected backlight policy. The native-backlight test
  # changed sysfs readings but not visible brightness, and the user reported
  # that its keys regressed. Do not reintroduce acpi_backlight=native here.
}
