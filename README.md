Configuration file for my laptop

ASUS TUF Gaming A16 FA608UP (240 W adapter, Italian keyboard):
see [setup and feature guide](hosts/asus-fa608up/README.md), then use
`sudo nixos-rebuild build --flake .#asus-fa608up`.
The guide includes a helper to collect this laptop's disk configuration and GPU
addresses before the first build.

Precision 7560, including Windows Gaming/Light and automatic guest integration:

```sh
sudo nixos-rebuild switch --flake /etc/nixos#precision
```

See [WINDOWS-GUIDE.md](WINDOWS-GUIDE.md) for usage and preserved Windows prerequisites.

sudo nixos-rebuild switch --flake .#nixos
sudo nixos-rebuild switch --flake .#msi-laptop
