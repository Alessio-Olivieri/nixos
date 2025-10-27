# /etc/nixos/gnome-theme-switcher.nix

{ config, pkgs, ... }:

let
  theme-switcher-script = pkgs.writeShellScriptBin "gnome-theme-switcher" ''
    #!${pkgs.bash}/bin/bash

    set -e

    # Set a user agent to identify the client to the BeaconDB service.
    USER_AGENT="NixOS-GNOME-Theme-Switcher/1.0"

    get_location() {
      ${pkgs.curl}/bin/curl -X POST -A "$USER_AGENT" "https://api.beacondb.net/v1/geolocate"
    }

    while true; do
      echo "Determining location and sun times from BeaconDB..."
      location=$(get_location)
      
      # The API returns a 404 if a location cannot be determined.
      if echo "$location" | grep -q "404 Not Found"; then
        echo "Could not determine location. Retrying in 15 minutes."
        sleep 900
        continue
      fi

      latitude=$(echo "$location" | ${pkgs.jq}/bin/jq '.location.lat')
      longitude=$(echo "$location" | ${pkgs.jq}/bin/jq '.location.lng')

      if [ -z "$latitude" ] || [ -z "$longitude" ] || [ "$latitude" == "null" ] || [ "$longitude" == "null" ]; then
        echo "Could not parse location from API response. Retrying in 15 minutes."
        sleep 900
        continue
      fi

      sunrise=$(${pkgs.sunwait}/bin/sunwait list rise "''${latitude}"N "''${longitude}"W | cut -d' ' -f1)
      sunset=$(${pkgs.sunwait}/bin/sunwait list set "''${latitude}"N "''${longitude}"W | cut -d' ' -f1)

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