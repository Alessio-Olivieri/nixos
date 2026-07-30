{ config, pkgs, lib, ... }:

let
  vaultPath = "/home/lexyo/Documents/SharedDocuments/Obsidian/Personal Vault";
  desktopConfigDir = ".obsidian-desktop";
  defaultConfigDir = ".obsidian";

  catppuccin-obsidian = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "obsidian";
    rev = "667e1a893086bc8dec1db32b97ed6b23fdfd5d83";
    hash = "sha256-fbPkZXlk+TTcVwSrt6ljpmvRL+hxB74NIEygl4ICm2U=";
  };

  obsidianLocalStoragePython = pkgs.python3.withPackages (ps: [ ps.plyvel ]);
in
{
  options = {
    obsidian-module.enable = lib.mkEnableOption "desktop-specific Obsidian configuration";
  };

  config = lib.mkIf config.obsidian-module.enable {
    home.activation.obsidianDesktopConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      set -euo pipefail

      vault_path="${vaultPath}"
      default_config="$vault_path/${defaultConfigDir}"
      desktop_config="$vault_path/${desktopConfigDir}"
      theme_dir="$desktop_config/themes/Catppuccin"
      obsidian_state="$HOME/.config/obsidian/obsidian.json"
      obsidian_local_storage="$HOME/.config/obsidian/Local Storage/leveldb"

      if [ ! -d "$desktop_config" ] && [ -d "$default_config" ]; then
        cp -a "$default_config" "$desktop_config"
        chmod -R u+w "$desktop_config"
      fi

      mkdir -p "$theme_dir"
      ln -sfn "${catppuccin-obsidian}/theme.css" "$theme_dir/theme.css"
      ln -sfn "${catppuccin-obsidian}/manifest.json" "$theme_dir/manifest.json"

      cat > "$desktop_config/appearance.json" <<'JSON'
{
  "theme": "obsidian",
  "cssTheme": "Catppuccin",
  "baseColorScheme": "dark"
}
JSON

      mkdir -p "$HOME/.config/obsidian"
      tmp="$(${pkgs.coreutils}/bin/mktemp)"

      if [ -f "$obsidian_state" ]; then
        ${pkgs.jq}/bin/jq \
          --arg vaultPath "$vault_path" \
          --arg configDir "${desktopConfigDir}" \
          '
            .vaults = (.vaults // {}) |
            if ([.vaults[]? | select(.path == $vaultPath)] | length) > 0 then
              .vaults |= with_entries(
                if .value.path == $vaultPath then
                  .value.configDir = $configDir
                else
                  .
                end
              )
            else
              .vaults."desktop-vault" = {
                path: $vaultPath,
                ts: 0,
                open: true,
                configDir: $configDir
              }
            end
          ' "$obsidian_state" > "$tmp"
      else
        ${pkgs.jq}/bin/jq -n \
          --arg vaultPath "$vault_path" \
          --arg configDir "${desktopConfigDir}" \
          '{
            vaults: {
              "desktop-vault": {
                path: $vaultPath,
                ts: 0,
                open: true,
                configDir: $configDir
              }
            }
          }' > "$tmp"
      fi

      mv "$tmp" "$obsidian_state"

      vault_id="$(${pkgs.jq}/bin/jq -er --arg vaultPath "$vault_path" '
        .vaults // {} |
        to_entries[] |
        select(.value.path == $vaultPath) |
        .key
      ' "$obsidian_state" | ${pkgs.coreutils}/bin/head -n 1)"

      mkdir -p "$obsidian_local_storage"
      OBSIDIAN_LOCAL_STORAGE_DIR="$obsidian_local_storage" \
      OBSIDIAN_VAULT_ID="$vault_id" \
      OBSIDIAN_CONFIG_DIR="${desktopConfigDir}" \
      ${obsidianLocalStoragePython}/bin/python <<'PY'
import os
import sys

import plyvel

db_path = os.environ["OBSIDIAN_LOCAL_STORAGE_DIR"]
vault_id = os.environ["OBSIDIAN_VAULT_ID"]
config_dir = os.environ["OBSIDIAN_CONFIG_DIR"]

key = b"_app://obsidian.md\x00\x01" + vault_id.encode("utf-8") + b"-config"
value = b"\x01" + config_dir.encode("utf-8")

try:
    db = plyvel.DB(db_path, create_if_missing=True)
except Exception as exc:
    print(
        "warning: could not update Obsidian config-folder override; "
        f"close Obsidian and run home-manager/nixos switch again: {exc}",
        file=sys.stderr,
    )
    sys.exit(0)

try:
    if db.get(b"VERSION") is None:
        db.put(b"VERSION", b"1")
    db.put(key, value)
finally:
    db.close()
PY
    '';
  };
}
