{ pkgs, lib, config, ... }:
let
  lock-false = {
    Value = false;
    Status = "locked";
  };
  lock-true = {
    Value = true;
    Status = "locked";
  };
in
{
  options = {
    thunderbird-module.enable = lib.mkEnableOption "Enables thunderbird";
  };

  config = lib.mkIf config.thunderbird-module.enable {
    programs.thunderbird = {
      enable=true;
      profiles."lexyo" = {
        isDefault = true;
        extensions = [];
        settings={
          "privacy.donottrackheader.enabled" = true;
          "extensions.autoDisableScopes" = 0;
        };
      };
    };
  };
}