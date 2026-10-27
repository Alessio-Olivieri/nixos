
{ pkgs, lib, config, ... }:

let
  # Open Zellij scrollback directly in VSCodium.
  scrollbackEditor = pkgs.writeShellScriptBin
    "zellij-scrollback-editor" ''
      exec ${pkgs.vscodium}/bin/codium --wait "$@"
    '';
in
{
  options.zellij-module.enable =
    lib.mkEnableOption "Zellij terminal workspace";

  config = lib.mkIf config.zellij-module.enable {

    programs.zellij = {
      enable = true;

      # Bash is already configured in bash-module.nix.
      # Don't automatically start Zellij in every shell.
      enableBashIntegration = false;

      settings = {
        # Appearance
        theme = "catppuccin-frappe";
        pane_frames = true;
        simplified_ui = false;
        show_startup_tips = false;

        # Mouse and scrollback
        mouse_mode = true;
        scroll_buffer_size = 30000;
        copy_on_select = true;

        # Native Wayland clipboard
        copy_command = "${pkgs.wl-clipboard}/bin/wl-copy";

        # Open scrollback in VSCodium
        scrollback_editor =
          "${scrollbackEditor}/bin/zellij-scrollback-editor";

        # Sessions
        on_force_close = "detach";
        session_serialization = true;
        pane_viewport_serialization = false;

        # Start in regular keyboard mode
        default_mode = "normal";
      };


layouts.codex = ''
  layout {
    default_tab_template {
      children
      pane size=1 borderless=true {
        plugin location="zellij:compact-bar"
      }
    }

    tab name="Codex" focus=true {
      pane split_direction="vertical" {
        pane size="65%" name="Codex" command="codex" start_suspended=true

        pane size="35%" split_direction="horizontal" {
          pane name="Tests"
          pane name="Logs"
        }
      }
    }

    tab name="Shell" {
      pane
    }
  }
'';
    };


    # Start or reattach to a project workspace.
    programs.bash.initExtra = ''
      zj() {
        local name="''${1:-$(basename "$PWD")}"
        zellij attach -c "$name" options --default-layout codex
      }
    '';
  };
}
