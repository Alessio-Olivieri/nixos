{ pkgs, lib, config, ... }:
{
  options = {
    vscode-module.enable = lib.mkEnableOption "Enables vscode";
  };

  config = lib.mkIf config.vscode-module.enable {
    programs.vscode = {
      enable = true;
      package = pkgs.vscodium;
      mutableExtensionsDir = true;
      extensions = with pkgs; [
        # arrterian.nix-env-selector
        
        open-vsx.kylinideteam.kylin-clangd
        open-vsx.kylinideteam.cppdebug
        open-vsx.kylinideteam.kylin-cmake-tools
        open-vsx.jajera.vsx-remote-ssh
        open-vsx.jeanp413.open-remote-ssh



        # ms-vscode-remote.remote-containers
        # ms-vscode-remote.remote-ssh
        vscode-extensions.mkhl.direnv
        vscode-extensions.bbenoist.nix

        #3timeslazy.vscodium-devpodcontainers
        # open-vsx.jeanp413.open-remote-ssh
        open-vsx.nerditation.open-remote-distrobox
        # open-vsx."3timeslazy".vscodium-devpodcontainers
        vscode-extensions.yzhang.markdown-all-in-one
        vscode-extensions.mechatroner.rainbow-csv
        vscode-extensions.catppuccin.catppuccin-vsc
        vscode-extensions.catppuccin.catppuccin-vsc-icons
      ]; 
    };

    home.file.".vscode-oss/argv.json".source = lib.mkForce (
      # IMPORTANT: You must replace the path below with the absolute path
      # to your own vscode-settings.json file.
      config.lib.file.mkOutOfStoreSymlink "/etc/nixos/home/modules/submodules/argv-vscodium.json"
    );

    # This section creates a symlink to a writable settings.json file. [1]
    # This allows you to edit your VSCode settings directly, and the changes
    # will persist and can be committed to your configuration repository.
    # The path is for standard VSCode on Linux. If you use VSCodium, change
    # ".config/Code/User/settings.json" to ".config/VSCodium/User/settings.json".
    home.file.".config/Code/User/settings.json".source = lib.mkForce (
      # IMPORTANT: You must replace the path below with the absolute path
      # to your own vscode-settings.json file.
      config.lib.file.mkOutOfStoreSymlink "/etc/nixos/home/modules/submodules/vscode-settings.json"
    );
    home.file.".config/VSCodium/User/settings.json".source = lib.mkForce (
      # IMPORTANT: You must replace the path below with the absolute path
      # to your own vscode-settings.json file.
      config.lib.file.mkOutOfStoreSymlink "/etc/nixos/home/modules/submodules/vscode-settings.json"
    );
  };
}