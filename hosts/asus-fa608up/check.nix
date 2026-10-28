# Synthetic hardware is used only to evaluate the profile, never to install it.
{ configuration, pkgs, lib }:
let
  fixture = configuration.extendModules {
    modules = [ ({ lib, ... }: {
      hardware.asus-fa608up = {
        configured = lib.mkForce true;
        amdPciAddress = lib.mkForce "0000:65:00.0";
        nvidiaPciAddress = lib.mkForce "0000:01:00.0";
        irCamera = lib.mkForce null;
      };
      fileSystems = lib.mkForce {
        "/" = { device = "none"; fsType = "tmpfs"; };
        "/boot" = { device = "/dev/test-efi"; fsType = "vfat"; };
      };
      boot.initrd.luks.devices = lib.mkForce { };
      swapDevices = lib.mkForce [ ];
      boot.resumeDevice = lib.mkForce "";
    }) ];
  };
  c = fixture.config;
  source = lib.cleanSourceWith {
    src = ./.;
    filter = path: type: type == "directory"
      || builtins.elem (baseNameOf path) [ "prepare.py" "test_prepare.py" ];
  };
in
assert c.hardware.nvidia.open;
assert c.hardware.nvidia.prime.amdgpuBusId == "PCI:101@0:0:0";
assert c.services.xserver.xkb.layout == "it" && c.console.keyMap == "it";
assert c.services.gpu-indicator.integratedGpuName == "AMD";
assert c.services.asusd.enable && !c.services.tlp.enable && !c.services.power-profiles-daemon.enable;
assert !c.networking.nat.enable;
builtins.deepSeq c.system.build.toplevel.drvPath (pkgs.runCommand "asus-fa608up-profile-check" { } ''
  ${pkgs.python3}/bin/python3 -B -m unittest discover -s ${source} -p 'test_*.py' -v
  touch $out
'')
