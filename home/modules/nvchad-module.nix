{ pkgs, lib, config, inputs, ... }:
{
    options = {
        nvchad-module.enable = lib.mkEnableOption "Enables nvchad";
    };

    config = lib.mkIf config.nvchad-module.enable {
        programs.nvchad = {
            enable = true;
            extraPackages = with pkgs; [
            nodePackages.bash-language-server
            docker-compose-language-service
            dockerfile-language-server-nodejs
            emmet-language-server
            nixd
            (python3.withPackages(ps: with ps; [
                python-lsp-server
                flake8
            ]))
            ];
            hm-activation = true;
            backup = true;
        };

    };
}