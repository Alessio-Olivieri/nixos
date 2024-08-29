{ pkgs, lib, config, ... }:
{
    options = {
        vscpde-module.enable = lib.mkEnableOption "Enables vscode";
    };

    config = lib.mkIf config.vscode-module.enable {
          programs.vscode = {
            enable = true;
            extensions = with pkgs.vscode-extensions; [
            ms-python.python
            ms-python.debugpy
            bbenoist.nix
            ms-vscode-remote.remote-ssh
            ];
        };
    };
}