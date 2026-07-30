{ inputs, config, pkgs, pkgsUnstable, ... }:
let 
  system = "x86_64-linux";

  jdownloaderLauncher = pkgs.writeShellScriptBin "launch-jdownloader" ''
    # Set the target directory using $HOME instead of ~ (safer in scripts)
    TARGET_DIR="$HOME/.local/share/JDownloader"
    
    # Create directory
    mkdir -p "$TARGET_DIR"
    
    # Copy file if it exists and hasn't been copied yet
    if [ -f "/etc/nixos/files/JDownloader.jar" ]; then
      cp -n /etc/nixos/files/JDownloader.jar "$TARGET_DIR/"
    fi
    
    # Change directory and run
    cd "$TARGET_DIR"
    exec ${pkgs.jre}/bin/java -jar JDownloader.jar
  '';
in
{
  home.username = "lexyo";
  home.homeDirectory = "/home/lexyo";

  imports = [
    ./modules/vscode-module.nix
    ./modules/gnome-manager.nix
    ./modules/git-module.nix
    ./modules/bash-module.nix
    ./modules/kitty-module.nix
    ./modules/firefox-module.nix
    ./modules/obsidian-module.nix
    ./modules/thunderbird-module.nix
    ./modules/steam.nix
    ./modules/hide-waydroid.nix
    ./modules/submodules/dconf.nix 
    # ./modules/submodules/gnome-theme-switcher.nix
    ];
  gnome-manager.enable = true;
  vscode-module.enable = true;
  bash-module.enable = true;
  git-module.enable = true;
  kitty-module.enable = true;
  firefox-module.enable=true;
  obsidian-module.enable = true;
  thunderbird-module.enable=false;


  services.syncthing = {
    enable = true;
  };

  # link the configuration file in current directory to the specified location in home directory
  # home.file.".config/i3/wallpaper.jpg".source = ./wallpaper.jpg;

  # link all files in `./scripts` to `~/.config/i3/scripts`
  # home.file.".config/i3/scripts" = {
  #   source = ./scripts;
  #   recursive = true;   # link recursively
  #   executable = true;  # make all files executable
  # };
  home.stateVersion = "26.05";
  programs.home-manager.enable = true;

  programs.starship.enable = true;
  xdg.configFile."starship.toml".source = ./modules/submodules/starship.toml;


  
  xdg = {
    mime = {
    enable = true;

      # defaultApplications = {
      #   "text/html" = "firefox.desktop";
      #   "application/xhtml+xml" = "firefox.desktop";
      #   "x-scheme-handler/http" = "firefox.desktop";
      #   "x-scheme-handler/https" = "firefox.desktop";
      #   "x-scheme-handler/about" = "firefox.desktop";
      #   "x-scheme-handler/unknown" = "firefox.desktop";
      # };
    };
    desktopEntries = {
      jdownloader = {
        name = "JDownloader 2";
        genericName = "Download Manager";
        # This new command does 3 things:
        # 1. Creates the folder in your home
        # 2. Copies the jar there ONLY if it doesn't exist (so updates aren't overwritten)
        # 3. Runs the jar from that new folder
        exec = "${jdownloaderLauncher}/bin/launch-jdownloader";
        terminal = false;
        categories = [ "Network" "FileTransfer" ];
        icon = "folder-download"; 
        settings = {
          Path = "/home/lexyo/.local/share/JDownloader"; 
        };
      };
      Windows = {
        name = "Windows";
        genericName = "Virtual Machine";
        exec = "quickemu --vm /home/lexyo/windows-11.conf --display spice";
        terminal = false;
        icon = "distributor-logo-windows";
        settings = {
          Path = "/home/lexyo";
        };
      };
    };
  #   mimeApps = {
  #     enable = true;
  #     defaultApplications = {
  #       "x-scheme-handler/sms" = [ "org.gnome.Shell.Extensions.GSConnect.desktop" ];
  #       "x-scheme-handler/tel" = [ "org.gnome.Shell.Extensions.GSConnect.desktop" ];
        
  #       # Multiple apps are separated by spaces inside the list brackets
  #       "x-scheme-handler/tg" = [ "org.telegram.desktop.desktop" "userapp-AyuGram Desktop-20GG82.desktop" ];
        
  #       "image/*" = [ "org.gnome.Loupe.desktop" ];
  #       "application/pdf" = [ "okularApplication_pdf.desktop" ];
  #       "x-scheme-handler/http" = [ "firefox.desktop" ];
  #       "x-scheme-handler/https" = [ "firefox.desktop" ];
  #       "text/html" = [ "firefox.desktop" ];
        
  #       "application/x-ipynb+json" = [ "code.desktop" ];
  #       "application/json" = [ "code.desktop" "firefox.desktop" ];
  #       "text/css" = [ "code.desktop" ];
        
  #       "x-scheme-handler/tonsite" = [ "userapp-AyuGram Desktop-Q3JF82.desktop" ];
  #       "text/markdown" = [ "org.gnome.gitlab.somas.Apostrophe.desktop" ];
  #       "text/plain" = [ "code.desktop" "codium.desktop" ];
  #       "application/x-shellscript" = [ "codium.desktop" ];z
        
  #       "x-scheme-handler/mailto" = [ "userapp-Thunderbird-4U4NG3.desktop" ];
  #       "x-scheme-handler/mid" = [ "userapp-Thunderbird-4U4NG3.desktop" ];
  #     };
  #   };
  };
  
  home.packages = with pkgs; [
    libreoffice-qt
    hunspell
    hunspellDicts.en_US
    hunspellDicts.it_IT

    authenticator


    htop
    xnviewmp
    variety

    # archives
    zip
    xz
    unzip
    p7zip
    unrar
    
    # misc
    jre
    cowsay
    file
    which
    tree
    gnused
    gnutar
    gawk
    zstd
    gnupg
    smile

    nix-output-monitor

    btop  
    iotop 
    iftop 

    sysstat
    lm_sensors 
    ethtool
    pciutils 
    usbutils 
    wev 
    distrobox

    zoom-us
    discord
    slack

    obs-studio
    gimp-with-plugins

    libgcc
    
    proton-vpn

    cpufetch
    pear-desktop
    ghostty
    filezilla
    obsidian
    localsend

    newsflash
    android-tools
    tmux
    openfortivpn
    hotspot #For visualizing perf.data
    chromium
    pkgsUnstable.codex
    ];


  #NEXTCLOUD
    # services.nextcloud-client = {
    #   enable = true;
    #   #startInBackground = false;
    # };
    # systemd.user.services.nextcloud-client = {
    #   Unit = {
    #     After = pkgs.lib.mkForce "graphical-session.target"; 
    #   };
    # };
}
