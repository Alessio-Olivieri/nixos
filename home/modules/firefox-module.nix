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
    firefox-module.enable = lib.mkEnableOption "Enables Firefox Nix settings";
  };
  config = lib.mkIf config.firefox.enable {
    programs.firefox = {
      enable = true;
      profiles.default.chrome = ./sub/chrome;
      policies = {
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        EnableTrackingProtection = {
          Value= true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };
        DisablePocket = true;
        OverrideFirstRunPage = "";
        OverridePostUpdatePage = "";
        /* ---- EXTENSIONS ---- */
        # Check about:support for extension/add-on ID strings.
        # Valid strings for installation_mode are "allowed", "blocked",
        # "force_installed" and "normal_installed".
        ExtensionSettings = {
          "*".installation_mode = "blocked"; # blocks all addons except the ones specified below
        };

        Preferences = {
            "toolkit.legacyUserProfileCustomizations.stylesheets" = lock-true;
            "layers.acceleration.force-enabled" = lock-true;
            "gfx.webrender.all" = lock-true;
            "gfx.webrender.enabled" = lock-true;
            "layout.css.backdrop-filter.enabled" = lock-true;
            "svg.context-properties.content.enabled" = lock-true;
            "widget.gtk.ignore-bogus-leave-notify" = lock-true;
        };
      };
    };
  };
}


