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
          ms-vscode.cpptools
          ms-vscode.cpptools
          ms-python.debugpy
          ms-python.python
          ms-python.vscode-pylance
          ms-toolsai.jupyter
          ms-toolsai.vscode-jupyter-cell-tags
          ms-toolsai.jupyter-keymap
          ms-toolsai.jupyter-renderers
          ms-toolsai.vscode-jupyter-slideshow
          ms-vscode-remote.remote-containers
          ms-vscode-remote.remote-ssh
          yzhang.markdown-all-in-one
          mechatroner.rainbow-csv
          catppuccin.catppuccin-vsc
          catppuccin.catppuccin-vsc-icons
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
          "editor.fontFamily" = ["JetBrainsMono Nerd Font" "monospace"];
          "editor.fontLigatures" = true;
        };
      };
    };
  };
}