{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
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

            # The main Home Manager module for NixOS.
            home-manager.nixosModules.home-manager
            {
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
          ];
        };
      };
    };
}