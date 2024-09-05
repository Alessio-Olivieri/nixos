# Generated via dconf2nix: https://github.com/gvolpe/dconf2nix
{ lib, ... }:

with lib.hm.gvariant;

{
  dconf.settings = {
    "org/gnome/Connections" = {
      first-run = false;
    };

    "org/gnome/Console" = {
      last-window-maximised = false;
      last-window-size = mkTuple [ 1898 1028 ];
    };

    "org/gnome/Extensions" = {
      window-height = 1028;
      window-width = 744;
    };

    "org/gnome/Geary" = {
      compose-as-html = true;
      formatting-toolbar-visible = false;
      migrated-config = true;
      window-height = 1028;
    };

    "org/gnome/Snapshot" = {
      is-maximized = false;
      window-height = 640;
      window-width = 800;
    };

    "org/gnome/Weather" = {
      locations = [ (mkVariant [ (mkUint32 2) (mkVariant [ "Rome" "LIRU" true [ (mkTuple [ 0.7321656212116213 0.2181661564992912 ]) ] [ (mkTuple [ 0.731292956585624 0.21787526247286132 ]) ] ]) ]) ];
    };

    "org/gnome/baobab/ui" = {
      is-maximized = false;
      window-size = mkTuple [ 960 1028 ];
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
      window-size = mkTuple [ 680 1028 ];
      word-size = 64;
    };

    "org/gnome/calendar" = {
      active-view = "month";
      window-maximized = false;
      window-size = mkTuple [ 1717 1028 ];
    };

    "org/gnome/control-center" = {
      last-panel = "multitasking";
      window-state = mkTuple [ 1898 1028 false ];
    };

    "org/gnome/desktop/app-folders" = {
      folder-children = [ "Utilities" "YaST" "Pardus" ];
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
      picture-uri = "file:///home/lexyo/.local/share/backgrounds/2024-09-01-15-41-16-dragon_ball_z_2-wallpaper-1920x1080.jpg";
      picture-uri-dark = "file:///home/lexyo/.local/share/backgrounds/2024-09-01-15-41-16-dragon_ball_z_2-wallpaper-1920x1080.jpg";
      primary-color = "#000000000000";
      secondary-color = "#000000000000";
    };

    "org/gnome/desktop/input-sources" = {
      sources = [ (mkTuple [ "xkb" "it" ]) ];
      xkb-options = [ "terminate:ctrl_alt_bksp" ];
    };

    "org/gnome/desktop/interface" = {
      enable-hot-corners = false;
      show-battery-percentage = true;
    };

    "org/gnome/desktop/notifications" = {
      application-children = [ "org-gnome-console" "org-kde-kdeconnect-daemon" "gnome-power-panel" "code" "org-gnome-settings" "firefox" "org-gnome-loupe" "org-gnome-geary" "org-gnome-baobab" "org-telegram-desktop" "org-gnome-evolution-alarm-notify" "discord" ];
    };

    "org/gnome/desktop/notifications/application/code" = {
      application-id = "code.desktop";
    };

    "org/gnome/desktop/notifications/application/discord" = {
      application-id = "discord.desktop";
    };

    "org/gnome/desktop/notifications/application/firefox" = {
      application-id = "firefox.desktop";
    };

    "org/gnome/desktop/notifications/application/gnome-power-panel" = {
      application-id = "gnome-power-panel.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-baobab" = {
      application-id = "org.gnome.baobab.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-console" = {
      application-id = "org.gnome.Console.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-evolution-alarm-notify" = {
      application-id = "org.gnome.Evolution-alarm-notify.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-geary" = {
      application-id = "org.gnome.Geary.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-loupe" = {
      application-id = "org.gnome.Loupe.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-settings" = {
      application-id = "org.gnome.Settings.desktop";
    };

    "org/gnome/desktop/notifications/application/org-kde-kdeconnect-daemon" = {
      application-id = "org.kde.kdeconnect.daemon.desktop";
    };

    "org/gnome/desktop/notifications/application/org-telegram-desktop" = {
      application-id = "org.telegram.desktop.desktop";
    };

    "org/gnome/desktop/peripherals/keyboard" = {
      numlock-state = true;
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      two-finger-scrolling-enabled = true;
    };

    "org/gnome/desktop/screensaver" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file:///home/lexyo/.local/share/backgrounds/2024-09-01-15-41-16-dragon_ball_z_2-wallpaper-1920x1080.jpg";
      primary-color = "#000000000000";
      secondary-color = "#000000000000";
    };

    "org/gnome/desktop/search-providers" = {
      sort-order = [ "org.gnome.Contacts.desktop" "org.gnome.Documents.desktop" "org.gnome.Nautilus.desktop" ];
    };

    "org/gnome/desktop/wm/keybindings" = {
      maximize = [];
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
      num-workspaces = 8;
      workspace-names = [ "Resilient" "Wise" "Chaotic" "Ferocius" "Tyrannical" "Perfectionist" "Determined" "Unstoppable" ];
    };

    "org/gnome/evince" = {
      document-directory = "file:///home/lexyo/Documents/papers";
    };

    "org/gnome/evince/default" = {
      continuous = true;
      dual-page = false;
      dual-page-odd-left = false;
      enable-spellchecking = true;
      fullscreen = false;
      inverted-colors = false;
      show-sidebar = true;
      sidebar-page = "thumbnails";
      sidebar-size = 148;
      sizing-mode = "free";
      window-ratio = mkTuple [ 2.138888888888889 1.297979797979798 ];
      zoom = 0.5625328167490407;
    };

    "org/gnome/evolution-data-server" = {
      migrated = true;
    };

    "org/gnome/evolution-data-server/calendar" = {
      reminders-past = [ "4fc1b98ad7aed08d02fac68df774486a9ca4a462n79e99eae4a12a3e2bc63f3fde1bbf572c062e65ct20240904T080000n1725429000n1725429600n1725436800nBEGIN:VEVENTrnDTSTART;TZID=Europe/Rome:20240904T080000rnDTEND;TZID=Europe/Rome:20240904T100000rnRRULE:FREQ=WEEKLY;BYDAY=WErnDTSTAMP:20240225T224341ZrnUID:rn clj6ae33clj3ab9i68sm8b9k6osmcb9pcosjgbb16phmcp3674sj2e1gc4@google.comrnCREATED:20240216T170533ZrnX-LIC-ERROR;X-LIC-ERRORTYPE=VALUE-PARSE-ERROR:No value for DESCRIPTION rn property. Removing entire property:rnLAST-MODIFIED:20240225T224341ZrnLOCATION:Dipartimento di informatica\\, (RM115\\, Edificio G) Sapienza\\, rn Viale Regina Elena\\, 295\\, 00161 Roma RM\\, ItaliarnSEQUENCE:1rnSTATUS:CONFIRMEDrnSUMMARY:OptimizationrnTRANSP:OPAQUErnX-EVOLUTION-CALDAV-ETAG:63851380414rnRECURRENCE-ID;TZID=Europe/Rome:20240904T080000rnBEGIN:VALARMrnACTION:DISPLAYrnDESCRIPTION:This is an event reminderrnTRIGGER:-PT10MrnX-EVOLUTION-ALARM-UID:79e99eae4a12a3e2bc63f3fde1bbf572c062e65crnEND:VALARMrnEND:VEVENTrn" ];
    };

    "org/gnome/gnome-system-monitor" = {
      current-tab = "processes";
      show-dependencies = false;
      show-whose-processes = "user";
      window-height = 1028;
      window-width = 874;
    };

    "org/gnome/gnome-system-monitor/disktreenew" = {
      col-6-visible = true;
      col-6-width = 0;
    };

    "org/gnome/gnome-system-monitor/proctree" = {
      columns-order = [ 0 1 2 3 4 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 ];
      sort-col = 8;
      sort-order = 0;
    };

    "org/gnome/maps" = {
      last-viewed-location = [ 46.0723087508336 11.128500602401942 ];
      map-type = "MapsStreetSource";
      transportation-type = "pedestrian";
      window-maximized = false;
      window-size = [ 1898 1028 ];
      zoom-level = 13;
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

    "org/gnome/nautilus/icon-view" = {
      default-zoom-level = "extra-large";
    };

    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "icon-view";
      migrated-gtk-settings = true;
      search-filter-time-type = "last_modified";
    };

    "org/gnome/nautilus/window-state" = {
      initial-size = mkTuple [ 890 1028 ];
      maximized = false;
    };

    "org/gnome/portal/filechooser/discord" = {
      last-folder-path = "/home/lexyo/Dev/thesis";
    };

    "org/gnome/portal/filechooser/org/gnome/Settings" = {
      last-folder-path = "/etc/nixos/files/wallpapers/Dragonball";
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      rotate-video-lock-static = [];
    };

    "org/gnome/settings-daemon/plugins/power" = {
      power-button-action = "nothing";
    };

    "org/gnome/shell" = {
      disable-user-extensions = false;
      disabled-extensions = [ "apps-menu@gnome-shell-extensions.gcampax.github.com" "auto-move-windows@gnome-shell-extensions.gcampax.github.com" "light-style@gnome-shell-extensions.gcampax.github.com" "native-window-placement@gnome-shell-extensions.gcampax.github.com" "places-menu@gnome-shell-extensions.gcampax.github.com" "windowsNavigator@gnome-shell-extensions.gcampax.github.com" "drive-menu@gnome-shell-extensions.gcampax.github.com" "blur-my-shell@aunetx" ];
      enabled-extensions = [ "blur-my-shell@aunetx" "paperwm@paperwm.github.com" ];
      welcome-dialog-last-shown-version = "46.2";
    };

    "org/gnome/shell/app-switcher" = {
      current-workspace-only = true;
    };

    "org/gnome/shell/extensions/blur-my-shell" = {
      brightness = 0.75;
      noise-amount = 0;
      settings-version = 2;
    };

    "org/gnome/shell/extensions/blur-my-shell/appfolder" = {
      brightness = 0.75;
      sigma = 30;
    };

    "org/gnome/shell/extensions/blur-my-shell/dash-to-dock" = {
      blur = true;
      brightness = 0.75;
      pipeline = "pipeline_default_rounded";
      sigma = 30;
      static-blur = true;
      style-dash-to-dock = 0;
    };

    "org/gnome/shell/extensions/blur-my-shell/lockscreen" = {
      pipeline = "pipeline_default";
    };

    "org/gnome/shell/extensions/blur-my-shell/overview" = {
      pipeline = "pipeline_default";
    };

    "org/gnome/shell/extensions/blur-my-shell/panel" = {
      brightness = 0.75;
      pipeline = "pipeline_default";
      sigma = 30;
    };

    "org/gnome/shell/extensions/blur-my-shell/screenshot" = {
      pipeline = "pipeline_default";
    };

    "org/gnome/shell/extensions/blur-my-shell/window-list" = {
      brightness = 0.75;
      sigma = 30;
    };

    "org/gnome/shell/extensions/gsconnect" = {
      devices = [ "d891693c_35f1_42a1_b4be_e96cc440eae9" ];
      id = "8ddd00cc-6f0e-47c0-a394-82a65ce74536";
      name = "nixos";
    };

    "org/gnome/shell/extensions/gsconnect/device/_88face01_d763_4f60_94d4_b9e6746a8dc3_" = {
      incoming-capabilities = [ "kdeconnect.battery" "kdeconnect.battery.request" "kdeconnect.bigscreen.stt" "kdeconnect.clipboard" "kdeconnect.clipboard.connect" "kdeconnect.connectivity_report" "kdeconnect.contacts.response_uids_timestamps" "kdeconnect.contacts.response_vcards" "kdeconnect.findmyphone.request" "kdeconnect.lock" "kdeconnect.lock.request" "kdeconnect.mousepad.echo" "kdeconnect.mousepad.keyboardstate" "kdeconnect.mousepad.request" "kdeconnect.mpris" "kdeconnect.mpris.request" "kdeconnect.notification" "kdeconnect.notification.request" "kdeconnect.photo" "kdeconnect.ping" "kdeconnect.presenter" "kdeconnect.runcommand" "kdeconnect.runcommand.request" "kdeconnect.sftp" "kdeconnect.share.request" "kdeconnect.sms.attachment_file" "kdeconnect.sms.messages" "kdeconnect.systemvolume" "kdeconnect.systemvolume.request" "kdeconnect.telephony" "kdeconnect.telephony.request_mute" "kdeconnect.virtualmonitor" "kdeconnect.virtualmonitor.request" ];
      last-connection = "lan://192.168.26.136:1716";
      name = "nixos";
      outgoing-capabilities = [ "kdeconnect.battery" "kdeconnect.battery.request" "kdeconnect.bigscreen.stt" "kdeconnect.clipboard" "kdeconnect.clipboard.connect" "kdeconnect.connectivity_report.request" "kdeconnect.contacts.request_all_uids_timestamps" "kdeconnect.contacts.request_vcards_by_uid" "kdeconnect.findmyphone.request" "kdeconnect.lock" "kdeconnect.lock.request" "kdeconnect.mousepad.keyboardstate" "kdeconnect.mousepad.request" "kdeconnect.mpris" "kdeconnect.mpris.request" "kdeconnect.notification" "kdeconnect.notification.action" "kdeconnect.notification.reply" "kdeconnect.notification.request" "kdeconnect.photo.request" "kdeconnect.ping" "kdeconnect.runcommand" "kdeconnect.runcommand.request" "kdeconnect.sftp.request" "kdeconnect.share.request" "kdeconnect.share.request.update" "kdeconnect.sms.request" "kdeconnect.sms.request_attachment" "kdeconnect.sms.request_conversation" "kdeconnect.sms.request_conversations" "kdeconnect.systemvolume" "kdeconnect.systemvolume.request" "kdeconnect.telephony" "kdeconnect.telephony.request_mute" "kdeconnect.virtualmonitor" "kdeconnect.virtualmonitor.request" ];
      supported-plugins = [ "battery" "clipboard" "findmyphone" "mousepad" "mpris" "notification" "ping" "runcommand" "share" "systemvolume" "telephony" ];
      type = "desktop";
    };

    "org/gnome/shell/extensions/gsconnect/device/_88face01_d763_4f60_94d4_b9e6746a8dc3_/plugin/battery" = {
      custom-battery-notification-value = mkUint32 80;
    };

    "org/gnome/shell/extensions/gsconnect/device/_88face01_d763_4f60_94d4_b9e6746a8dc3_/plugin/notification" = {
      applications = ''
        {"Power":{"iconName":"org.gnome.Settings-power-symbolic","enabled":true},"Clocks":{"iconName":"org.gnome.clocks","enabled":true},"Color":{"iconName":"org.gnome.Settings-color-symbolic","enabled":true},"File Roller":{"iconName":"org.gnome.FileRoller","enabled":true},"Printers":{"iconName":"org.gnome.Settings-printers-symbolic","enabled":true},"Files":{"iconName":"org.gnome.Nautilus","enabled":true},"Disk Usage Analyzer":{"iconName":"org.gnome.baobab","enabled":true},"Disks":{"iconName":"org.gnome.DiskUtility","enabled":true},"Events and Tasks Reminders":{"iconName":"org.gnome.Evolution-alarm-notify","enabled":true},"Console":{"iconName":"org.gnome.Console","enabled":true},"Geary":{"iconName":"org.gnome.Geary","enabled":true},"Date & Time":{"iconName":"org.gnome.Settings-time-symbolic","enabled":true}}
      '';
    };

    "org/gnome/shell/extensions/gsconnect/device/_88face01_d763_4f60_94d4_b9e6746a8dc3_/plugin/share" = {
      receive-directory = "/home/lexyo/Downloads";
    };

    "org/gnome/shell/extensions/gsconnect/device/d891693c_35f1_42a1_b4be_e96cc440eae9" = {
      incoming-capabilities = [ "kdeconnect.battery" "kdeconnect.bigscreen.stt" "kdeconnect.clipboard" "kdeconnect.clipboard.connect" "kdeconnect.contacts.request_all_uids_timestamps" "kdeconnect.contacts.request_vcards_by_uid" "kdeconnect.findmyphone.request" "kdeconnect.mousepad.keyboardstate" "kdeconnect.mousepad.request" "kdeconnect.mpris" "kdeconnect.mpris.request" "kdeconnect.notification" "kdeconnect.notification.action" "kdeconnect.notification.reply" "kdeconnect.notification.request" "kdeconnect.ping" "kdeconnect.runcommand" "kdeconnect.sftp.request" "kdeconnect.share.request" "kdeconnect.share.request.update" "kdeconnect.sms.request" "kdeconnect.sms.request_attachment" "kdeconnect.sms.request_conversation" "kdeconnect.sms.request_conversations" "kdeconnect.systemvolume" "kdeconnect.telephony.request" "kdeconnect.telephony.request_mute" ];
      last-connection = "lan://192.168.148.216:1716";
      name = "Redmi K20 Pro";
      outgoing-capabilities = [ "kdeconnect.battery" "kdeconnect.bigscreen.stt" "kdeconnect.clipboard" "kdeconnect.clipboard.connect" "kdeconnect.connectivity_report" "kdeconnect.contacts.response_uids_timestamps" "kdeconnect.contacts.response_vcards" "kdeconnect.findmyphone.request" "kdeconnect.mousepad.echo" "kdeconnect.mousepad.keyboardstate" "kdeconnect.mousepad.request" "kdeconnect.mpris" "kdeconnect.mpris.request" "kdeconnect.notification" "kdeconnect.notification.request" "kdeconnect.ping" "kdeconnect.presenter" "kdeconnect.runcommand.request" "kdeconnect.sftp" "kdeconnect.share.request" "kdeconnect.sms.attachment_file" "kdeconnect.sms.messages" "kdeconnect.systemvolume.request" "kdeconnect.telephony" ];
      paired = false;
      supported-plugins = [ "battery" "clipboard" "connectivity_report" "contacts" "findmyphone" "mousepad" "mpris" "notification" "ping" "presenter" "runcommand" "sftp" "share" "sms" "systemvolume" "telephony" ];
      type = "phone";
    };

    "org/gnome/shell/extensions/gsconnect/device/d891693c_35f1_42a1_b4be_e96cc440eae9/plugin/battery" = {
      custom-battery-notification = true;
      custom-battery-notification-value = mkUint32 80;
      full-battery-notification = true;
      send-statistics = true;
    };

    "org/gnome/shell/extensions/gsconnect/device/d891693c_35f1_42a1_b4be_e96cc440eae9/plugin/clipboard" = {
      receive-content = true;
      send-content = true;
    };

    "org/gnome/shell/extensions/gsconnect/device/d891693c_35f1_42a1_b4be_e96cc440eae9/plugin/notification" = {
      applications = ''
        {"Power":{"iconName":"org.gnome.Settings-power-symbolic","enabled":true},"Clocks":{"iconName":"org.gnome.clocks","enabled":true},"Color":{"iconName":"org.gnome.Settings-color-symbolic","enabled":true},"File Roller":{"iconName":"org.gnome.FileRoller","enabled":true},"Printers":{"iconName":"org.gnome.Settings-printers-symbolic","enabled":true},"Files":{"iconName":"org.gnome.Nautilus","enabled":true},"Disk Usage Analyzer":{"iconName":"org.gnome.baobab","enabled":true},"Disks":{"iconName":"org.gnome.DiskUtility","enabled":true},"Events and Tasks Reminders":{"iconName":"org.gnome.Evolution-alarm-notify","enabled":true},"Console":{"iconName":"org.gnome.Console","enabled":true},"Geary":{"iconName":"org.gnome.Geary","enabled":true},"Date & Time":{"iconName":"org.gnome.Settings-time-symbolic","enabled":true},"Telegram Desktop":{"iconName":"telegram","enabled":true}}
      '';
      send-notifications = false;
    };

    "org/gnome/shell/extensions/gsconnect/device/d891693c_35f1_42a1_b4be_e96cc440eae9/plugin/share" = {
      receive-directory = "/home/lexyo/Downloads";
    };

    "org/gnome/shell/extensions/gsconnect/device/d891693c_35f1_42a1_b4be_e96cc440eae9/plugin/telephony" = {
      ringing-pause = true;
    };

    "org/gnome/shell/extensions/gsconnect/preferences" = {
      window-maximized = false;
      window-size = mkTuple [ 754 981 ];
    };

    "org/gnome/shell/extensions/paperwm" = {
      gesture-workspace-fingers = 4;
      horizontal-margin = 11;
      last-used-display-server = "Wayland";
      minimap-shade-opacity = 3;
      open-window-position = 0;
      overview-ensure-viewport-animation = 1;
      overview-min-windows-per-row = 15;
      restore-attach-modal-dialogs = "false";
      restore-edge-tiling = "false";
      restore-keybinds = ''
        {"toggle-tiled-right":{"bind":"[\\"<Super>Right\\"]","schema_id":"org.gnome.mutter.keybindings"},"toggle-tiled-left":{"bind":"[\\"<Super>Left\\"]","schema_id":"org.gnome.mutter.keybindings"},"cancel-input-capture":{"bind":"[\\"<Super><Shift>Escape\\"]","schema_id":"org.gnome.mutter.keybindings"},"restore-shortcuts":{"bind":"[\\"<Super>Escape\\"]","schema_id":"org.gnome.mutter.wayland.keybindings"},"switch-panels":{"bind":"[\\"<Control><Alt>Tab\\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"switch-to-workspace-left":{"bind":"[\\"<Super>Page_Up\\",\\"<Super><Alt>Left\\",\\"<Control><Alt>Left\\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"switch-group-backward":{"bind":"[\\"<Shift><Super>Above_Tab\\",\\"<Shift><Alt>Above_Tab\\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"move-to-monitor-down":{"bind":"[\\"<Super><Shift>Down\\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"switch-to-workspace-1":{"bind":"[\\"<Super>Home\\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"move-to-monitor-left":{"bind":"[\\"<Super><Shift>Left\\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"unmaximize":{"bind":"[\\"<Super>Down\\",\\"<Alt>F5\\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"switch-group":{"bind":"[\\"<Super>Above_Tab\\",\\"<Alt>Above_Tab\\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"move-to-workspace-left":{"bind":"[\\"<Super><Shift>Page_Up\\",\\"<Super><Shift><Alt>Left\\",\\"<Control><Shift><Alt>Left\\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"move-to-workspace-right":{"bind":"[\\"<Super><Shift>Page_Down\\",\\"<Super><Shift><Alt>Right\\",\\"<Control><Shift><Alt>Right\\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"switch-panels-backward":{"bind":"[\\"<Shift><Control><Alt>Tab\\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"move-to-workspace-up":{"bind":"[\\"<Control><Shift><Alt>Up\\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"switch-to-workspace-right":{"bind":"[\\"<Super>Page_Down\\",\\"<Super><Alt>Right\\",\\"<Control><Alt>Right\\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"move-to-workspace-down":{"bind":"[\\"<Control><Shift><Alt>Down\\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"switch-applications":{"bind":"[\\"<Super>Tab\\",\\"<Alt>Tab\\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"maximize":{"bind":"[\\"<Super>Up\\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"switch-to-workspace-last":{"bind":"[\\"<Super>End\\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"move-to-monitor-right":{"bind":"[\\"<Super><Shift>Right\\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"switch-applications-backward":{"bind":"[\\"<Shift><Super>Tab\\",\\"<Shift><Alt>Tab\\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"move-to-monitor-up":{"bind":"[\\"<Super><Shift>Up\\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"shift-overview-up":{"bind":"[\\"<Super><Alt>Up\\"]","schema_id":"org.gnome.shell.keybindings"},"shift-overview-down":{"bind":"[\\"<Super><Alt>Down\\"]","schema_id":"org.gnome.shell.keybindings"},"focus-active-notification":{"bind":"[\\"<Super>n\\"]","schema_id":"org.gnome.shell.keybindings"},"rotate-video-lock-static":{"bind":"[\\"<Super>o\\",\\"XF86RotationLockToggle\\"]","schema_id":"org.gnome.settings-daemon.plugins.media-keys"}}
      '';
      restore-workspaces-only-on-primary = "false";
      selection-border-size = 8;
      show-window-position-bar = false;
      show-workspace-indicator = true;
      vertical-margin = 10;
      window-gap = 20;
    };

    "org/gnome/shell/extensions/paperwm/workspaces" = {
      list = [ "3caef056-a11b-47c6-a7e3-301eccb2a922" "68f151bf-0926-4239-961a-d56156bdf6d6" "ac221d71-90ef-41b6-9924-d9739b0f40f4" "be7ab809-48a2-43d4-971e-150fbdf99148" "041e9fd0-f288-4426-97a3-f7767bd82260" "9dbb45ba-983f-422e-a4ae-ac024f664ae5" "d7a3c3af-0b08-445b-b632-07fa8c4df16e" "22ac0db7-0bfc-4642-95a4-dd6312774095" "dbcd1e00-9606-4306-b4ed-37a36dd33ee7" "021e9ec3-7ede-4d86-a793-826a60d09168" ];
    };

    "org/gnome/shell/extensions/paperwm/workspaces/021e9ec3-7ede-4d86-a793-826a60d09168" = {
      index = 9;
    };

    "org/gnome/shell/extensions/paperwm/workspaces/041e9fd0-f288-4426-97a3-f7767bd82260" = {
      background = "/etc/nixos/files/wallpapers/Dragonball/tyrannical.png";
      index = 4;
      name = "Tyrannical";
      show-top-bar = true;
    };

    "org/gnome/shell/extensions/paperwm/workspaces/22ac0db7-0bfc-4642-95a4-dd6312774095" = {
      background = "/etc/nixos/files/wallpapers/Dragonball/unstoppable.png";
      index = 7;
      name = "Unstoppable";
    };

    "org/gnome/shell/extensions/paperwm/workspaces/3caef056-a11b-47c6-a7e3-301eccb2a922" = {
      background = "/etc/nixos/files/wallpapers/Dragonball/resilient.jpg";
      index = 0;
      name = "Resilient";
      show-top-bar = true;
    };

    "org/gnome/shell/extensions/paperwm/workspaces/68f151bf-0926-4239-961a-d56156bdf6d6" = {
      background = "/etc/nixos/files/wallpapers/Dragonball/wise.png";
      index = 1;
      name = "Wise";
      show-top-bar = true;
    };

    "org/gnome/shell/extensions/paperwm/workspaces/9dbb45ba-983f-422e-a4ae-ac024f664ae5" = {
      background = "/etc/nixos/files/wallpapers/Dragonball/perfectionist.png";
      index = 5;
      name = "Perfectionist";
      show-top-bar = true;
    };

    "org/gnome/shell/extensions/paperwm/workspaces/ac221d71-90ef-41b6-9924-d9739b0f40f4" = {
      background = "/etc/nixos/files/wallpapers/Dragonball/chaotic.png";
      index = 2;
      name = "Chaotic";
      show-top-bar = true;
    };

    "org/gnome/shell/extensions/paperwm/workspaces/be7ab809-48a2-43d4-971e-150fbdf99148" = {
      background = "/etc/nixos/files/wallpapers/Dragonball/ferocius.png";
      index = 3;
      name = "Ferocius";
      show-top-bar = true;
    };

    "org/gnome/shell/extensions/paperwm/workspaces/d7a3c3af-0b08-445b-b632-07fa8c4df16e" = {
      background = "/etc/nixos/files/wallpapers/Dragonball/determined.jpg";
      index = 6;
      name = "Determined";
    };

    "org/gnome/shell/extensions/paperwm/workspaces/dbcd1e00-9606-4306-b4ed-37a36dd33ee7" = {
      index = 8;
    };

    "org/gnome/shell/keybindings" = {
      focus-active-notification = [];
      shift-overview-down = [];
      shift-overview-up = [];
    };

    "org/gnome/shell/weather" = {
      automatic-location = true;
      locations = [ (mkVariant [ (mkUint32 2) (mkVariant [ "Rome" "LIRU" true [ (mkTuple [ 0.7321656212116213 0.2181661564992912 ]) ] [ (mkTuple [ 0.731292956585624 0.21787526247286132 ]) ] ]) ]) ];
    };

    "org/gnome/shell/world-clocks" = {
      locations = [];
    };

    "org/gtk/gtk4/settings/color-chooser" = {
      custom-colors = [ (mkTuple [ 0.29411765933036804 0.4117647111415863 0.5137255191802979 1.0 ]) (mkTuple [ 0.4000000059604645 0.21960784494876862 0.13333334028720856 1.0 ]) (mkTuple [ 0.2666666805744171 0.33725491166114807 0.19607843458652496 1.0 ]) ];
      selected-color = mkTuple [ true 0.29411765933036804 0.4117647111415863 0.5137255191802979 1.0 ];
    };

    "org/gtk/gtk4/settings/file-chooser" = {
      date-format = "regular";
      location-mode = "path-bar";
      show-hidden = false;
      sidebar-width = 140;
      sort-column = "name";
      sort-directories-first = true;
      sort-order = "ascending";
      type-format = "category";
      view-type = "grid";
      window-size = mkTuple [ 744 858 ];
    };

    "org/gtk/settings/file-chooser" = {
      date-format = "regular";
      location-mode = "path-bar";
      show-hidden = false;
      show-size-column = true;
      show-type-column = true;
      sidebar-width = 157;
      sort-column = "name";
      sort-directories-first = false;
      sort-order = "ascending";
      type-format = "category";
      window-position = mkTuple [ 26 23 ];
      window-size = mkTuple [ 1203 902 ];
    };

  };
}
