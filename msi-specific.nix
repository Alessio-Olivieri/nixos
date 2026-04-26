{ config, pkgs, lib, ... }:

let
  # Fetches the hardware repo exactly once. Instantly faster rebuilds, no --impure!
  nixos-hardware = builtins.fetchTarball {
    url="https://github.com/NixOS/nixos-hardware/archive/master.tar.gz";
    sha256="sha256:0qy51il4hs4qyw6llahyg8g8kh5srrrfbjp7k48qkharsq66346r";
  };
in
{
  networking.hostName = lib.mkForce "msi-laptop";

  imports =[
    "${nixos-hardware}/common/cpu/intel"
    "${nixos-hardware}/common/gpu/intel/tiger-lake"
    
    # We import turing so we get the base community Nvidia fixes (via its ../. import)
    "${nixos-hardware}/common/gpu/nvidia/turing"
    
    # We skip prime.nix because we are explicitly configuring it below.
  ];
  # =========================================================
  # BASIC COOLING & BATTERY MANAGEMENT 
  # =========================================================
  # Essential for the Intel i7 to downclock and stay cool
  services.power-profiles-daemon.enable = true;
  services.thermald.enable = true;

  # =========================================================
  # GRAPHICS & NVIDIA OPTIMUS
  # =========================================================
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    
    package = config.boot.kernelPackages.nvidiaPackages.legacy_535;
    
    # We explicitly set this to false to override turing.nix. 
    # Proprietary drivers handle GTX 1650 sleeping much better.
    open = false; 

    # --- Power Management ---
    powerManagement = {
      enable = true;
      # The magic bullet for turning the GPU off (D3cold state)
      finegrained = true;
    };

    # --- PRIME Offload ---
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };

      # Bus IDs (Verify with 'lspci | grep -E "VGA|3D"')
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
# =======================================================================
  # 1. FORCE THE MSI MOTHERBOARD TO ALLOW PCIE SLEEP (ASPM)
  # =======================================================================
  # =======================================================================
  # OVERRIDE NIXOS SOURCE CODE TO KILL THE FRAMEBUFFER LOCK
  # =======================================================================
  boot.kernelParams = lib.mkAfter[ 
    "nvidia-drm.fbdev=0" 
    "nvidia_drm.fbdev=0" 
    "pcie_port_pm=force" 
    "pcie_aspm=force" 
  ];

services.udev.extraRules = ''
    # 1. Stops GNOME's Mutter from polling the NVIDIA GPU and keeping it awake.
    ACTION=="add|change", SUBSYSTEM=="drm", KERNEL=="card*", DRIVERS=="nvidia", TAG-="seat", TAG-="master-of-seat", ENV{MUTTER_HINTS}="ignore-device"

    # 2. Force PCI power management "auto" for the NVIDIA GPU
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030000", ATTR{power/control}="auto"
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030200", ATTR{power/control}="auto"
    
    # 3. EXTERMINATE THE NVIDIA AUDIO CONTROLLER
    # This prevents PipeWire from keeping the GPU awake.
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{remove}="1"
  '';
}