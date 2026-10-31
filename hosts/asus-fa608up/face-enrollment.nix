{ config, lib, pkgs, ... }:
let
  nativeGui = pkgs.writeShellScript "asus-howdy-native-gui" ''
    umask 077
    export DISPLAY="$1"
    export XAUTHORITY="$2"
    export SUDO_USER="$3"
    export GDK_BACKEND=x11
    export PATH="${config.services.howdy.package}/bin:/run/current-system/sw/bin:/run/wrappers/bin"
    shift 3
    exec ${config.services.howdy.package}/bin/howdy-gtk "$@"
  '';
  nativeLauncher = pkgs.writeShellApplication {
    name = "asus-howdy";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      exec /run/wrappers/bin/pkexec ${nativeGui} "''${DISPLAY:-}" "''${XAUTHORITY:-}" "$(id -un)" "$@"
    '';
  };
  gui = pkgs.writeShellScript "asus-howdy-enroll-gui" ''
    export DISPLAY="$1"
    export XAUTHORITY="$2"
    export GDK_BACKEND=x11
    export OMP_NUM_THREADS=1
    shift 2
    exec ${config.services.howdy.package.pythonEnv}/bin/python3 ${./face-enrollment.py} "$@"
  '';
  launcher = pkgs.writeShellApplication {
    name = "asus-howdy-enroll";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      exec /run/wrappers/bin/pkexec ${gui} "''${DISPLAY:-}" "''${XAUTHORITY:-}" --user "$(id -un)" "$@"
    '';
  };
in {
  config = lib.mkIf (config.hardware.asus-fa608up.irCamera != null) {
    environment.systemPackages = [ nativeLauncher launcher ];
    home-manager.users.lexyo.xdg.desktopEntries.howdy = {
      name = "Howdy Face Authentication";
      comment = "Manage face models and preview the infrared camera";
      exec = "${nativeLauncher}/bin/asus-howdy";
      icon = "howdy";
      terminal = false;
      categories = [ "Settings" "Security" ];
    };
    home-manager.users.lexyo.xdg.desktopEntries.asus-howdy-enroll = {
      name = "ASUS Face Enrollment";
      comment = "Preview the IR camera and enroll face angles with one administrator prompt";
      exec = "${launcher}/bin/asus-howdy-enroll";
      icon = "camera-web-symbolic";
      terminal = false;
      categories = [ "Settings" "Security" ];
    };
  };
}
