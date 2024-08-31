{ pkgs, lib, config, inputs, ... }:
{

  options = {
    gnome-manager.enable = lib.mkEnableOption "Enables gnome Nix settings";
  };

  config = lib.mkIf config.gnome-manager.enable {
  };

}