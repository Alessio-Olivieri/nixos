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
  config = lib.mkIf config.firefox-module.enable {
    programs.firefox = {
      enable = true;
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
          "treestyletab@piro.sakura.ne.jp" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/tree-style-tab/latest.xpi";
            installation_mode = "force_installed";
          };
          "uBlock0@raymondhill.net" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "force_installed";
          };
          "extension@tabliss.io" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/tabliss/latest.xpi";
            installation_mode = "force_installed";            
          }; 
          "@testpilot-containers" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/multi-account-containers/latest.xpi";
            installation_mode = "force_installed";    
          };
          "Tab-Session-Manager@sienori" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/tab-session-manager/latest.xpi";
            installation_mode = "force_installed";    
          };
          "addon@darkreader.org" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
            installation_mode = "force_installed";    
          };
          "tst-indent-line@piro.sakura.ne.jp" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/tst-indent-line/latest.xpi";
            installation_mode = "force_installed";   
          };
          "jid1-MnnxcxisBPnSXQ@jetpack" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/privacy-badger17/latest.xpi";
            installation_mode = "force_installed"; 
          };
          "FirefoxColor@mozilla.com" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/firefox-color/latest.xpi";
            installation_mode = "force_installed"; 
          };
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


