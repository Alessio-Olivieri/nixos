{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let 
      system = "x86_64-linux";
      lib = nixpkgs.lib;
      pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
      extraSpecialArgs = { inherit system; inherit inputs; };  # <- passing inputs to the attribute set for home-manager
      specialArgs = { inherit system; inherit inputs; };       # <- passing inputs to the attribute set for NixOS (optional)
    in
    {

    nixosConfigurations = {
      nixos = lib.nixosSystem {
        inherit specialArgs;        # <- this will make inputs available anywhere in the NixOS configuration
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager {
            home-manager = {
              inherit extraSpecialArgs; # <- this will make inputs available anywhere in the HM configuration
              useGlobalPkgs = true;
              useUserPackages = true;
              users.lexyo = import ./home/home.nix;
            };
          }
        ];
      };
    };
  };
}