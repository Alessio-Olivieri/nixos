# Generated via dconf2nix: https://github.com/gvolpe/dconf2nix
{ lib, ... }:

with lib.hm.gvariant;

{
  dconf.settings = {
    "org/gnome/shell/extensions/paperwm" =
    {
      gesture-horizontal-fingers = 3;
      gesture-workspace-fingers = 3;
      horizontal-margin = 0;
      last-used-display-server = "Wayland";
      minimap-shade-opacity = 0;
      open-window-position = 0;
      overview-ensure-viewport-animation = 1;
      overview-min-windows-per-row = 4;
      restore-attach-modal-dialogs = "false";
      restore-edge-tiling = "false";
      restore-keybinds = ''
        {"toggle-tiled-right":{"bind":"[\\"<Super>Right\\"]","schema_id":"org.gnome.mutter.keybindings"},"toggle-tiled-left":{"bind":"[\\"<Super>Left\\"]","schema_id":"org.gnome.mutter.keybindings"},"cancel-input-capture":{"bind":"[\\"<Super><Shift>Escape\\"]","schema_id":"org.gnome.mutter.keybindings"},"restore-shortcuts":{"bind":"[\\"<Super>Escape\\"]","schema_id":"org.gnome.mutter.wayland.keybindings"},"switch-panels":{"bind":"[\\"<Control><Alt>Tab\\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"switch-to-workspace-left":{"bind":"[\\"<Super>Page_Up\\",\\"<Super><Alt>Left\\",\\"<Control><Alt>Left\\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"switch-group-backward":{"bind":"[\\"<Shift><Super>Above_Tab\\",\\"<Shift><Alt>Above_Tab\\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"move-to-monitor-down":{"bind":"[\\"<Super><Shift>Down\\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"switch-to-workspace-1":{"bind":"[\\"<Super>Home\\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"move-to-monitor-left":{"bind":"[\\"<Super><Shift>Left\\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"unmaximize":{"bind":"[\\"<Super>Down\\",\\"<Alt>F5\\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"switch-group":{"bind":"[\\"<Super>Above_Tab\\",\\"<Alt>Above_Tab\\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"move-to-workspace-left":{"bind":"[\\"<Super><Shift>Page_Up\\",\\"<Super><Shift><Alt>Left\\",\\"<Control><Shift><Alt>Left\\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"move-to-workspace-right":{"bind":"[\\"<Super><Shift>Page_Down\\",\\"<Super><Shift><Alt>Right\\",\\"<Control><Shift><Alt>Right\\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"switch-panels-backward":{"bind":"[\\"<Shift><Control><Alt>Tab\\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"move-to-workspace-up":{"bind":"[\\"<Control><Shift><Alt>Up\\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"switch-to-workspace-right":{"bind":"[\\"<Super>Page_Down\\",\\"<Super><Alt>Right\\",\\"<Control><Alt>Right\\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"move-to-workspace-down":{"bind":"[\\"<Control><Shift><Alt>Down\\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"switch-applications":{"bind":"[\\"<Super>Tab\\",\\"<Alt>Tab\\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"maximize":{"bind":"[\\"<Super>Up\\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"switch-to-workspace-last":{"bind":"[\\"<Super>End\\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"move-to-monitor-right":{"bind":"[\\"<Super><Shift>Right\\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"switch-applications-backward":{"bind":"[\\"<Shift><Super>Tab\\",\\"<Shift><Alt>Tab\\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"move-to-monitor-up":{"bind":"[\\"<Super><Shift>Up\\"]","schema_id":"org.gnome.desktop.wm.keybindings"},"shift-overview-up":{"bind":"[\\"<Super><Alt>Up\\"]","schema_id":"org.gnome.shell.keybindings"},"shift-overview-down":{"bind":"[\\"<Super><Alt>Down\\"]","schema_id":"org.gnome.shell.keybindings"},"focus-active-notification":{"bind":"[\\"<Super>n\\"]","schema_id":"org.gnome.shell.keybindings"},"rotate-video-lock-static":{"bind":"[\\"<Super>o\\",\\"XF86RotationLockToggle\\"]","schema_id":"org.gnome.settings-daemon.plugins.media-keys"}}
      '';
      restore-workspaces-only-on-primary = "false";
      selection-border-size = 0;
      show-focus-mode-icon = true;
      show-window-position-bar = true;
      show-workspace-indicator = true;
      vertical-margin = 0;
      vertical-margin-bottom = 0;
      window-gap = 3;
      
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
  };
}
