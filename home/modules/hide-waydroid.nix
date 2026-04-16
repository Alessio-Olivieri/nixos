{ config, pkgs, lib, ... }:

{
  home.activation.hideWaydroidApps = lib.hm.dag.entryAfter ["writeBoundary"] ''
    APP_DIR="$HOME/.local/share/applications"
    
    if [ -d "$APP_DIR" ]; then
      echo "Processing Waydroid apps..."

      for file in "$APP_DIR"/waydroid.*.desktop; do
        # 1. Fix the "Nuclear" attempt: 
        # If it is a symlink (to /dev/null), delete it so Waydroid can regenerate it cleanly
        if [ -L "$file" ]; then
          rm "$file"
          echo "Removed broken symlink: $file"
          continue
        fi
        
        # Check if file exists (it might have just been deleted)
        [ -e "$file" ] || continue

        # 2. Handle FEEDER (Keep Visible)
        if [[ "$file" =~ [Ff]eeder ]]; then
          chmod u+w "$file"
          # Remove any NoDisplay line found anywhere in the file
          ${pkgs.gnused}/bin/sed -i '/NoDisplay=true/d' "$file"
          continue
        fi
        if [[ "$file" =~ [Pp]ipe[Pp]ipe ]]; then
          chmod u+w "$file"
          # Remove any NoDisplay line found anywhere in the file
          ${pkgs.gnused}/bin/sed -i '/NoDisplay=true/d' "$file"
          continue
        fi

        # 3. Handle OTHER APPS (Hide)
        chmod u+w "$file"

        # Step A: Remove misplaced NoDisplay=true (from previous attempts at bottom of file)
        ${pkgs.gnused}/bin/sed -i '/NoDisplay=true/d' "$file"

        # Step B: Insert NoDisplay=true specifically under [Desktop Entry]
        # This forces it to the top where GNOME actually reads it
        ${pkgs.gnused}/bin/sed -i '/^\[Desktop Entry\]/a NoDisplay=true' "$file"
        
        echo "Hidden correctly: $file"
      done

      # 4. Update Database
      ${pkgs.desktop-file-utils}/bin/update-desktop-database "$APP_DIR"
    fi
  '';
}