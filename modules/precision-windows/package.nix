{ lib, pkgs, lookingGlass ? import ./looking-glass.nix { inherit pkgs; } }:
let
  cudaProbe = pkgs.writeScriptBin "precision-cuda-probe" ("#!${pkgs.python3}/bin/python3 -I\n" + lib.removePrefix "#!/usr/bin/env python3\n" (builtins.readFile ./cuda_probe.py));
  cfg = pkgs.writeText "precision-windows-config.json" (builtins.toJSON {
    qemu = "${pkgs.qemu}/bin/qemu-system-x86_64";
    swtpm = "${pkgs.swtpm}/bin/swtpm";
    # Same QEMU firmware package as the existing Quickemu installation.
    firmware = "${pkgs.qemu}/share/qemu/edk2-x86_64-code.fd";
    viewer = "${pkgs.virt-viewer}/bin/remote-viewer";
    chooser = "${pkgs.zenity}/bin/zenity";
    looking_glass = "${lookingGlass}/bin/looking-glass-client";
    notify = "${pkgs.libnotify}/bin/notify-send";
    modprobe = "${pkgs.kmod}/bin/modprobe";
    udevadm = "${pkgs.systemd}/bin/udevadm";
    cuda_probe = "${cudaProbe}/bin/precision-cuda-probe";
    controller = "/run/current-system/sw/bin/precision-windows";
    gpu_helper = "/run/current-system/sw/bin/precision-windows-gpu";
  });
in pkgs.runCommand "precision-windows-1.0" { passthru = { inherit cudaProbe; }; } ''
  mkdir -p $out/bin $out/lib
  cp ${./controller.py} $out/bin/precision-windows
  cp ${./gpu.py} $out/bin/precision-windows-gpu
  cp ${../precision-gpu-indicator/collector.py} $out/lib/collector.py
  for script in $out/bin/*; do
    substituteInPlace "$script" \
      --replace-fail '#!/usr/bin/env python3' '#!${pkgs.python3}/bin/python3 -I' \
      --replace-fail '@config@' '${cfg}'
    chmod +x "$script"
  done
  substituteInPlace $out/bin/precision-windows-gpu --replace-fail '@lib@' "$out/lib"
  ln -s ${cudaProbe}/bin/precision-cuda-probe $out/bin/precision-cuda-probe
''
