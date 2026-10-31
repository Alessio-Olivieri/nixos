# AMD adaptation of modules/precision-desktop-gpu.nix.
# This is a loader-selection policy, NOT a device-access security sandbox.
{ config, lib, pkgs, ... }:
let
  roots = [ "/run/opengl-driver" ]
    ++ lib.optional config.hardware.graphics.enable32Bit "/run/opengl-driver-32";
  egl = vendor: lib.concatMapStringsSep ":"
    (root: "${root}/share/glvnd/egl_vendor.d/${vendor}.json") roots;
  amdVulkan = "/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json"
    + lib.optionalString config.hardware.graphics.enable32Bit
      ":/run/opengl-driver-32/share/vulkan/icd.d/radeon_icd.i686.json";
  nvidiaVulkan = lib.concatMapStringsSep ":"
    (root: "${root}/share/vulkan/icd.d/nvidia_icd.json") roots;
  amd = {
    DRI_PRIME = "pci-${builtins.replaceStrings [ ":" "." ] [ "_" "_" ] config.hardware.asus-fa608up.amdPciAddress}";
    __EGL_VENDOR_LIBRARY_FILENAMES = egl "50_mesa";
    __GLX_VENDOR_LIBRARY_NAME = "mesa";
    VK_DRIVER_FILES = amdVulkan;
    VK_ICD_FILENAMES = amdVulkan;
  };
  assignments = vars: lib.concatStringsSep "\n"
    (lib.mapAttrsToList (key: value: "export ${key}=${lib.escapeShellArg value}") vars);
  amdRun = pkgs.writeShellScriptBin "amd-only" ''
    unset __NV_PRIME_RENDER_OFFLOAD __NV_PRIME_RENDER_OFFLOAD_PROVIDER __VK_LAYER_NV_optimus
    ${assignments amd}
    exec "$@"
  '';
  offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    # Undo inherited AMD selectors, including selectors from older launchers.
    unset DRI_PRIME MESA_VK_DEVICE_SELECT MESA_VK_DEVICE_SELECT_FORCE_DEFAULT_DEVICE
    export __EGL_VENDOR_LIBRARY_FILENAMES=${lib.escapeShellArg (egl "10_nvidia")}
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __VK_LAYER_NV_optimus=NVIDIA_only
    export VK_DRIVER_FILES=${lib.escapeShellArg nvidiaVulkan}
    export VK_ICD_FILENAMES="$VK_DRIVER_FILES"
    exec "$@"
  '';
  stellaris = pkgs.writeShellApplication {
    name = "stellaris-steam-gpu";
    runtimeInputs = [ pkgs.procps pkgs.coreutils pkgs.libnotify ];
    text = ''
      if pgrep -u "$(id -u)" -x steam >/dev/null; then
        notify-send "Stellaris GPU Launcher" "Quit Steam before choosing a GPU profile." || true
        exit 1
      fi
      case "''${1:-}" in
        integrated) exec ${amdRun}/bin/amd-only steam steam://rungameid/281990 ;;
        dedicated) exec ${offload}/bin/nvidia-offload steam steam://rungameid/281990 ;;
        *) echo "Usage: stellaris-steam-gpu integrated|dedicated" >&2; exit 2 ;;
      esac
    '';
  };
in {
  # Mutter needs both EGL vendors for the NVIDIA-wired HDMI output. Restricting
  # the entire session to Mesa prevents accelerated cross-GPU display sharing.
  # Explicit amd-only launchers can still restrict an individual application.
  environment.sessionVariables = builtins.removeAttrs amd [ "__EGL_VENDOR_LIBRARY_FILENAMES" ];
  # The stock offload helper does not clear inherited EGL/Vulkan restrictions.
  # Keep its option enabled for existing Lutris integration, but prefer this one.
  environment.systemPackages = [ amdRun (lib.hiPrio offload) stellaris ];
  home-manager.users.lexyo.xdg.desktopEntries = {
    stellaris-amd = {
      name = "Stellaris (Integrated GPU)";
      exec = "${lib.getExe stellaris} integrated";
      icon = "steam_icon_281990";
      categories = [ "Game" ];
    };
    stellaris-nvidia = {
      name = "Stellaris (NVIDIA GPU)";
      exec = "${lib.getExe stellaris} dedicated";
      icon = "steam_icon_281990";
      categories = [ "Game" ];
    };
  };
  # This per-user override applies on the very next Discord launch, including
  # before the next GNOME login has inherited environment.sessionVariables.
  home-manager.users.lexyo.xdg.desktopEntries.discord = {
    name = "Discord";
    genericName = "Chat client";
    exec = "${amdRun}/bin/amd-only ${pkgs.discord}/bin/Discord";
    icon = "discord";
    terminal = false;
    type = "Application";
    categories = [ "Network" "InstantMessaging" ];
    startupNotify = true;
  };
  system.build.asusAmdOnly = amdRun;
  system.build.asusNvidiaOffload = offload;
  assertions = [{
    assertion = config.hardware.nvidia.prime.offload.enable
      && config.hardware.nvidia.prime.offload.offloadCmdMainProgram == "nvidia-offload";
    message = "ASUS desktop GPU policy requires the standard nvidia-offload command name.";
  }];
}
