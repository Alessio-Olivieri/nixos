{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
    };
  };

  outputs = { self, nixpkgs, home-manager, nix-vscode-extensions, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
      # You can pass inputs to all modules this way.
      specialArgs = { inherit inputs; };
    in
    {
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          inherit specialArgs; # Makes `inputs` available in all NixOS modules.
          modules = [
            ./configuration.nix
            ./hardware-vivobook.nix
            ./modules/wps-fonts.nix
            ./vivobook-battery-optimizations.nix

            # The main Home Manager module for NixOS.
            home-manager.nixosModules.home-manager
            {
              nixpkgs.overlays = [ nix-vscode-extensions.overlays.default ];

              # Home Manager configuration.
              home-manager = {
                backupFileExtension = "hm-bak";
                # This makes `inputs` available in all Home Manager modules.
                # It inherits the `specialArgs` from the nixosSystem call above,
                # so `extraSpecialArgs` is not strictly needed but doesn't hurt.
                extraSpecialArgs = specialArgs;
                useGlobalPkgs = true;
                useUserPackages = true;
                users.lexyo = { imports = [ ./home/home.nix];};
              };
            }
          ];
        };
        msi-laptop = nixpkgs.lib.nixosSystem {
          inherit specialArgs; 
          modules =[
            ./configuration.nix
            ./hardware-msi.nix    # <- Loads the NEW generated hardware
            ./modules/wps-fonts.nix
            ./msi-specific.nix    # <- Loads the GPU/Fan/TPM config

            home-manager.nixosModules.home-manager
            {
              nixpkgs.overlays =[ nix-vscode-extensions.overlays.default ];
              home-manager = {
                backupFileExtension = "hm-bak";
                extraSpecialArgs = specialArgs;
                useGlobalPkgs = true;
                useUserPackages = true;
                users.lexyo = { imports = [ ./home/home.nix ]; };
              };
            }
          ];
        };
        precision = nixpkgs.lib.nixosSystem {
          inherit specialArgs; 
          modules =[
            ./configuration.nix
            ./hardware-configuration.nix    # <- Loads the NEW generated hardware
            ./precision-nvidia.nix
            ./precision-camera.nix


            home-manager.nixosModules.home-manager
            {
              nixpkgs.overlays =[ nix-vscode-extensions.overlays.default ];
              home-manager = {
                backupFileExtension = "hm-bak";
                extraSpecialArgs = specialArgs;
                useGlobalPkgs = true;
                useUserPackages = true;
                users.lexyo = { imports = [ ./home/home.nix ]; };
              };
            }
          ];
        };
      };
    };
}
