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
      checks.${system} = {
        precision-mutter-lifecycle = self.packages.${system}.precision-mutter-lifecycle-vm-test;
        precision-gpu-indicator = pkgs.callPackage ./modules/precision-gpu-indicator/package.nix {};
        precision-windows-safety = let
          source = nixpkgs.lib.cleanSourceWith {
            src = ./modules/precision-windows;
            filter = path: type:
              nixpkgs.lib.cleanSourceFilter path type
              && baseNameOf path != "__pycache__"
              && !(nixpkgs.lib.hasSuffix ".pyc" path);
          };
        in pkgs.runCommand "precision-windows-safety-tests" {} ''
          ${pkgs.python3}/bin/python3 -B -m unittest discover -s ${source}/tests -p 'test_*.py'
          ${pkgs.gjs}/bin/gjs -m ${source}/tests/test_display_guard.js
          touch $out
        '';
      };

      packages.${system} = {
        precision-gaming-lifecycle-candidate =
          (self.nixosConfigurations.precision.extendModules {
            modules = [ ./maintenance/lifecycle-session-candidate-module.nix
              { services.precision-windows.gamingEnabled = true; } ];
          }).config.system.build.toplevel;
        precision-lifecycle-session-candidate =
          (self.nixosConfigurations.precision.extendModules {
            modules = [ ./maintenance/lifecycle-session-candidate-module.nix ];
          }).config.system.build.toplevel;
        precision-mutter-cpu-vm-test =
          import ./maintenance/mutter-lifecycle-vm-test.nix {
            inherit pkgs;
            mutter = self.packages.${system}.precision-mutter-scanout-cpu-candidate;
          };
        precision-mutter-lifecycle-vm-test =
          import ./maintenance/mutter-lifecycle-vm-test.nix {
            inherit pkgs;
            mutter = self.packages.${system}.precision-mutter-lifecycle-candidate;
          };
        precision-mutter-lifecycle-candidate =
          import ./maintenance/mutter-lifecycle-candidate.nix { inherit pkgs; };
        precision-scanout-cpu-session-candidate =
          (self.nixosConfigurations.precision.extendModules {
            modules = [ ./maintenance/scanout-cpu-session-candidate-module.nix ];
          }).config.system.build.toplevel;
        precision-mutter-scanout-cpu-candidate =
          import ./maintenance/mutter-scanout-cpu-candidate.nix { inherit pkgs; };
        precision-mutter-scanout-candidate =
          import ./maintenance/mutter-scanout-candidate.nix { inherit pkgs; };
        precision-scanout-session-candidate =
          (self.nixosConfigurations.precision.extendModules {
            modules = [ ./maintenance/scanout-session-candidate-module.nix ];
          }).config.system.build.toplevel;

        # Historical explicit test build, separate from the tested CPU-copy
        # desktop baseline now used by the normal host output.
        precision-hdmi-session-test =
          (self.nixosConfigurations.precision.extendModules {
            modules = [ ./maintenance/hdmi-session-test-module.nix ];
          }).config.system.build.toplevel;
      };

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
            ./precision-windows.nix

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
