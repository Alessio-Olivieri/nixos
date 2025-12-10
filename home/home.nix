{ inputs, config, pkgs, ... }:
let 
  system = "x86_64-linux";
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
    ./modules/yazi-module.nix
    ./modules/firefox-module.nix
    ./modules/thunderbird-module.nix
    ./modules/submodules/dconf.nix 
    # ./modules/submodules/gnome-theme-switcher.nix
    ];
  gnome-manager.enable = true;
  vscode-module.enable = true;
  bash-module.enable = true;
  git-module.enable = true;
  kitty-module.enable = true;
  yazi-module.enable=true;
  firefox-module.enable=true;
  thunderbird-module.enable=true;

  # link the configuration file in current directory to the specified location in home directory
  # home.file.".config/i3/wallpaper.jpg".source = ./wallpaper.jpg;

  # link all files in `./scripts` to `~/.config/i3/scripts`
  # home.file.".config/i3/scripts" = {
  #   source = ./scripts;
  #   recursive = true;   # link recursively
  #   executable = true;  # make all files executable
  # };
  home.stateVersion = "25.05";
  programs.home-manager.enable = true;

  programs.starship.enable = true;
  xdg.configFile."starship.toml".source = ./modules/submodules/starship.toml;

  xdg = {
    mimeApps = {
      enable = true;
      defaultApplications = {
        "x-scheme-handler/sms" = [ "org.gnome.Shell.Extensions.GSConnect.desktop" ];
        "x-scheme-handler/tel" = [ "org.gnome.Shell.Extensions.GSConnect.desktop" ];
        
        # Multiple apps are separated by spaces inside the list brackets
        "x-scheme-handler/tg" = [ "org.telegram.desktop.desktop" "userapp-AyuGram Desktop-20GG82.desktop" ];
        
        "image/*" = [ "org.gnome.Loupe.desktop" ];
        "application/pdf" = [ "okularApplication_pdf.desktop" ];
        "x-scheme-handler/http" = [ "firefox.desktop" ];
        "x-scheme-handler/https" = [ "firefox.desktop" ];
        "text/html" = [ "firefox.desktop" ];
        
        "application/x-ipynb+json" = [ "code.desktop" ];
        "application/json" = [ "code.desktop" "firefox.desktop" ];
        "text/css" = [ "code.desktop" ];
        
        "x-scheme-handler/tonsite" = [ "userapp-AyuGram Desktop-Q3JF82.desktop" ];
        "text/markdown" = [ "org.gnome.gitlab.somas.Apostrophe.desktop" ];
        "text/plain" = [ "code.desktop" "codium.desktop" ];
        "application/x-shellscript" = [ "codium.desktop" ];
        
        "x-scheme-handler/mailto" = [ "userapp-Thunderbird-4U4NG3.desktop" ];
        "x-scheme-handler/mid" = [ "userapp-Thunderbird-4U4NG3.desktop" ];
      };
    };
  };
  
  home.packages = with pkgs; [
    neofetch
    htop

    # archives
    zip
    xz
    unzip
    p7zip
    unrar
    
    # misc
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
    onlyoffice-bin
    gimp-with-plugins

    libgcc
    
    protonvpn-gui

    cpufetch
    youtube-music
    ghostty
    kdePackages.okular
    filezilla
    obsidian

    android-tools
    tmux
    openfortivpn
    apostrophe
    zettlr
    hotspot #For visualizing perf.data
    chromium
    ];

  #NEXTCLOUD
    services.nextcloud-client = {
      enable = true;
      #startInBackground = false;
    };
    systemd.user.services.nextcloud-client = {
      Unit = {
        After = pkgs.lib.mkForce "graphical-session.target"; 
      };
    };
}


