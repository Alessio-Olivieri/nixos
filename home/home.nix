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
    ./modules/niri-module.nix
     ./modules/sub/dconf.nix
    ];
  gnome-manager.enable = false;
  vscode-module.enable = true;
  bash-module.enable = true;
  git-module.enable = true;
  kitty-module.enable = true;
  yazi-module.enable=true;
  niri-module.enable=true;

  # link the configuration file in current directory to the specified location in home directory
  # home.file.".config/i3/wallpaper.jpg".source = ./wallpaper.jpg;
services.mako.enable = true;
  # link all files in `./scripts` to `~/.config/i3/scripts`
  # home.file.".config/i3/scripts" = {
  #   source = ./scripts;
  #   recursive = true;   # link recursively
  #   executable = true;  # make all files executable
  # };
  home.stateVersion = "25.05";
  programs.home-manager.enable = true;

  programs.starship.enable = true;
  xdg.configFile."starship.toml".source = ./modules/sub/starship.toml;

  home.packages = with pkgs; [
    neofetch

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

    ayugram-desktop
    zoom-us
    discord
    slack

    obs-studio
    onlyoffice-bin
    gimp-with-plugins

    libgcc
    
    protonvpn-gui

    cpufetch
    google-chrome
    youtube-music
    kodi
    ghostty
    kdePackages.okular
    filezilla
    obsidian

    android-tools

    openfortivpn
      ];
}


