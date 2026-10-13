{ lib, stdenv, fetchurl, autoPatchelfHook, makeWrapper, makeDesktopItem,
  copyDesktopItems, alsa-lib, fontconfig, freetype, glib, gtk3,
  libappindicator-gtk3, libGL, libx11, libxext, libxi, libxrender, libxtst,
  libxrandr, libxcursor, libxfixes, libxinerama, zlib }:
let
  runtimeLibraries = [
    stdenv.cc.cc.lib alsa-lib fontconfig freetype glib gtk3
    libappindicator-gtk3 libGL zlib
    libx11 libxext libxi libxrender libxtst
    libxrandr libxcursor libxfixes libxinerama
  ];
in
stdenv.mkDerivation (finalAttrs: {
  pname = "ab-download-manager";
  version = "1.11.0";

  # Official upstream distribution, including its matching Java runtime.
  src = fetchurl {
    url = "https://github.com/amir1376/ab-download-manager/releases/download/v${finalAttrs.version}/ABDownloadManager_${finalAttrs.version}_linux_x64.tar.gz";
    hash = "sha256-aaxQyvBJpR1aL5gwA77U2IyR4q33vZQn5Mj1Z+Pwf6A=";
  };

  nativeBuildInputs = [ autoPatchelfHook makeWrapper copyDesktopItems ];
  buildInputs = runtimeLibraries;
  dontBuild = true;
  dontStrip = true;

  desktopItems = [ (makeDesktopItem {
    name = "com.abdownloadmanager";
    desktopName = "AB Download Manager";
    genericName = "Download Manager";
    comment = "Manage and organize downloads";
    exec = "ab-download-manager";
    icon = "ab-download-manager";
    categories = [ "Network" "FileTransfer" ];
    startupWMClass = "com-abdownloadmanager-desktop-AppKt";
  }) ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/ab-download-manager $out/bin
    cp -r . $out/lib/ab-download-manager/
    # Keep jpackage executables at their original names: they locate their
    # .cfg files using the executable basename.
    makeWrapper $out/lib/ab-download-manager/bin/ABDownloadManager $out/bin/ab-download-manager \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibraries}:/run/opengl-driver/lib
    makeWrapper $out/lib/ab-download-manager/bin/ABDownloadManagerCli $out/bin/ab-download-manager-cli \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibraries}:/run/opengl-driver/lib
    makeWrapper $out/lib/ab-download-manager/bin/ABDownloadManagerNativeMessagingHost $out/bin/ab-download-manager-native-host \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibraries}:/run/opengl-driver/lib
    install -Dm644 lib/ABDownloadManager.png $out/share/pixmaps/ab-download-manager.png

    # Firefox discovers this through programs.firefox.nativeMessagingHosts.
    mkdir -p $out/lib/mozilla/native-messaging-hosts
    cat > $out/lib/mozilla/native-messaging-hosts/com.abdownloadmanager.json <<EOF
    {
      "name": "com.abdownloadmanager",
      "description": "AB Download Manager",
      "path": "$out/bin/ab-download-manager-native-host",
      "type": "stdio",
      "allowed_extensions": ["firefox-integration@abdownloadmanager.com"]
    }
    EOF
    runHook postInstall
  '';

  meta = {
    description = "Download manager with browser integration";
    homepage = "https://abdownloadmanager.com/";
    license = lib.licenses.asl20;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "ab-download-manager";
  };
})
