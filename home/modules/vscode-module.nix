{ pkgs, lib, config, ... }:
{
  options = {
    vscode-module.enable = lib.mkEnableOption "Enables vscode";
  };

  config = lib.mkIf config.vscode-module.enable {
    programs.vscode = {
      enable = true;
      mutableExtensionsDir = false;
      extensions = with pkgs.vscode-extensions; [
          # arrterian.nix-env-selector
          mkhl.direnv
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
    };

    # This section creates a symlink to a writable settings.json file. [1]
    # This allows you to edit your VSCode settings directly, and the changes
    # will persist and can be committed to your configuration repository.
    # The path is for standard VSCode on Linux. If you use VSCodium, change
    # ".config/Code/User/settings.json" to ".config/VSCodium/User/settings.json".
    home.file.".config/Code/User/settings.json".source = lib.mkForce (
      # IMPORTANT: You must replace the path below with the absolute path
      # to your own vscode-settings.json file.
      config.lib.file.mkOutOfStoreSymlink "/etc/nixos/home/modules/sub/vscode-settings.json"
    );
  };
}