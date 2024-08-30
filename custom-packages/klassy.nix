{
  klassy,
  cmake,
  kdePackages,
  libsForQt5,
  hicolor-icon-theme,
  xdg-utils,
  stdenv,
}:
stdenv.mkDerivation rec {
  # based on https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/kde/plasma/breeze/default.nix
  # & archlinux package
  pname = "klassy";
  name = pname;

  src = klassy;

  # dependencies from aur package
  buildInputs =
    [
      hicolor-icon-theme
      xdg-utils
    ]
    ++ (with kdePackages; [
      wrapQtAppsHook
      # breeze-icons
      frameworkintegration
      kcmutils
      kcolorscheme
      kconfig
      kcoreaddons
      kdecoration
      kguiaddons
      ki18n
      kiconthemes
      kirigami
      kwidgetsaddons
      kwindowsystem
      qtbase
      qtsvg
      qtdeclarative
    ]);

  nativeBuildInputs = [
    cmake
    kdePackages.extra-cmake-modules
  ];

  outputs = [
    "out"
    "dev"
    "qt5"
  ];
  # We can't add qt5 stuff to dependencies or the hooks blow up,
  # so manually point everything to everything. Oof.
  cmakeFlags = [
    "-DQt5_DIR=${libsForQt5.qtbase.dev}/lib/cmake/Qt5"
    "-DQt5Core_DIR=${libsForQt5.qtbase.dev}/lib/cmake/Qt5Core"
    "-DQt5DBus_DIR=${libsForQt5.qtbase.dev}/lib/cmake/Qt5DBus"
    "-DQt5Gui_DIR=${libsForQt5.qtbase.dev}/lib/cmake/Qt5Gui"
    "-DQt5Network_DIR=${libsForQt5.qtbase.dev}/lib/cmake/Qt5Network"
    "-DQt5Qml_DIR=${libsForQt5.qtdeclarative.dev}/lib/cmake/Qt5Qml"
    "-DQt5QmlModels_DIR=${libsForQt5.qtdeclarative.dev}/lib/cmake/Qt5QmlModels"
    "-DQt5Quick_DIR=${libsForQt5.qtdeclarative.dev}/lib/cmake/Qt5Quick"
    "-DQt5Widgets_DIR=${libsForQt5.qtbase.dev}/lib/cmake/Qt5Widgets"
    "-DQt5X11Extras_DIR=${libsForQt5.qtx11extras.dev}/lib/cmake/Qt5X11Extras"
    "-DQt5Xml_DIR=${libsForQt5.qtbase.dev}/lib/cmake/Qt5Xml"

    "-DKF5Auth_DIR=${libsForQt5.kauth.dev}/lib/cmake/KF5Auth"
    "-DKF5Codecs_DIR=${libsForQt5.kcodecs.dev}/lib/cmake/KF5Codecs"
    "-DKF5Config_DIR=${libsForQt5.kconfig.dev}/lib/cmake/KF5Config"
    "-DKF5ConfigWidgets_DIR=${libsForQt5.kconfigwidgets.dev}/lib/cmake/KF5ConfigWidgets"
    "-DKF5CoreAddons_DIR=${libsForQt5.kcoreaddons.dev}/lib/cmake/KF5CoreAddons"
    "-DKF5FrameworkIntegration_DIR=${libsForQt5.frameworkintegration.dev}/lib/cmake/KF5FrameworkIntegration"
    "-DKF5GuiAddons_DIR=${libsForQt5.kguiaddons.dev}/lib/cmake/KF5GuiAddons"
    "-DKF5IconThemes_DIR=${libsForQt5.kiconthemes.dev}/lib/cmake/KF5IconThemes"
    "-DKF5Kirigami2_DIR=${libsForQt5.kirigami2.dev}/lib/cmake/KF5Kirigami2"
    "-DKF5WidgetsAddons_DIR=${libsForQt5.kwidgetsaddons.dev}/lib/cmake/KF5WidgetsAddons"
    "-DKF5WindowSystem_DIR=${libsForQt5.kwindowsystem.dev}/lib/cmake/KF5WindowSystem"

    "-DKF5I18n_DIR=${libsForQt5.ki18n.dev}/lib/cmake/KF5I18n"

    "-DBUILD_TESTING=ON"
    "-DBUILD_QT6=ON"
    "-DBUILD_QT5=ON"
  ];

  # Move Qt5 plugin to Qt5 plugin path
  postInstall = ''
    mkdir -p $qt5/${libsForQt5.qtbase.qtPluginPrefix}/styles
    mv $out/${kdePackages.qtbase.qtPluginPrefix}/styles/klassy5.so $qt5/${libsForQt5.qtbase.qtPluginPrefix}/styles
  '';
}