{ pkgs, lib, config, ... }:

{
    options = {
        lutris-module.enable = lib.mkEnableOption "Enables lutris";
    };

    config = lib.mkIf config.lutris-module.enable {
        
      programs.steam = {
        enable = true;
        remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
        dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
        localNetworkGameTransfers.openFirewall = true; 
      };

      # 2. Install Game-related Packages
      environment.systemPackages = with pkgs; [
        lutris
        
        # Wine and Winetricks are needed as a backend for Lutris
        wineWow64Packages.staging
        winetricks
        
        # ProtonUp-Qt is essential for easily installing custom Wine-GE / Proton-GE runners
        protonup-qt 

        # Optional: Vulkan tools and MangoHud for FPS overlay
        vulkan-tools
        mangohud
      ];
    };
}