# Avoid speculative NVIDIA EGL/Vulkan initialization by ordinary desktop apps.
# This is a loader-selection policy, NOT a device-access security sandbox.
{ config, lib, pkgs, ... }:
let
  roots = [ "/run/opengl-driver" ]
    ++ lib.optional config.hardware.graphics.enable32Bit "/run/opengl-driver-32";
  egl = vendor: lib.concatMapStringsSep ":"
    (root: "${root}/share/glvnd/egl_vendor.d/${vendor}.json") roots;
  intelVulkan = "/run/opengl-driver/share/vulkan/icd.d/intel_icd.x86_64.json"
    + lib.optionalString config.hardware.graphics.enable32Bit
      ":/run/opengl-driver-32/share/vulkan/icd.d/intel_icd.i686.json";
  nvidiaVulkan = lib.concatMapStringsSep ":"
    (root: "${root}/share/vulkan/icd.d/nvidia_icd.json") roots;
  intel = {
    DRI_PRIME = "pci-0000_00_02_0";
    __EGL_VENDOR_LIBRARY_FILENAMES = egl "50_mesa";
    __GLX_VENDOR_LIBRARY_NAME = "mesa";
    VK_DRIVER_FILES = intelVulkan;
    VK_ICD_FILENAMES = intelVulkan;
  };
  assignments = vars: lib.concatStringsSep "\n"
    (lib.mapAttrsToList (key: value: "export ${key}=${lib.escapeShellArg value}") vars);
  intelRun = pkgs.writeShellScriptBin "intel-only" ''
    unset __NV_PRIME_RENDER_OFFLOAD __NV_PRIME_RENDER_OFFLOAD_PROVIDER __VK_LAYER_NV_optimus
    ${assignments intel}
    exec "$@"
  '';
  offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    # Undo inherited Intel selectors, including selectors from older launchers.
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
in {
  environment.sessionVariables = intel;
  # The stock offload helper does not clear inherited EGL/Vulkan restrictions.
  # Keep its option enabled for existing Lutris integration, but prefer this one.
  environment.systemPackages = [ intelRun (lib.hiPrio offload) ];
  # This per-user override applies on the very next Discord launch, including
  # before the next GNOME login has inherited environment.sessionVariables.
  home-manager.users.lexyo.xdg.desktopEntries.discord = {
    name = "Discord";
    genericName = "Chat client";
    exec = "${intelRun}/bin/intel-only ${pkgs.discord}/bin/Discord";
    icon = "discord";
    terminal = false;
    type = "Application";
    categories = [ "Network" "InstantMessaging" ];
    startupNotify = true;
  };
  system.build.precisionIntelOnly = intelRun;
  system.build.precisionNvidiaOffload = offload;
  assertions = [{
    assertion = config.hardware.nvidia.prime.offload.enable
      && config.hardware.nvidia.prime.offload.offloadCmdMainProgram == "nvidia-offload";
    message = "Precision desktop GPU policy requires the standard nvidia-offload command name.";
  }];
}
