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

            login-leonardo = "ssh -i ~/.step/certs/my_key aolivie1@login.leonardo.cineca.it";
            leonardo-setup-step = ''step ca bootstrap --ca-url=https://sshproxy.hpc.cineca.it --fingerprint 2ae1543202304d3f434bdc1a2c92eff2cd2b02110206ef06317e70c1c1735ecd '';
            leonardo-certificate = ''step ssh certificate olivieri.1973323@studenti.uniroma1.it --provisioner cineca-hpc ~/.step/certs/my_key'';
            leonardo-certificate-troubleshoot = ''
            ssh aolivie1@login01-ext.leonardo.cineca.it -o hashknownhosts=no
            ssh aolivie1@login02-ext.leonardo.cineca.it -o hashknownhosts=no
            ssh aolivie1@login05-ext.leonardo.cineca.it -o hashknownhosts=no
            ssh aolivie1@login07-ext.leonardo.cineca.it -o hashknownhosts=no
            '';




            };
        };
    };
}