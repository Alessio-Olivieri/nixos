# Generated via dconf2nix: https://github.com/gvolpe/dconf2nix
{ lib, ... }:

with lib.hm.gvariant;

{
  dconf.settings = {
    "ca/desrt/dconf-editor" = {
      saved-pathbar-path = "/org/gnome/shell/extensions/";
      saved-view = "/";
      show-warning = false;
      window-height = 1001;
      window-is-maximized = false;
      window-width = 1146;
    };

    "it/mijorus/smile" = {
      is-first-run = false;
      last-run-version = "2.10.1";
    };

    "org/gnome/Connections" = {
      first-run = false;
    };

    "org/gnome/Console" = {
      font-scale = 1.1;
      last-window-maximised = false;
      last-window-size = mkTuple [ 1200 1048 ];
    };

    "org/gnome/Disks" = {
      image-dir-uri = "file:///home/lexyo/Documents";
    };

    "org/gnome/Extensions" = {
      window-height = 1080;
      window-maximized = false;
      window-width = 955;
    };

    "org/gnome/Geary" = {
      compose-as-html = true;
      formatting-toolbar-visible = false;
      migrated-config = true;
      window-height = 1048;
      window-maximize = false;
      window-width = 1440;
    };

    "org/gnome/Snapshot" = {
      capture-mode = "video";
      is-maximized = false;
      window-height = 1048;
      window-width = 800;
    };

    "org/gnome/TextEditor" = {
      last-save-directory = "file:///home/lexyo";
    };

    "org/gnome/Totem" = {
      active-plugins = [ "rotation" "skipto" "open-directory" "vimeo" "save-file" "mpris" "apple-trailers" "recent" "screenshot" "variable-rate" "movie-properties" "autoload-subtitles" "screensaver" ];
      subtitle-encoding = "UTF-8";
    };

    "org/gnome/baobab/ui" = {
      is-maximized = false;
      window-size = mkTuple [ 960 1040 ];
    };

    "org/gnome/calculator" = {
      accuracy = 9;
      angle-units = "degrees";
      base = 10;
      button-mode = "advanced";
      number-format = "automatic";
      show-thousands = false;
      show-zeroes = false;
      source-currency = "";
      source-units = "degree";
      target-currency = "";
      target-units = "radian";
      window-maximized = false;
      window-size = mkTuple [ 700 1048 ];
      word-size = 64;
    };

    "org/gnome/calendar" = {
      active-view = "month";
      week-view-zoom-level = 1.0;
      window-maximized = false;
      window-size = mkTuple [ 1898 1028 ];
    };

    "org/gnome/clocks/state/window" = {
      maximized = false;
      panel-id = "stopwatch";
      size = mkTuple [ 870 1080 ];
    };

    "org/gnome/control-center" = {
      last-panel = "system";
      window-state = mkTuple [ 1440 1048 false ];
    };

    "org/gnome/desktop/app-folders" = {
      folder-children = [ "Utilities" "YaST" "Pardus" "2f1b3f8e-78cc-4d47-b225-be36d58bcd33" ];
    };

    "org/gnome/desktop/app-folders/folders/2f1b3f8e-78cc-4d47-b225-be36d58bcd33" = {
      apps = [ "org.kicad.gerbview.desktop" "org.kicad.kicad.desktop" "org.kicad.bitmap2component.desktop" "org.kicad.pcbcalculator.desktop" "org.kicad.pcbnew.desktop" "org.kicad.eeschema.desktop" ];
      name = "kicad";
      translate = false;
    };

    "org/gnome/desktop/app-folders/folders/Pardus" = {
      categories = [ "X-Pardus-Apps" ];
      name = "X-Pardus-Apps.directory";
      translate = true;
    };

    "org/gnome/desktop/app-folders/folders/Utilities" = {
      apps = [ "gnome-abrt.desktop" "gnome-system-log.desktop" "nm-connection-editor.desktop" "org.gnome.baobab.desktop" "org.gnome.Connections.desktop" "org.gnome.DejaDup.desktop" "org.gnome.Dictionary.desktop" "org.gnome.DiskUtility.desktop" "org.gnome.Evince.desktop" "org.gnome.FileRoller.desktop" "org.gnome.fonts.desktop" "org.gnome.Loupe.desktop" "org.gnome.seahorse.Application.desktop" "org.gnome.tweaks.desktop" "org.gnome.Usage.desktop" "vinagre.desktop" ];
      categories = [ "X-GNOME-Utilities" ];
      name = "X-GNOME-Utilities.directory";
      translate = true;
    };

    "org/gnome/desktop/app-folders/folders/YaST" = {
      categories = [ "X-SuSE-YaST" ];
      name = "suse-yast.directory";
      translate = true;
    };

    "org/gnome/desktop/background" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file:///home/lexyo/.local/share/backgrounds/2025-06-05-16-15-21-Background.png";
      picture-uri-dark = "file:///home/lexyo/.local/share/backgrounds/2025-06-05-16-15-21-Background.png";
      primary-color = "#000000000000";
      secondary-color = "#000000000000";
    };

    "org/gnome/desktop/break-reminders" = {
      selected-breaks = [];
    };

    "org/gnome/desktop/break-reminders/eyesight" = {
      play-sound = true;
    };

    "org/gnome/desktop/break-reminders/movement" = {
      duration-seconds = mkUint32 300;
      interval-seconds = mkUint32 1800;
      play-sound = true;
    };

    "org/gnome/desktop/datetime" = {
      automatic-timezone = false;
    };

    "org/gnome/desktop/default-applications/terminal" = {
      exec = "ghostty";
      exec-arg = "--";
    };

    "org/gnome/desktop/input-sources" = {
      mru-sources = [ (mkTuple [ "xkb" "it" ]) ];
      sources = [ (mkTuple [ "xkb" "it" ]) ];
      xkb-options = [ "terminate:ctrl_alt_bksp" ];
    };

    "org/gnome/desktop/interface" = {
      accent-color = "purple";
      clock-show-weekday = false;
      color-scheme = "default";
      enable-animations = true;
      enable-hot-corners = false;
      show-battery-percentage = true;
    };

    "org/gnome/desktop/notifications" = {
      application-children = [ "org-gnome-baobab" "gnome-power-panel" "firefox" ];
    };

    "org/gnome/desktop/notifications/application/code-url-handler" = {
      application-id = "code-url-handler.desktop";
    };

    "org/gnome/desktop/notifications/application/code" = {
      application-id = "code.desktop";
    };

    "org/gnome/desktop/notifications/application/com-nextcloud-desktopclient-nextcloud" = {
      application-id = "com.nextcloud.desktopclient.nextcloud.desktop";
    };

    "org/gnome/desktop/notifications/application/discord" = {
      application-id = "discord.desktop";
    };

    "org/gnome/desktop/notifications/application/filezilla" = {
      application-id = "filezilla.desktop";
    };

    "org/gnome/desktop/notifications/application/firefox" = {
      application-id = "firefox.desktop";
    };

    "org/gnome/desktop/notifications/application/gimp" = {
      application-id = "gimp.desktop";
    };

    "org/gnome/desktop/notifications/application/gnome-power-panel" = {
      application-id = "gnome-power-panel.desktop";
    };

    "org/gnome/desktop/notifications/application/gnome-wellbeing-panel" = {
      application-id = "gnome-wellbeing-panel.desktop";
    };

    "org/gnome/desktop/notifications/application/it-mijorus-smile" = {
      application-id = "it.mijorus.smile.desktop";
    };

    "org/gnome/desktop/notifications/application/onlyoffice-desktopeditors" = {
      application-id = "onlyoffice-desktopeditors.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-baobab" = {
      application-id = "org.gnome.baobab.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-clocks" = {
      application-id = "org.gnome.clocks.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-console" = {
      application-id = "org.gnome.Console.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-evince" = {
      application-id = "org.gnome.Evince.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-evolution-alarm-notify" = {
      application-id = "org.gnome.Evolution-alarm-notify.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-extensions" = {
      application-id = "org.gnome.Extensions.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-fileroller" = {
      application-id = "org.gnome.FileRoller.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-geary" = {
      application-id = "org.gnome.Geary.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-loupe" = {
      application-id = "org.gnome.Loupe.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-nautilus" = {
      application-id = "org.gnome.Nautilus.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-settings" = {
      application-id = "org.gnome.Settings.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-shell-extensions-gsconnect" = {
      application-id = "org.gnome.Shell.Extensions.GSConnect.desktop";
    };

    "org/gnome/desktop/notifications/application/org-kde-kdeconnect-daemon" = {
      application-id = "org.kde.kdeconnect.daemon.desktop";
    };

    "org/gnome/desktop/notifications/application/org-kde-okular" = {
      application-id = "org.kde.okular.desktop";
    };

    "org/gnome/desktop/notifications/application/org-telegram-desktop" = {
      application-id = "org.telegram.desktop.desktop";
    };

    "org/gnome/desktop/notifications/application/slack" = {
      application-id = "slack.desktop";
    };

    "org/gnome/desktop/notifications/application/zen" = {
      application-id = "zen.desktop";
    };

    "org/gnome/desktop/notifications/application/zoom" = {
      application-id = "Zoom.desktop";
    };

    "org/gnome/desktop/peripherals/keyboard" = {
      numlock-state = true;
    };

    "org/gnome/desktop/peripherals/mouse" = {
      accel-profile = "flat";
      speed = -0.244635;
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      disable-while-typing = false;
      send-events = "enabled";
      two-finger-scrolling-enabled = true;
    };

    "org/gnome/desktop/privacy" = {
      old-files-age = mkUint32 30;
      recent-files-max-age = -1;
    };

    "org/gnome/desktop/screensaver" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file:///home/lexyo/.local/share/backgrounds/2025-06-05-16-15-21-Background.png";
      primary-color = "#000000000000";
      secondary-color = "#000000000000";
    };

    "org/gnome/desktop/search-providers" = {
      sort-order = [ "org.gnome.Contacts.desktop" "org.gnome.Documents.desktop" "org.gnome.Nautilus.desktop" ];
    };

    "org/gnome/desktop/session" = {
      idle-delay = mkUint32 300;
    };

    "org/gnome/desktop/sound" = {
      allow-volume-above-100-percent = false;
    };

    "org/gnome/desktop/wm/keybindings" = {
      maximize = [];
      minimize = [];
      move-to-monitor-down = [];
      move-to-monitor-left = [];
      move-to-monitor-right = [];
      move-to-monitor-up = [];
      move-to-workspace-down = [];
      move-to-workspace-left = [];
      move-to-workspace-right = [];
      move-to-workspace-up = [];
      switch-applications = [];
      switch-applications-backward = [];
      switch-group = [];
      switch-group-backward = [];
      switch-panels = [];
      switch-panels-backward = [];
      switch-to-workspace-1 = [];
      switch-to-workspace-last = [];
      switch-to-workspace-left = [];
      switch-to-workspace-right = [];
      unmaximize = [];
    };

    "org/gnome/desktop/wm/preferences" = {
      num-workspaces = 5;
      workspace-names = [ "Resilient" "Wise" "Chaotic" "Ferocius" "Tyrannical" "Perfectionist" "Determined" "Unstoppable" ];
    };

    "org/gnome/evince/default" = {
      continuous = true;
      dual-page = false;
      dual-page-odd-left = true;
      enable-spellchecking = true;
      fullscreen = false;
      inverted-colors = false;
      show-sidebar = false;
      sidebar-page = "thumbnails";
      sidebar-size = 148;
      sizing-mode = "free";
      window-ratio = mkTuple [ 3.137255 1.323232 ];
      zoom = 0.856153;
    };

    "org/gnome/evolution-data-server" = {
      migrated = true;
    };

    "org/gnome/evolution-data-server/calendar" = {
      reminders-past = [];
    };

    "org/gnome/evolution" = {
      default-calendar = "91ff4201a761d4658ba70bfd9a3f55745b6f0922";
    };

    "org/gnome/file-roller/dialogs/extract" = {
      height = 800;
      recreate-folders = true;
      skip-newer = false;
      width = 1000;
    };

    "org/gnome/file-roller/file-selector" = {
      show-hidden = false;
      sidebar-size = 300;
      sort-method = "name";
      sort-type = "ascending";
      window-size = mkTuple [ (-1) (-1) ];
    };

    "org/gnome/file-roller/listing" = {
      list-mode = "as-folder";
      name-column-width = 280;
      show-path = false;
      sort-method = "name";
      sort-type = "ascending";
    };

    "org/gnome/file-roller/ui" = {
      sidebar-width = 200;
      window-height = 1048;
      window-width = 830;
    };

    "org/gnome/gitlab/somas/Apostrophe" = {
      color-scheme = "system";
      hemingway-mode = false;
      hemingway-toast-count = 1;
      input-format = "markdown";
      open-file-path = "/home/lexyo/Nextcloud/Notes";
      preview-active = false;
      preview-mode = "half-width";
      preview-security = "ask";
      spellcheck = false;
      toolbar-active = false;
    };

    "org/gnome/gnome-system-monitor" = {
      current-tab = "resources";
      maximized = false;
      show-dependencies = false;
      show-whose-processes = "user";
      window-height = 1048;
      window-width = 874;
    };

    "org/gnome/gnome-system-monitor/disktreenew" = {
      col-6-visible = true;
      col-6-width = 0;
    };

    "org/gnome/gnome-system-monitor/proctree" = {
      col-26-visible = false;
      col-26-width = 0;
      columns-order = [ 0 1 2 3 4 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 ];
      sort-col = 26;
      sort-order = 0;
    };

    "org/gnome/maps" = {
      last-viewed-location = [ 40.542167 10.656517 ];
      map-type = "MapsStreetSource";
      transportation-type = "pedestrian";
      window-maximized = false;
      window-size = [ 1898 1048 ];
      zoom-level = 4;
    };

    "org/gnome/mutter" = {
      attach-modal-dialogs = false;
      dynamic-workspaces = false;
      edge-tiling = false;
      workspaces-only-on-primary = false;
    };

    "org/gnome/mutter/keybindings" = {
      cancel-input-capture = [];
      toggle-tiled-left = [];
      toggle-tiled-right = [];
    };

    "org/gnome/mutter/wayland/keybindings" = {
      restore-shortcuts = [];
    };

    "org/gnome/nautilus/compression" = {
      default-compression-format = "tar.xz";
    };

    "org/gnome/nautilus/icon-view" = {
      captions = [ "none" "none" "none" ];
      default-zoom-level = "small";
    };

    "org/gnome/nautilus/list-view" = {
      default-zoom-level = "small";
      use-tree-view = true;
    };

    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "list-view";
      migrated-gtk-settings = true;
      search-filter-time-type = "last_modified";
    };

    "org/gnome/nautilus/window-state" = {
      initial-size = mkTuple [ 1440 1048 ];
      initial-size-file-chooser = mkTuple [ 890 550 ];
      maximized = false;
    };

    "org/gnome/nm-applet/eap/1073068d-dc26-4f89-baf8-93f87bd92f2f" = {
      ignore-ca-cert = true;
      ignore-phase2-ca-cert = false;
    };

    "org/gnome/nm-applet/eap/6c647994-1737-4261-b607-c926e4120716" = {
      ignore-ca-cert = false;
      ignore-phase2-ca-cert = false;
    };

    "org/gnome/nm-applet/eap/8a24c358-b7d5-40f2-9e66-81f824c20f06" = {
      ignore-ca-cert = false;
      ignore-phase2-ca-cert = false;
    };

    "org/gnome/nm-applet/eap/f6dad3c9-a6de-4aa5-992d-4d3367d69440" = {
      ignore-ca-cert = false;
      ignore-phase2-ca-cert = false;
    };

    "org/gnome/portal/filechooser/brave-browser" = {
      last-folder-path = "/home/lexyo/Documents";
    };

    "org/gnome/portal/filechooser/code" = {
      last-folder-path = "/etc/nixos";
    };

    "org/gnome/portal/filechooser/discord" = {
      last-folder-path = "/home/lexyo/Dev/thesis";
    };

    "org/gnome/portal/filechooser/obsidian" = {
      last-folder-path = "/home/lexyo/Nextcloud/ObsidianVault";
    };

    "org/gnome/portal/filechooser/org/gnome/gitlab/somas/Apostrophe" = {
      last-folder-path = "/home/lexyo/Nextcloud/Notes";
    };

    "org/gnome/portal/filechooser/org/gnome/Settings" = {
      last-folder-path = "/etc/nixos/files/wallpapers/Dragonball";
    };

    "org/gnome/portal/filechooser/slack" = {
      last-folder-path = "/home/lexyo/Pictures/Screenshots";
    };

    "org/gnome/settings-daemon/plugins/color" = {
      night-light-enabled = false;
      night-light-schedule-automatic = false;
      night-light-temperature = mkUint32 3509;
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [ "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/" ];
      help = [ "<Alt>f" ];
      rotate-video-lock-static = [];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Control>comma";
      command = "smile";
      name = "smile";
    };

    "org/gnome/settings-daemon/plugins/power" = {
      idle-dim = true;
      power-button-action = "hibernate";
      sleep-inactive-ac-timeout = 1200;
      sleep-inactive-ac-type = "suspend";
      sleep-inactive-battery-timeout = 900;
      sleep-inactive-battery-type = "nothing";
    };

    "org/gnome/settings-daemon/plugins/sharing/gnome-user-share-webdav" = {
      enabled-connections = [];
    };

    "org/gnome/shell" = {
      command-history = [ "kg" "lg" ];
      disable-user-extensions = false;
      disabled-extensions = [ "auto-move-windows@gnome-shell-extensions.gcampax.github.com" "places-menu@gnome-shell-extensions.gcampax.github.com" "windowsNavigator@gnome-shell-extensions.gcampax.github.com" "apps-menu@gnome-shell-extensions.gcampax.github.com" "launch-new-instance@gnome-shell-extensions.gcampax.github.com" "light-style@gnome-shell-extensions.gcampax.github.com" "native-window-placement@gnome-shell-extensions.gcampax.github.com" "drive-menu@gnome-shell-extensions.gcampax.github.com" "tilingshell@ferrarodomenico.com" "forge@jmmaranan.com" "blur-my-shell@aunetx" "bluetooth-battery@michalw.github.com" "openbar@neuromorph" "unite@hardpixel.eu" "vertical-overview@RensAlthuis.github.com" "system-monitor@gnome-shell-extensions.gcampax.github.com" "gestureImprovements@gestures" "touchpad-gesture-customization@coooolapps.com" ];
      enabled-extensions = [ "boostvolume@shaquib.dev" "smile-extension@mijorus.it" "just-perfection-desktop@just-perfection" "tophat@fflewddur.github.io" "HeadsetControl@lauinger-clan.de" "quick-settings-audio-panel@rayzeq.github.io" "paperwm@paperwm.github.com" "paperwm@paperwm.github.com" "boostvolume@shaquib.dev" "smile-extension@mijorus.it" "just-perfection-desktop@just-perfection" "tophat@fflewddur.github.io" "HeadsetControl@lauinger-clan.de" "quick-settings-audio-panel@rayzeq.github.io" "paperwm@paperwm.github.com" "boostvolume@shaquib.dev" "smile-extension@mijorus.it" "just-perfection-desktop@just-perfection" "tophat@fflewddur.github.io" "HeadsetControl@lauinger-clan.de" "quick-settings-audio-panel@rayzeq.github.io" "nightthemeswitcher@romainvigier.fr" ];
      favorite-apps = [ "org.gnome.Nautilus.desktop" "code.desktop" "firefox.desktop" ];
      welcome-dialog-last-shown-version = "46.2";
    };

    "org/gnome/shell/app-switcher" = {
      current-workspace-only = true;
    };

    "org/gnome/shell/extensions/HeadsetControl" = {
      show-systemindicator = false;
    };

    "org/gnome/shell/extensions/dash-to-panel" = {
      extension-version = 68;
      panel-anchors = ''
        {}\n
      '';
      panel-element-positions = ''
        {}\n
      '';
      panel-lengths = ''
        {}\n
      '';
      panel-positions = ''
        {}\n
      '';
      panel-sizes = ''
        {}\n
      '';
      prefs-opened = false;
      primary-monitor = "LGD-0x00000000";
    };

    "org/gnome/shell/extensions/just-perfection" = {
      accent-color-icon = false;
      accessibility-menu = false;
      background-menu = true;
      controls-manager-spacing-size = 0;
      dash = false;
      dash-app-running = false;
      dash-icon-size = 16;
      dash-separator = false;
      double-super-to-appgrid = true;
      looking-glass-height = 0;
      max-displayed-search-results = 0;
      osd = true;
      panel = false;
      panel-button-padding-size = 10;
      panel-icon-size = 16;
      panel-in-overview = true;
      panel-size = 0;
      ripple-box = false;
      search = false;
      show-apps-button = false;
      startup-status = 1;
      support-notifier-showed-version = 34;
      support-notifier-type = 0;
      theme = true;
      top-panel-position = 0;
      window-demands-attention-focus = true;
      window-maximized-on-create = false;
      window-picker-icon = false;
      window-preview-caption = true;
      window-preview-close-button = true;
      workspace = true;
      workspace-background-corner-size = 0;
      workspace-popup = true;
      workspace-switcher-should-show = false;
      workspace-switcher-size = 18;
      workspaces-in-app-grid = false;
    };

    "org/gnome/shell/extensions/libpanel" = {
      layout = [ [ "gnome@main" "quick-settings-audio-panel@rayzeq.github.io/main" ] ];
    };

    "org/gnome/shell/extensions/openbar" = {
      accent-color = [ "0" "0.75" "0.75" ];
      autohg-bar = true;
      autohg-menu = true;
      autotheme-dark = "Dark";
      autotheme-font = true;
      autotheme-light = "Light";
      bartype = "Islands";
      bcolor = [ "0.643" "0.612" "0.675" ];
      bg-change = true;
      bgalpha = 0.0;
      bgcolor = [ "0.843" "0.843" "0.851" ];
      bgcolor-wmax = [ "0.922" "0.922" "0.922" ];
      bgcolor2 = [ "0.725" "0.725" "0.725" ];
      bguri = "file:///home/lexyo/.local/share/backgrounds/2025-06-05-16-15-21-Background.png";
      boxalpha = 0.0;
      boxcolor = [ "0.843" "0.843" "0.851" ];
      color-scheme = "default";
      count1 = 497448;
      count10 = 12;
      count11 = 2;
      count12 = 1;
      count2 = 11474;
      count3 = 10107;
      count4 = 507;
      count5 = 209;
      count6 = 141;
      count7 = 40;
      count8 = 32;
      count9 = 27;
      dark-bcolor = [ "0.643" "0.612" "0.675" ];
      dark-bgcolor = [ "0.259" "0.259" "0.275" ];
      dark-bgcolor-wmax = [ "0.118" "0.118" "0.118" ];
      dark-bgcolor2 = [ "0.224" "0.224" "0.243" ];
      dark-bguri = "file:///home/lexyo/.local/share/backgrounds/2025-06-05-16-15-21-Background.png";
      dark-boxcolor = [ "0.259" "0.259" "0.275" ];
      dark-hcolor = [ "0.643" "0.643" "0.663" ];
      dark-hscd-color = [ "0.349" "0.314" "0.380" ];
      dark-iscolor = [ "0.259" "0.259" "0.275" ];
      dark-mbcolor = [ "0.643" "0.643" "0.663" ];
      dark-mbgcolor = [ "0.075" "0.075" "0.075" ];
      dark-mhcolor = [ "0.643" "0.643" "0.663" ];
      dark-mscolor = [ "0.349" "0.314" "0.380" ];
      dark-mshcolor = [ "0.000" "0.000" "0.000" ];
      dark-palette1 = [ "83" "75" "91" ];
      dark-palette10 = [ "124" "116" "132" ];
      dark-palette11 = [ "52" "36" "52" ];
      dark-palette12 = [ "164" "156" "172" ];
      dark-palette2 = [ "9" "7" "14" ];
      dark-palette3 = [ "244" "244" "245" ];
      dark-palette4 = [ "145" "141" "148" ];
      dark-palette5 = [ "112" "106" "119" ];
      dark-palette6 = [ "44" "39" "52" ];
      dark-palette7 = [ "164" "164" "169" ];
      dark-palette8 = [ "124" "124" "131" ];
      dark-palette9 = [ "100" "100" "107" ];
      dark-shcolor = [ "0.000" "0.000" "0.000" ];
      dark-smbgcolor = [ "0.224" "0.224" "0.243" ];
      dark-vw-color = [ "0.349" "0.314" "0.380" ];
      dark-winbcolor = [ "0.349" "0.314" "0.380" ];
      default-font = "Sans 12";
      fgalpha = 1.0;
      fgcolor = [ "1.0" "1.0" "1.0" ];
      gradient-direction = "horizontal";
      hcolor = [ "0.204" "0.141" "0.204" ];
      hscd-color = [ "0.412" "0.290" "0.529" ];
      import-export = false;
      isalpha = 0.92;
      iscolor = [ "0.843" "0.843" "0.851" ];
      light-bcolor = [ "0.643" "0.612" "0.675" ];
      light-bgcolor = [ "0.843" "0.843" "0.851" ];
      light-bgcolor-wmax = [ "0.922" "0.922" "0.922" ];
      light-bgcolor2 = [ "0.725" "0.725" "0.725" ];
      light-bguri = "file:///home/lexyo/.local/share/backgrounds/2025-06-05-16-15-21-Background.png";
      light-boxcolor = [ "0.843" "0.843" "0.851" ];
      light-hcolor = [ "0.204" "0.141" "0.204" ];
      light-hscd-color = [ "0.412" "0.290" "0.529" ];
      light-iscolor = [ "0.843" "0.843" "0.851" ];
      light-mbcolor = [ "0.204" "0.141" "0.204" ];
      light-mbgcolor = [ "0.953" "0.953" "0.961" ];
      light-mhcolor = [ "0.204" "0.141" "0.204" ];
      light-mscolor = [ "0.412" "0.290" "0.529" ];
      light-mshcolor = [ "0.000" "0.000" "0.000" ];
      light-palette1 = [ "83" "75" "91" ];
      light-palette10 = [ "124" "116" "132" ];
      light-palette11 = [ "52" "36" "52" ];
      light-palette12 = [ "164" "156" "172" ];
      light-palette2 = [ "9" "7" "14" ];
      light-palette3 = [ "244" "244" "245" ];
      light-palette4 = [ "145" "141" "148" ];
      light-palette5 = [ "112" "106" "119" ];
      light-palette6 = [ "44" "39" "52" ];
      light-palette7 = [ "164" "164" "169" ];
      light-palette8 = [ "124" "124" "131" ];
      light-palette9 = [ "100" "100" "107" ];
      light-shcolor = [ "0.957" "0.957" "0.961" ];
      light-smbgcolor = [ "0.725" "0.725" "0.725" ];
      light-vw-color = [ "0.412" "0.290" "0.529" ];
      light-winbcolor = [ "0.412" "0.290" "0.529" ];
      mbcolor = [ "0.204" "0.141" "0.204" ];
      mbgcolor = [ "0.953" "0.953" "0.961" ];
      mfgalpha = 1.0;
      mfgcolor = [ "1.0" "1.0" "1.0" ];
      mhcolor = [ "0.204" "0.141" "0.204" ];
      monitor-height = 1080;
      monitor-width = 1920;
      mscolor = [ "0.412" "0.290" "0.529" ];
      mshcolor = [ "0.000" "0.000" "0.000" ];
      palette1 = [ "83" "75" "91" ];
      palette10 = [ "124" "116" "132" ];
      palette11 = [ "52" "36" "52" ];
      palette12 = [ "164" "156" "172" ];
      palette2 = [ "9" "7" "14" ];
      palette3 = [ "244" "244" "245" ];
      palette4 = [ "145" "141" "148" ];
      palette5 = [ "112" "106" "119" ];
      palette6 = [ "44" "39" "52" ];
      palette7 = [ "164" "164" "169" ];
      palette8 = [ "124" "124" "131" ];
      palette9 = [ "100" "100" "107" ];
      pause-reload = false;
      reloadstyle = true;
      shadow = false;
      shalpha = 0.54;
      shcolor = [ "0.957" "0.957" "0.961" ];
      smbgcolor = [ "0.725" "0.725" "0.725" ];
      trigger-autotheme = true;
      trigger-reload = true;
      vw-color = [ "0.412" "0.290" "0.529" ];
      winbcolor = [ "0.412" "0.290" "0.529" ];
      wmaxbar = false;
    };

    "org/gnome/shell/extensions/paperwm" = {
      edge-preview-click-enable = false;
      edge-preview-enable = false;
      edge-preview-timeout-continual = false;
      gesture-horizontal-fingers = 3;
      gesture-workspace-fingers = 3;
      horizontal-margin = 0;
      last-used-display-server = "Wayland";
      maximize-width-percent = 0.98;
      minimap-shade-opacity = 0;
      open-window-position = 0;
      overview-ensure-viewport-animation = 1;
      overview-min-windows-per-row = 4;
      restore-attach-modal-dialogs = "false";
      restore-edge-tiling = "false";
      restore-keybinds = ''
        {}
      '';
      restore-workspaces-only-on-primary = "false";
      selection-border-size = 0;
      show-focus-mode-icon = true;
      show-window-position-bar = false;
      show-workspace-indicator = true;
      vertical-margin = 0;
      vertical-margin-bottom = 0;
      window-gap = 3;
      winprops = [ ''
        {"wm_class":"com.nextcloud.desktopclient.nextcloud","scratch_layer":true,"focus":false}\n
      '' ''
        {"wm_class":"kitty","preferredWidth":"50%"}\n
      '' ];
    };

    "org/gnome/shell/extensions/paperwm/keybindings" = {
      switch-next = [ "<Super>period" ];
    };

    "org/gnome/shell/extensions/paperwm/workspaces" = {
      list = [ "3caef056-a11b-47c6-a7e3-301eccb2a922" "68f151bf-0926-4239-961a-d56156bdf6d6" "ac221d71-90ef-41b6-9924-d9739b0f40f4" "be7ab809-48a2-43d4-971e-150fbdf99148" "041e9fd0-f288-4426-97a3-f7767bd82260" "9dbb45ba-983f-422e-a4ae-ac024f664ae5" "d7a3c3af-0b08-445b-b632-07fa8c4df16e" "22ac0db7-0bfc-4642-95a4-dd6312774095" "dbcd1e00-9606-4306-b4ed-37a36dd33ee7" "021e9ec3-7ede-4d86-a793-826a60d09168" ];
    };

    "org/gnome/shell/extensions/paperwm/workspaces/021e9ec3-7ede-4d86-a793-826a60d09168" = {
      index = 9;
    };

    "org/gnome/shell/extensions/paperwm/workspaces/041e9fd0-f288-4426-97a3-f7767bd82260" = {
      index = 4;
      name = "Tyrannical";
      show-top-bar = true;
    };

    "org/gnome/shell/extensions/paperwm/workspaces/22ac0db7-0bfc-4642-95a4-dd6312774095" = {
      index = 7;
      name = "Unstoppable";
    };

    "org/gnome/shell/extensions/paperwm/workspaces/3caef056-a11b-47c6-a7e3-301eccb2a922" = {
      index = 0;
      name = "Resilient";
      show-top-bar = true;
    };

    "org/gnome/shell/extensions/paperwm/workspaces/68f151bf-0926-4239-961a-d56156bdf6d6" = {
      index = 1;
      name = "Wise";
      show-position-bar = true;
      show-top-bar = true;
    };

    "org/gnome/shell/extensions/paperwm/workspaces/9dbb45ba-983f-422e-a4ae-ac024f664ae5" = {
      index = 5;
      name = "Perfectionist";
      show-top-bar = true;
    };

    "org/gnome/shell/extensions/paperwm/workspaces/ac221d71-90ef-41b6-9924-d9739b0f40f4" = {
      index = 2;
      name = "Chaotic";
      show-top-bar = true;
    };

    "org/gnome/shell/extensions/paperwm/workspaces/be7ab809-48a2-43d4-971e-150fbdf99148" = {
      index = 3;
      name = "Ferocius";
      show-top-bar = true;
    };

    "org/gnome/shell/extensions/paperwm/workspaces/d7a3c3af-0b08-445b-b632-07fa8c4df16e" = {
      index = 6;
      name = "Determined";
    };

    "org/gnome/shell/extensions/paperwm/workspaces/dbcd1e00-9606-4306-b4ed-37a36dd33ee7" = {
      index = 8;
    };

    "org/gnome/shell/extensions/quick-settings-audio-panel" = {
      version = 2;
    };

    "org/gnome/shell/extensions/tophat" = {
      meter-fg-color = "rgb(255,255,255)";
      mount-to-monitor = "/";
      show-icons = true;
      use-system-accent = false;
    };

    "org/gnome/shell/keybindings" = {
      focus-active-notification = [];
      shift-overview-down = [];
      shift-overview-up = [];
      toggle-message-tray = [];
    };

    "org/gnome/shell/world-clocks" = {
      locations = [];
    };

    "org/gtk/gtk4/settings/color-chooser" = {
      custom-colors = [ (mkTuple [ 0.113725 0.67451 0.839216 1.0 ]) (mkTuple [ 0.5 0.5 0.5 1.0 ]) (mkTuple [ 0.294118 0.411765 0.513726 1.0 ]) (mkTuple [ 0.4 0.219608 0.133333 1.0 ]) (mkTuple [ 0.266667 0.337255 0.196078 1.0 ]) ];
      selected-color = mkTuple [ true 1.0 1.0 1.0 1.0 ];
    };

    "org/gtk/gtk4/settings/file-chooser" = {
      date-format = "regular";
      location-mode = "path-bar";
      show-hidden = true;
      sidebar-width = 140;
      sort-column = "name";
      sort-directories-first = true;
      sort-order = "ascending";
      type-format = "category";
      view-type = "grid";
      window-size = mkTuple [ 1920 858 ];
    };

    "org/gtk/settings/color-chooser" = {
      custom-colors = [ (mkTuple [ 1.0 0.843137 0.0 1.0 ]) ];
      selected-color = mkTuple [ true 0.141176 0.121569 0.192157 1.0 ];
    };

    "org/gtk/settings/file-chooser" = {
      date-format = "regular";
      location-mode = "path-bar";
      show-hidden = false;
      show-size-column = true;
      show-type-column = true;
      sidebar-width = 192;
      sort-column = "modified";
      sort-directories-first = false;
      sort-order = "descending";
      type-format = "category";
      window-position = mkTuple [ 26 23 ];
      window-size = mkTuple [ 1203 902 ];
    };

  };
}
