{ pkgs, lib, config, ... }:
{
  options = {
    vscode-module.enable = lib.mkEnableOption "Enables vscode";
  };

  config = lib.mkIf config.vscode-module.enable {
    programs.vscode = {
      enable = true;
      profiles.default = {
        extensions = with pkgs.vscode-extensions; [
          bbenoist.nix
          ms-python.debugpy
          ms-python.python
          ms-vscode-remote.remote-ssh
          yzhang.markdown-all-in-one
        ];
        userSettings = {
          ### Editor & UI ###
          "editor.minimap.enabled" = false;
          "window.autoDetectColorScheme" = true;
          "window.titleBarStyle" = "custom";
          "workbench.colorTheme" = "Catppuccin Frappé";
          "workbench.iconTheme" = "catppuccin-latte";
          "workbench.preferredDarkColorTheme" = "Catppuccin Frappé";
          "workbench.preferredLightColorTheme" = "Catppuccin Latte";

          ### Explorer (File Tree) ###
          "explorer.confirmDelete" = false;
          "explorer.confirmDragAndDrop" = false;
          "explorer.confirmPasteNative" = false;

          ### Git ###
          "git.enableSmartCommit" = true;
          "git.ignoreMissingGitWarning" = true;

          ### Python ###
          "python.analysis.extraPaths" = [
            "source"
            "../source"
          ];

          ### Remote - SSH ###
          "remote.SSH.showLoginTerminal" = true;

          ### Terminal ###
          "terminal.integrated.enableMultiLinePasteWarning" = false;
        };
      };
    };
  };
}