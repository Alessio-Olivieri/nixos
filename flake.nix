{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    zen-browser.url = "github:MarceColl/zen-browser-flake";

    nvchad4nix = {
      url = "github:nix-community/nix4nvchad";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, plasma-manager, ... }@inputs:
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
          {  # <- # example to add the overlay to Nixpkgs:
            nixpkgs = {
              overlays = [
                (final: prev: {
                    nvchad = inputs.nvchad4nix.packages."${pkgs.system}".nvchad;
                })
              ];
            };
          }
          home-manager.nixosModules.home-manager {
            home-manager = {
              inherit extraSpecialArgs; # <- this will make inputs available anywhere in the HM configuration
              useGlobalPkgs = true;
              useUserPackages = true;
              sharedModules = [plasma-manager.homeManagerModules.plasma-manager];
              users.lexyo = import ./home/home.nix;
            };
          }
        ];
      };
    };
  };
}