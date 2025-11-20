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
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./modules/gnome.nix
    ];
    gnome.enable = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.configurationLimit = 15;

  nix.gc = {
		automatic = true;
		dates = "daily";
		options = "--delete-older-than 3d";
	};

  zramSwap.enable = true;  

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  # Ensure the service is started at boot
  systemd.services.NetworkManager.wantedBy = [ "multi-user.target" ];

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

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  # services.xserver.enable = true;

  # Display manager
  #services.displayManager.sddm.enable = true; # Hyprland

  #GUI
  # programs.hyprland = {
  #   enable = true;
  #   xwayland.enable = true;
  # };

  # environment.sessionVariables = {
  #   NIXOS_OZONE_WL = "1"; # This variable fixes electron apps in Wayland
  # };


  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "it,us";             # Italian first, English (US) second
    variant = ",";                 # default variants
    options = "grp:super_space_toggle"; # switch with Super+Space
  };

  fonts.packages = with pkgs; [ nerd-fonts.jetbrains-mono ];  


  # Configure console keymap
  console.keyMap = "it";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    audio.enable = true;
    # If you want to use JACK applications, uncomment this
    # jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
    settings.General = {
      Experimental = true; # To show the battery of connected devices
    };
  };

  virtualisation.podman = {
  enable = true;
  dockerCompat = true;
};
security.lsm = lib.mkForce [ ]; # otherwise distrobox doesn't work


  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.lexyo = {
    isNormalUser = true;
    description = "Alessio Olivieri";
    extraGroups = [ "networkmanager" "wheel" "adbusers" "EduRadius-22"];
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Install some programs.
  programs.kdeconnect.enable = true;

  services.tailscale.enable = true;
  
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
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
  pkgs.android-tools
  pkgs.direnv
  (pkgs.kodi.withPackages (kodiPkgs: with kodiPkgs; [
    inputstream-adaptive
    inputstream-rtmp
    inputstream-ffmpegdirect
    inputstreamhelper
    raiplay
    netflix
    libretro
    libretro-fuse
    libretro-gw
    libretro-nestopia
    libretro-snes9x
    libretro-mgba
    libretro-genplus
    iagl
    ]))
  ];



  programs.ssh.extraConfig = ''
  '';

    nix.settings = {
    # given the users in this list the right to specify additional substituters via:
    #    1. `nixConfig.substituters` in `flake.nix`
    #    2. command line args `--options substituters http://xxx`
    trusted-users = ["lexyo"];
      substituters = [
      # cache mirror located in China
      # status: https://mirror.sjtu.edu.cn/
      # "https://mirror.sjtu.edu.cn/nix-channels/store"
      # status: https://mirrors.ustc.edu.cn/status/
      # "https://mirrors.ustc.edu.cn/nix-channels/store"

      "https://cache.nixos.org"
    ];

    trusted-public-keys = [
      # the default public key of cache.nixos.org, it's built-in, no need to add it here
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };

  nixpkgs.config.permittedInsecurePackages = [
              "ventoy-qt5-1.1.05"
            ];
    
  

  system.stateVersion = "25.05"; # Did you read the comment?

  # Watch stuff
  boot.kernel.sysctl."net.ipv4.ip_forward" = true;
  
  networking.nat = {
  enable = true;
  externalInterface = "wlp1s0";
  internalInterfaces = [ "enp4s0f3u4" ];
  };

}
