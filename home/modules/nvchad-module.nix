{ pkgs, lib, config, inputs, ... }:
{
          imports = [
            inputs.nvchad4nix.homeManagerModule
        ];
        options = {
            nvchad-module.enable = lib.mkEnableOption "Enables nvchad";
        };

    config = lib.mkIf config.nvchad-module.enable {
        programs.nvchad = {
            enable = true;
            hm-activation = true;
        };


    };
}