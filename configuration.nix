# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, lib, ... }:
    let 
      system = "x86_64-linux";
    in
{
  imports =
    [ 
      ./battery-optimizations.nix
      ./hardware-configuration.nix
      ./system-configuration.nix

      ./modules/gnome.nix
      ./modules/niri.nix
      ./modules/firefox.nix
    ];
    gnome.enable = true;
    niri.enable = true;
    firefox.enable = true;




  # Set your time zone.
  time.timeZone = "Europe/Rome";

  i18n = {
    # Select internationalisation properties.
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
    LC_ADDRESS = "it_IT.UTF-8";
    LC_IDENTIFICATION = "it_IT.UTF-8";
    LC_MEASUREMENT = "it_IT.UTF-8";
    LC_MONETARY = "it_IT.UTF-8";
    LC_NAME = "it_IT.UTF-8";
    LC_NUMERIC = "it_IT.UTF-8";
    LC_PAPER = "it_IT.UTF-8";
    LC_TELEPHONE = "it_IT.UTF-8";
    LC_TIME = "it_IT.UTF-8";
    };
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "it";
    variant = "";
  };
  console.keyMap = "it";

  fonts.packages = with pkgs; [ nerd-fonts.jetbrains-mono ];  

  
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  # Ensure the service is started at boot
  systemd.services.NetworkManager.wantedBy = [ "multi-user.target" ];

  virtualisation.podman = {
  enable = true;
  dockerCompat = true;
  };
  security.lsm = lib.mkForce [ ]; # otherwise distrobox doesn't work

  users.users.lexyo = {
    isNormalUser = true;
    description = "Alessio Olivieri";
    extraGroups = [ "networkmanager" "wheel" "adbusers" "EduRadius-22"];
  };


  services.printing.enable = true;
  programs.kdeconnect.enable = true;
  programs.adb.enable = true; 
  programs.direnv.enable=true;
  environment.systemPackages = [
  pkgs.wget
  pkgs.git
  pkgs.python3
  pkgs.vlc
  # dolphin
  # inputs.rose-pine-hyprcursor.packages.${pkgs.system}.default
  pkgs.libinput
  pkgs.devenv
  pkgs.stress-ng

  # pkgs.easyeffects # For audio effects on pipewire applications
  pkgs.xorg.xhost
  pkgs.kitty
  ];

    nix.settings = {

    trusted-users = ["lexyo"];
    substituters = [
      "https://cache.nixos.org"
    ];

    trusted-public-keys = [
      # the default public key of cache.nixos.org, it's built-in, no need to add it here
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };
  
  system.stateVersion = "25.05";

}
