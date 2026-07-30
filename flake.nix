{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    nix-vscode-extensions,
    ...
  }@inputs:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      pkgsUnstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };

      # Makes inputs and unstable packages available to the modules.
      specialArgs = {
        inherit inputs pkgsUnstable;
      };
    in
    {
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          inherit specialArgs;

          modules = [
            ./configuration.nix
            ./hardware-vivobook.nix
            ./modules/wps-fonts.nix
            ./vivobook-battery-optimizations.nix

            home-manager.nixosModules.home-manager
            {
              nixpkgs.overlays = [
                nix-vscode-extensions.overlays.default
              ];

              home-manager = {
                backupFileExtension = "hm-bak";
                extraSpecialArgs = specialArgs;
                useGlobalPkgs = true;
                useUserPackages = true;

                users.lexyo = {
                  imports = [ ./home/home.nix ];
                };
              };
            }
          ];
        };

        msi-laptop = nixpkgs.lib.nixosSystem {
          inherit specialArgs;

          modules = [
            ./configuration.nix
            ./hardware-msi.nix
            ./modules/wps-fonts.nix
            ./msi-specific.nix

            home-manager.nixosModules.home-manager
            {
              nixpkgs.overlays = [
                nix-vscode-extensions.overlays.default
              ];

              home-manager = {
                backupFileExtension = "hm-bak";
                extraSpecialArgs = specialArgs;
                useGlobalPkgs = true;
                useUserPackages = true;

                users.lexyo = {
                  imports = [ ./home/home.nix ];
                };
              };
            }
          ];
        };

        precision = nixpkgs.lib.nixosSystem {
          inherit specialArgs;

          modules = [
            ./configuration.nix
            ./hardware-configuration.nix
            ./precision-nvidia.nix
            ./precision-camera.nix

            home-manager.nixosModules.home-manager
            {
              nixpkgs.overlays = [
                nix-vscode-extensions.overlays.default
              ];

              home-manager = {
                backupFileExtension = "hm-bak";
                extraSpecialArgs = specialArgs;
                useGlobalPkgs = true;
                useUserPackages = true;

                users.lexyo = {
                  imports = [ ./home/home.nix ];
                };
              };
            }
          ];
        };
      };
    };
}