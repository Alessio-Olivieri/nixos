{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    
    yazi = {
      url = "github:sxyazi/yazi";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
    };
  };

  outputs = { self, nixpkgs, home-manager, yazi, nix-vscode-extensions, ... }@inputs:
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
            ./modules/wps-fonts.nix

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
                users.lexyo = {
                  imports = [
                    # Your personal home-manager configuration.
                    ./home/home.nix
                  ];
                };
              };
            }
            ({ pkgs, ... }: {
						environment.systemPackages = [ yazi.packages.${pkgs.system}.default ];
					  })
          ];
        };
      };
    };
}