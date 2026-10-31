{ lib, pkgs, ... }:
let
  nativeKeyboard = pkgs.writeShellScript "asus-keyboard-native" ''
    exec ${pkgs.python3}/bin/python3 ${./keyboard-native.py}
  '';
  keyboard = pkgs.writeShellApplication {
    name = "asus-keyboard";
    runtimeInputs = [ pkgs.asusctl pkgs.systemd pkgs.util-linux ];
    text = ''
      # Serialise rapid key presses, including the colour read/modify/write.
      exec 9>"$XDG_RUNTIME_DIR/asus-keyboard.lock"
      flock 9
      case "''${1:-}" in
        off|low|med|high) asusctl leds set "$1" ;;
        next|prev) asusctl leds "$1" ;;
        cycle)
          # FA608UP's pinned support database exposes Static only. Cycle
          # colours through asusd rather than silently reselecting Static.
          current=$(busctl get-property xyz.ljones.Asusd /xyz/ljones/aura/tuf \
            xyz.ljones.Aura LedModeData)
          case "$current" in
            *' 102 153 204 '*) colour=ffb060 ;;
            *' 255 176 96 '*) colour=bb77ff ;;
            *' 187 119 255 '*) colour=66cc99 ;;
            *) colour=6699cc ;;
          esac
          asusctl aura power-tuf --awake true --keyboard --boot false --sleep false
          asusctl aura effect static -c "$colour"
          if [[ $(asusctl leds get) == *Off* ]]; then
            asusctl leds set low
          fi
          ;;
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
        *) echo "Usage: asus-keyboard off|low|med|high|next|prev|cycle|colour RRGGBB|calm" >&2; exit 2 ;;
      esac
    '';
  };
  rogBackground = pkgs.writeShellApplication {
    name = "rog-background";
    runtimeInputs = [ pkgs.python3 ];
    text = ''
      # RCC rewrites this file itself. Keep it mutable and preserve GUI
      # preferences while enforcing the requested background behaviour.
      python3 ${./rog-background-config.py}
      exec ${pkgs.asusctl}/bin/rog-control-center
    '';
  };
  rogOpen = pkgs.writeShellApplication {
    name = "rog-open";
    runtimeInputs = [ pkgs.systemd ];
    text = ''
      systemctl --user start rog-control-center.service
      exec ${pkgs.asusctl}/bin/rog-control-center
    '';
  };
  bindings = {
    asus-aura = { name = "ASUS keyboard colours"; binding = "XF86Launch4"; command = "${keyboard}/bin/asus-keyboard cycle"; };
    asus-armoury = { name = "ROG Control Center"; binding = "XF86Launch3"; command = "${rogOpen}/bin/rog-open"; };
  };
in {
  # The I2C 0b05:19b6 LampArray can remain in OS-controlled mode while
  # asusd only discovers USB controllers. Return it to the EC so the native
  # Fn brightness keys and asusd's WMI colour controls drive the real LEDs.
  systemd.services.asus-keyboard-native = {
    description = "Restore native ASUS I2C keyboard lighting control";
    before = [ "asusd.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = nativeKeyboard;
    };
  };
  systemd.services.asusd = {
    wants = [ "asus-keyboard-native.service" ];
    after = [ "asus-keyboard-native.service" ];
  };
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="hidraw", KERNELS=="0018:0B05:19B6.*", TAG+="systemd", ENV{SYSTEMD_WANTS}+="asus-keyboard-native.service"
  '';
  powerManagement.resumeCommands = "${nativeKeyboard}";
  # This kernel exposes no asus-armoury firmware attributes, so there are no
  # deferred GPU writes to apply. The 6.3.7 helper ignores SIGTERM even on an
  # ordinary asusd restart and leaves failed jobs/processes behind. Keep it
  # disabled on this fixed-hybrid host until the firmware backend is enabled.
  systemd.services.asus-shutdown.enable = false;
  # Upstream's sandbox requires this directory even on first startup; the
  # daemon cannot create it from inside its own mount namespace. Keep its
  # files mutable so CLI/GUI choices persist instead of resetting on rebuild.
  systemd.services.asusd.serviceConfig = {
    ConfigurationDirectory = "asusd";
    ConfigurationDirectoryMode = "0755";
  };
  environment.systemPackages = [ keyboard rogOpen pkgs.mesa-demos pkgs.brightnessctl ];
  # The kernel consumes Fan (0xae) and cycles platform profiles itself.
  # Brightness (0xc4/0xc5/0xc7) is also handled there. Do not double-bind.
  home-manager.users.lexyo = { lib, ... }: {
    xdg.dataFile."gnome-shell/extensions/asus-profile-osd@alessio.local".source = ./profile-osd;
    systemd.user.services.rog-control-center = {
      Unit = {
        Description = "ROG Control Center background interface";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        Type = "dbus";
        BusName = "xyz.ljones.rogcc";
        ExecStart = "${rogBackground}/bin/rog-background";
        Restart = "on-failure";
        RestartSec = 3;
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
    dconf.settings = {
      "org/gnome/shell".enabled-extensions = lib.mkAfter [ "asus-profile-osd@alessio.local" ];
      "org/gnome/shell/keybindings".show-screenshot-ui =
        [ "Print" "XF86SelectiveScreenshot" "<Shift><Super>s" ];
      "org/gnome/settings-daemon/plugins/media-keys".custom-keybindings =
        lib.mkAfter (map (name: "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/${name}/") (builtins.attrNames bindings));
    } // lib.mapAttrs' (name: value: lib.nameValuePair
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/${name}" value) bindings;
  };

  # Keep the firmware-selected backlight policy. The native-backlight test
  # changed sysfs readings but not visible brightness, and the user reported
  # that its keys regressed. Do not reintroduce acpi_backlight=native here.
}
