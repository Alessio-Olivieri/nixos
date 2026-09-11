{ config, lib, pkgs, ... }:
let
  cfg = config.services.gpu-indicator;
  indicator = pkgs.callPackage ./package.nix { };
in {
  options.services.gpu-indicator = {
    enable = lib.mkEnableOption "the Intel/NVIDIA GNOME indicator and read-only process collector";
    device = lib.mkOption {
      type = lib.types.strMatching "[0-9a-fA-F]{4}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}\\.[0-7]";
      default = "0000:01:00.0";
      description = "Full PCI address of the NVIDIA graphics function.";
    };
    nvidiaDeviceNode = lib.mkOption {
      type = lib.types.strMatching "/dev/nvidia[0-9]+";
      default = "/dev/nvidia0";
      description = "NVIDIA character device corresponding to the selected PCI function.";
    };
    interval = lib.mkOption {
      type = lib.types.ints.between 2 30;
      default = 5;
      description = "Seconds between lightweight samples; no GPU ioctls are issued.";
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ indicator ];
    systemd.services.gpu-indicator = {
      description = "Read NVIDIA power state and publish sanitized GPU client names";
      wantedBy = [ "multi-user.target" ];
      after = [ "systemd-udevd.service" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${indicator}/bin/gpu-indicator-collector --device ${cfg.device} --nvidia-node ${cfg.nvidiaDeviceNode} --interval ${toString cfg.interval} --output /run/gpu-indicator/status.json";
        Restart = "on-failure";
        RestartSec = 5;
        User = "root";
        Group = "root";
        RuntimeDirectory = "gpu-indicator";
        RuntimeDirectoryMode = "0755";
        UMask = "0022";
        # Cross-user fd symlinks require ptrace *read* permission. No ptrace
        # syscall or process memory access is used by this program.
        CapabilityBoundingSet = [ "CAP_SYS_PTRACE" "CAP_DAC_READ_SEARCH" ];
        NoNewPrivileges = true;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        ProtectClock = true;
        ProtectHostname = true;
        RestrictAddressFamilies = [ "AF_UNIX" ];
        RestrictSUIDSGID = true;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        ReadWritePaths = [ "/run/gpu-indicator" ];
      };
    };
  };
}
