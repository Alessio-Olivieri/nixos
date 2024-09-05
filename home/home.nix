{ config, pkgs, ... }:
let 
  system = "x86_64-linux";
in
{
  home.username = "lexyo";
  home.homeDirectory = "/home/lexyo";

  imports = [
    ./modules/kde-manager.nix
    ./modules/hyprland-manager.nix
    ./modules/vscode-module.nix
    ./modules/gnome-manager.nix
    ./modules/git-module.nix
    ./modules/starship-module.nix
    ./modules/bash-module.nix

    # ./modules/sub/dconf.nix
    ];
  kde-manager.enable = false;
  hyprland-manager.enable = false;
  gnome-manager.enable = true;
  vscode-module.enable = true;
  starship-module.enable = true;
  bash-module.enable = true;
  git-module.enable = true;
  # link the configuration file in current directory to the specified location in home directory
  # home.file.".config/i3/wallpaper.jpg".source = ./wallpaper.jpg;

  # link all files in `./scripts` to `~/.config/i3/scripts`
  # home.file.".config/i3/scripts" = {
  #   source = ./scripts;
  #   recursive = true;   # link recursively
  #   executable = true;  # make all files executable
  # };

  # encode the file content in nix configuration file directly
  # home.file.".xxx".text = ''vscode
  #     xxx
  # '';

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    # here is some command line tools I use frequently
    # feel free to add your own or remove some of them

    neofetch

    # archives
    zip
    xz
    unzip
    p7zip

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

    # nix related
    #
    # it provides the command `nom` works just like `nix`
    # with more details log output
    nix-output-monitor

    btop  # replacement of htop/nmon
    iotop # io monitoring
    iftop # network monitoring

    # system tools
    sysstat
    lm_sensors # for `sensors` command
    ethtool
    pciutils # lspci
    usbutils # lsusb
    wev # wayland input

    telegram-desktop
    zoom-us
    discord
    obs-studio

    poetry
    step-cli
      ];

  # This value determines the home Manager release that your configuration is compatible with. 
  # This helps avoid breakage when a new home Manager release introduces backwards 
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.11";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
