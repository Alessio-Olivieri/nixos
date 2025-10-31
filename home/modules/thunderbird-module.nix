{ pkgs, lib, config, ... }:
{
  options = {
    thunderbird-module.enable = lib.mkEnableOption "Enables thunderbird";
  };

  config = lib.mkIf config.thunderbird-module.enable {
    programs.thunderbird = {
      enable = true;
  };
}