# /etc/nixos/gnome-theme-switcher.nix

{ config, pkgs, ... }:

let
  theme-switcher-script = pkgs.writeShellScriptBin "gnome-theme-switcher" ''
    #!${pkgs.bash}/bin/bash

    set -e

    # SapienzAAAAAAAAAAAAAA
    HARDCODED_LATITUDE="41.8905"
    HARDCODED_LONGITUDE="12.5127"

    # Set a user agent to identify the client to the BeaconDB service.
    USER_AGENT="NixOS-GNOME-Theme-Switcher/1.0"

    while true; do
      echo "Attempting to fetch location from BeaconDB with a 5-second timeout..."
      # We add '|| true' so the script doesn't exit if curl fails (because of 'set -e')
      location=$( ${pkgs.curl}/bin/curl --max-time 5 -X POST -A "$USER_AGENT" "https://api.beacondb.net/v1/geolocate" || true )

      # Check if the API call failed (empty response from timeout) or returned a known error.
      if [ -z "$location" ] || echo "$location" | grep -q "404 Not Found"; then
        echo "Could not fetch location from API. Using hardcoded fallback."
        latitude="$HARDCODED_LATITUDE"
        longitude="$HARDCODED_LONGITUDE"
      else
        # If we got a response, try to parse it.
        echo "Successfully fetched a response from the API."
        parsed_latitude=$(echo "$location" | ${pkgs.jq}/bin/jq '.location.lat')
        parsed_longitude=$(echo "$location" | ${pkgs.jq}/bin/jq '.location.lng')

        # Check if parsing succeeded. If not, use the fallback.
        if [ "$parsed_latitude" == "null" ] || [ "$parsed_longitude" == "null" ]; then
          echo "Could not parse location from API response. Using hardcoded fallback."
          latitude="$HARDCODED_LATITUDE"
          longitude="$HARDCODED_LONGITUDE"
        else
          echo "Successfully parsed location: Lat=$parsed_latitude, Lon=$parsed_longitude"
          latitude="$parsed_latitude"
          longitude="$parsed_longitude"
        fi
      fi

      # 1. Get the *actual* sunrise and sunset times from sunwait.
      actual_sunrise=$(${pkgs.sunwait}/bin/sunwait list rise "''${latitude}"N "''${longitude}"W | cut -d' ' -f1)
      actual_sunset=$(${pkgs.sunwait}/bin/sunwait list set "''${latitude}"N "''${longitude}"W | cut -d' ' -f1)

      # 2. Use the 'date' command to subtract 1 hour from each.
      #    The script will use these new 'sunrise' and 'sunset' variables for its logic.
      sunrise=$(date -d "$actual_sunrise + 3 hour" +%H:%M)
      sunset=$(date -d "$actual_sunset + 4 hour" +%H:%M)

      echo "Actual Times   -> Sunrise: $actual_sunrise, Sunset: $actual_sunset"

      current_time=$(date +%H%M)
      sunrise_time=$(echo "$sunrise" | sed 's/://')
      sunset_time=$(echo "$sunset" | sed 's/://')

      echo "Sunrise: $sunrise, Sunset: $sunset, Current time: $(date +%H:%M)"

      if [ "$current_time" -ge "$sunset_time" ] || [ "$current_time" -lt "$sunrise_time" ]; then
        echo "It is currently night. Switching to dark mode."
        ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
        sleep_duration=$(( $(date -d "$sunrise" +%s) - $(date +%s) ))
      else
        echo "It is currently day. Switching to light mode."
        ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
        sleep_duration=$(( $(date -d "$sunset" +%s) - $(date +%s) ))
      fi

      if [ "$sleep_duration" -lt 0 ]; then
        sleep_duration=$(( $sleep_duration + 86400 ))
      fi

      echo "Sleeping for $sleep_duration seconds."
      sleep "$sleep_duration"
      sleep 60
    done
  '';
in
{
  # This is where we define the systemd service and timer.
  # These settings will be merged into your main configuration.
  systemd.user.services.gnome-theme-switcher = {
    Unit = {
      Description = "Automatically switch GNOME theme based on sunrise and sunset using BeaconDB";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${theme-switcher-script}/bin/gnome-theme-switcher";
      Restart = "on-failure";
      RestartSec = "10s";
    };
  };

  systemd.user.timers.gnome-theme-switcher = {
    Unit = {
      Description = "Daily trigger for GNOME theme switcher";
    };
    Install = {
      WantedBy = [ "timers.target" ];
    };
    Timer = {
      OnCalendar = "daily";
      Persistent = true;
    };
  };
}