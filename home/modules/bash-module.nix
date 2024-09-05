{ pkgs, lib, config, ... }:
{
    options = {
        bash-module.enable = lib.mkEnableOption "Enables bash";
    };

    config = lib.mkIf config.bash-module.enable {
        programs.bash = {
            enable = true;
            enableCompletion = true;
            # TODO add your custom bashrc here
            bashrcExtra = ''
            export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
            '';

            initExtra = '' 
            eval `ssh-agent`
            ssh-add ~/.ssh/id_ed25519;        
            '';

            # set some aliases, feel free to add more or remove some
            shellAliases = {
            urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
            urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
            dconf-update = "dconf dump / | dconf2nix > /etc/nixos/home/modules/sub/dconf.nix";
            };
        };
    };
}