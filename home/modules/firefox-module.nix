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
  # in F12 search for "Add-on "{abcbde6d-57a1-45e3-9654-da805cf3568b}" not found so setting status to UNINSTALLED; exact error: Error: Addon not found"
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
        DontCheckDefaultBrowser = true;
        Preferences = {
            "toolkit.legacyUserProfileCustomizations.stylesheets" = lock-true;
            "layers.acceleration.force-enabled" = lock-true;
            "gfx.webrender.all" = lock-true;
            "gfx.webrender.enabled" = lock-true;
            "layout.css.backdrop-filter.enabled" = lock-true;
            "svg.context-properties.content.enabled" = lock-true;
            "widget.gtk.ignore-bogus-leave-notify" = lock-true;
        };
        /* ---- EXTENSIONS ---- */
        # Check about:support for extension/add-on ID strings.
        # Valid strings for installation_mode are "allowed", "blocked",
        # "force_installed" and "normal_installed".
        ExtensionSettings = {
          "*".installation_mode = "blocked"; # blocks all addons except the ones specified below
          #TreeStyleTab
          "treestyletab@piro.sakura.ne.jp" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/tree-style-tab/latest.xpi";
            installation_mode = "force_installed";
            private_browsing = lock-true;
          };
          "uBlock0@raymondhill.net" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "force_installed";
            private_browsing = lock-true;
          };
          "extension@tabliss.io" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/tabliss/latest.xpi";
            installation_mode = "force_installed";
            private_browsing = lock-true;            
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
            private_browsing = lock-true;    
          };
          "tst-indent-line@piro.sakura.ne.jp" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/tst-indent-line/latest.xpi";
            installation_mode = "force_installed";
            private_browsing = lock-true;   
          };
          "idcac-pub@guus.ninja" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/istilldontcareaboutcookies/latest.xpi";
            installation_mode = "force_installed"; 
            private_browsing = lock-true;
          };
          "jid1-MnnxcxisBPnSXQ@jetpack" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/privacy-badger17/latest.xpi";
            installation_mode = "force_installed";
            private_browsing = lock-true; 
          };
          "{9ed7d361-ccd9-4cad-9846-977da2651fb5}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/automatic-dark/latest.xpi";
            installation_mode = "force_installed";
            private_browsing = lock-true; 
          };
          "{c827c446-3d00-4160-a992-3ebcbe6d81a6}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/file/3990326/catppuccin_latte_mauve_git-2.0.xpi";
            installation_mode = "force_installed";
            private_browsing = lock-true;            
          };
          "{5ee380f7-abda-467c-ae9a-d30bf8f0d1d6}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/file/3990306/catppuccin_frappe_lavender-2.0.xpi";
            installation_mode = "force_installed";
            private_browsing = lock-true; 
          };
          "it-IT@dictionaries.addons.mozilla.org" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/dizionario-italiano/latest.xpi";
            installation_mode = "force_installed";
            private_browsing = lock-true; 
          };
          "{abcbde6d-57a1-45e3-9654-da805cf3568b}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/doqment/latest.xpi";
            installation_mode = "force_installed";
            private_browsing = lock-true; 
          };
        };
      };
      home.file.".mozilla/firefox/lexyo/chrome" = {
      source = ./submodules/chrome;
        recursive = true;
      };
    };
  };
}


