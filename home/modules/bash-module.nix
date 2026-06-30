{ pkgs, lib, config, ... }:
{
  options = {
    bash-module.enable = lib.mkEnableOption "Enables bash";
  };

  config = lib.mkIf config.bash-module.enable {
    home.packages = with pkgs; [
      repomix
    ];

    programs.bash = {
      enable = true;
      enableCompletion = true;

      bashrcExtra = ''
        export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin:$HOME/.pixi/bin";
      '';

      initExtra = ''
        if ! pgrep -u "$USER" ssh-agent >/dev/null; then
          eval "$(ssh-agent -s)" >/dev/null 2>&1
        fi
        ssh-add ~/.ssh/github/key </dev/null >/dev/null 2>&1
        ssh-add ~/.ssh/tensordock/key </dev/null >/dev/null 2>&1

        if command -v pixi > /dev/null; then
          eval "$(pixi completion --shell bash)"
        fi

        repo2text() {
          local target

          if [ "$#" -gt 0 ]; then
            target="$1"
            shift
          else
            target="."
          fi

          repomix "$target" \
            --stdout \
            --style markdown \
            --output-show-line-numbers \
            --ignore ".git/**,result/**,result-*,.direnv/**,.devenv/**,node_modules/**,*.iso,*.img,*.qcow2,*.zip,*.tar,*.tar.gz,*.7z,*.png,*.jpg,*.jpeg,*.webp,*.pdf" \
            "$@"
        }
      '';

      shellAliases = {
        urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
        urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";

        dconf-update = "dconf dump / | dconf2nix > /etc/nixos/home/modules/submodules/dconf.nix";
      };
    };

    programs.zoxide = {
      enable = true;
      enableBashIntegration = true;
      options = [
        "--cmd cd"
      ];
    };
  };
}