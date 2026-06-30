{ pkgs, lib, config, ... }:

let
  offloadCfg = config.hardware.nvidia.prime.offload;
  offloadCmdPath = "/run/current-system/sw/bin/${offloadCfg.offloadCmdMainProgram}";
  baseLutris = pkgs.lutris.override {
    extraPkgs = lutrisPkgs: [ lutrisPkgs.vulkan-tools ];
  };
  lutrisPackage =
    if offloadCfg.enableOffloadCmd then
      pkgs.symlinkJoin {
        name = "lutris-nvidia-offload";
        paths = [ baseLutris ];
        postBuild = ''
          rm -f $out/bin/lutris
          cat > $out/bin/lutris <<'EOF'
          #!${pkgs.runtimeShell}
          exec ${offloadCmdPath} ${lib.getExe baseLutris} "$@"
          EOF
          chmod +x $out/bin/lutris
        '';
      }
    else
      baseLutris;
in
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
        lutrisPackage
        
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
