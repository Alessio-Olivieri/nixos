{ pkgs, lib, config, ... }:
{
    options = {
        nvim-manager.enable = lib.mkEnableOption "Enables nvim";
    };

    config = lib.mkIf config.nvim-manager.enable {


        programs.neovim = {     

        enable = true;
        viAlias = true;
        vimAlias = true;
        extraConfig = ''
            set number relativenumber
        '';
        plugins = [
            pkgs.vimPlugins.nvim-tree-lua
            {
                plugin = pkgs.vimPlugins.vim-startify;
                config = "let g:startify_change_to_vcs_root = 0";
            }
        ];
        
        };


    };
}