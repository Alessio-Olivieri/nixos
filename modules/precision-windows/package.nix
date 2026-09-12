{ lib, pkgs, lookingGlass ? import ./looking-glass.nix { inherit pkgs; }, gamingEnabled ? false, requiredMutter ? null }:
let
  cudaProbe = pkgs.writeScriptBin "precision-cuda-probe" ("#!${pkgs.python3}/bin/python3 -I\n" + lib.removePrefix "#!/usr/bin/env python3\n" (builtins.readFile ./cuda_probe.py));
  hostDisplay = pkgs.runCommand "precision-host-display" {} ''
    mkdir -p $out/bin $out/lib/tests
    cp ${./host-display-bridge.js} $out/lib/host-display-bridge.js
    cp ${./display-guard.js} $out/lib/display-guard.js
    cp ${./tests/test_display_guard.js} $out/lib/tests/test_display_guard.js
    ${pkgs.gjs}/bin/gjs -m $out/lib/tests/test_display_guard.js
    cp ${./host_display.py} $out/bin/precision-host-display
    substituteInPlace $out/bin/precision-host-display \
      --replace-fail '#!/usr/bin/env python3' '#!${pkgs.python3}/bin/python3 -I' \
      --replace-fail '@gjs@' '${pkgs.gjs}/bin/gjs' \
      --replace-fail '@bridge@' "$out/lib/host-display-bridge.js"
    chmod +x $out/bin/precision-host-display
  '';
  cfg = pkgs.writeText "precision-windows-config.json" (builtins.toJSON {
    # Fail closed until the compositor's complete GPU-return path is validated.
    gaming_enabled = gamingEnabled;
    required_mutter = requiredMutter;
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
    host_display = "${hostDisplay}/bin/precision-host-display";
    guest_display_installer = "${./guest/install-display.ps1}";
  });
in pkgs.runCommand "precision-windows-1.0" { passthru = { inherit cudaProbe; }; } ''
  mkdir -p $out/bin $out/lib
  cp ${./controller.py} $out/bin/precision-windows
  cp ${./gpu.py} $out/bin/precision-windows-gpu
  cp ${./guest_sync.py} $out/bin/precision-windows-guest-sync
  cp ${./guest/qga-runner.py} $out/lib/qga-runner.py
  cp ${../precision-gpu-indicator/collector.py} $out/lib/collector.py
  cp ${./compositor_guard.py} $out/lib/compositor_guard.py
  for script in $out/bin/*; do
    substituteInPlace "$script" \
      --replace-fail '#!/usr/bin/env python3' '#!${pkgs.python3}/bin/python3 -I' \
      --replace-fail '@config@' '${cfg}' \
      --replace-fail '@lib@' "$out/lib"
    chmod +x "$script"
  done
  ln -s ${cudaProbe}/bin/precision-cuda-probe $out/bin/precision-cuda-probe
''
