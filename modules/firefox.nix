{ config, pkgs, lib, inputs, ... }:
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
    firefox.enable = lib.mkEnableOption "Enables KDE Nix settings";
    };


    config = lib.mkIf config.firefox.enable {
        programs.firefox = {
        enable = true;
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        DisablePocket = true;
        OverrideFirstRunPage = "";
        OverridePostUpdatePage = "";
        Preferences = {
            "toolkit.legacyUserProfileCustomizations.stylesheets" = lock-true;
            "layers.acceleration.force-enabled" = lock-true;
            "gfx.webrender.all" = lock-true;
            "gfx.webrender.enabled" = lock-true;
            "layout.css.backdrop-filter.enabled" = lock-true;
            "svg.context-properties.content.enabled" = lock-true;
            "widget.gtk.ignore-bogus-leave-notify" = { Value = 1 ; Status = "locked"; };
            
        };
        };

    };
}


