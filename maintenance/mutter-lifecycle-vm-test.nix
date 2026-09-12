# Disposable Linux VM only: no host PCI, Windows assets, firmware or TPM.
# This exercises real DRM/KMS teardown with virtual drivers. It is NOT proof
# of NVIDIA/Intel physical handoff, CUDA return or laptop display performance.
{ pkgs, mutter, secondaryDriver ? "vkms" }:
assert builtins.elem secondaryDriver [ "vkms" "qxl" ];
let
  shell = pkgs.gnome-shell.override { inherit mutter; };
  display = pkgs.writeText "lifecycle-test-display.js" ''
    import Gio from 'gi://Gio';
    import GLib from 'gi://GLib';
    function unpack(value) {
      if (value instanceof GLib.Variant) return unpack(value.deepUnpack());
      if (Array.isArray(value)) return value.map(unpack);
      if (value && typeof value === 'object')
        return Object.fromEntries(Object.entries(value).map(([k, v]) => [k, unpack(v)]));
      return value;
    }
    const call = (method, args = null) => unpack(Gio.DBus.session.call_sync(
      'org.gnome.Mutter.DisplayConfig', '/org/gnome/Mutter/DisplayConfig',
      'org.gnome.Mutter.DisplayConfig', method, args, null,
      Gio.DBusCallFlags.NONE, 5000, null));
    const [serial, monitors, logical] = call('GetCurrentState');
    if (ARGV[0] === 'snapshot') {
      const [shellPid] = Gio.DBus.session.call_sync('org.freedesktop.DBus',
        '/org/freedesktop/DBus', 'org.freedesktop.DBus', 'GetConnectionUnixProcessID',
        new GLib.Variant('(s)', ['org.gnome.Mutter.DisplayConfig']),
        new GLib.VariantType('(u)'), Gio.DBusCallFlags.NONE, 5000, null).deepUnpack();
      print(JSON.stringify({serial, monitors, logical, shellPid}));
    } else if (ARGV[0] === 'expect-connectors') {
      const available = monitors.map(monitor => monitor[0][0]);
      const missing = JSON.parse(ARGV[1]).filter(name => !available.includes(name));
      if (missing.length) throw new Error('Missing returned connectors: ' + missing);
      print('ready');
    } else if (ARGV[0] === 'apply') {
      const layouts = JSON.parse(ARGV[1]);
      call('ApplyMonitorsConfig', new GLib.Variant(
        '(uua(iiduba(ssa{sv}))a{sv})', [serial, 1, layouts, {}]));
      print('applied');
    } else {
      throw new Error('Expected snapshot or apply');
    }
  '';
in pkgs.testers.runNixOSTest {
  name = "precision-mutter-lifecycle-${secondaryDriver}";
  globalTimeout = 360;
  node.pkgsReadOnly = false;
  # Minimal test QEMU omits QXL. Use the same full QEMU package as the host VM.
  qemu.package = pkgs.qemu;
  nodes.machine = { lib, ... }: {
    nixpkgs.overlays = [ (_: _: { inherit mutter; gnome-shell = shell; }) ];
    users.users.alice = { isNormalUser = true; uid = 1000; password = ""; };
    services.displayManager.gdm.enable = true;
    services.displayManager.autoLogin = { enable = true; user = "alice"; };
    services.desktopManager.gnome.enable = true;
    services.gnome.gnome-initial-setup.enable = false;
    virtualisation = {
      memorySize = 4096;
      cores = 2;
      qemu.options = [ "-vga virtio" ] ++ lib.optional (secondaryDriver == "qxl") "-device qxl,id=scanout";
    };
    boot.kernelModules = [ "virtio_gpu" secondaryDriver ];
    services.udev.extraRules = ''
      SUBSYSTEM=="drm", KERNEL=="card[0-9]*", DRIVERS=="virtio_gpu", TAG+="mutter-device-preferred-primary"
      SUBSYSTEM=="drm", KERNEL=="card[0-9]*", DRIVERS=="qxl", ENV{MUTTER_DEVICE_SCANOUT_ONLY}="1"
    '';
    # Mutter's shipped61-mutter.rules normally hides VKMS outside its unit tests.
    # Override that policy ONLY inside this disposable test VM, after61.
    services.udev.packages = lib.mkAfter [
      # GUdev's legacy get_tags() includes historical tags even after TAG-=.
      # Never add the VKMS-ignore tag in this fixture; preserve all other rules.
      (pkgs.runCommand "precision-test-mutter-udev-rules" {} ''
        mkdir -p $out/lib/udev/rules.d
        sed '/vkms/d' ${mutter}/lib/udev/rules.d/61-mutter.rules > $out/lib/udev/rules.d/61-mutter.rules
      '')
      (pkgs.writeTextDir "lib/udev/rules.d/99-precision-vkms-test.rules" ''
      SUBSYSTEM=="drm", KERNEL=="card[0-9]*", KERNELS=="vkms", TAG-="mutter-device-ignore", ENV{MUTTER_DEVICE_SCANOUT_ONLY}="1", TAG+="seat", TAG+="master-of-seat"
      '')
    ];
    environment.systemPackages = [ pkgs.gjs pkgs.python3 pkgs.pciutils ];
    # Autologin and test controls belong solely to the disposable VM.
    services.xserver.enable = true;
  };
  testScript = ''
    import json
    import shlex
    serial_stdout_off()

    def display(action, layout=None):
        args = ["${pkgs.gjs}/bin/gjs", "-m", "${display}", action]
        if layout is not None:
            args.append(json.dumps(layout))
        command = "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus " + shlex.join(args)
        output = machine.succeed("su - alice -c " + shlex.quote(command) + " 2>&1")
        return json.loads(output) if action == "snapshot" else output

    def shell_pid():
        # Nix's process comm may be '.gnome-shell-wr'; use the actual bus owner.
        return str(display("snapshot")["shellPid"])

    def assert_session(pid):
        assert shell_pid() == pid, "GNOME exited or was replaced during the cycle"
        machine.succeed(f"grep -F '${mutter}/lib/libmutter-18.so' /proc/{pid}/maps")

    booted = False
    try:
        machine.start()
        machine.wait_for_unit("multi-user.target", timeout=90)
        booted = True
        machine.wait_for_unit("display-manager.service", timeout=60)
        machine.wait_for_file("/run/user/1000/wayland-0", timeout=90)
        machine.wait_for_unit("default.target", "alice", timeout=30)
        # The Wayland socket can precede ownership of DisplayConfig on D-Bus.
        ready_command = "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus ${pkgs.gjs}/bin/gjs -m ${display} snapshot"
        machine.wait_until_succeeds("su - alice -c " + shlex.quote(ready_command), timeout=30)
        pid = shell_pid()
        assert_session(pid)
        print(machine.succeed("udevadm info -q property -n /dev/dri/card1"))
        machine.succeed("journalctl -b --no-pager | grep -F 'Using CPU copy for scanout-only device'")
        if "${secondaryDriver}" == "qxl":
            # Discover only the disposable guest's QXL device, not a host BDF.
            pci = machine.succeed("readlink -f /sys/bus/pci/drivers/qxl/0000:*").strip()
            assert pci.startswith("/sys/devices/") and pci.count("\n") == 0
            bdf = pci.rsplit("/", 1)[1]
            card = machine.succeed(f"basename {shlex.quote(pci)}/drm/card[0-9]*").strip()
            remove_command = "${pkgs.python3}/bin/python3 -c " + shlex.quote(
                "from pathlib import Path; Path('/sys/bus/pci/drivers/qxl/unbind').write_text(" + repr(bdf) + ")")
            add_command = "${pkgs.python3}/bin/python3 -c " + shlex.quote(
                "from pathlib import Path; Path('/sys/bus/pci/drivers/qxl/bind').write_text(" + repr(bdf) + ")")
        else:
            card = machine.succeed("${pkgs.python3}/bin/python3 -c " + shlex.quote(
                "from pathlib import Path; print(' '.join(p.name for p in Path('/sys/class/drm').glob('card[0-9]*') if '-' not in p.name and '/vkms/' in str(p.resolve())))")).strip()
            remove_command = "modprobe -r vkms"
            add_command = "modprobe vkms"
        assert card.startswith("card") and card[4:].isdigit()
        device = "/dev/dri/" + card
        initial = display("snapshot")
        assert len(initial["logical"]) == 2, initial
        print("Initial display topology:", json.dumps(initial["logical"]))
        # The primary *monitor* chosen by GNOME is not necessarily on the
        # primary rendering GPU. Select by actual DRM connector ownership;
        # otherwise a test can disable virtio and leave VKMS actively scanning.
        primary_connectors = machine.succeed("${pkgs.python3}/bin/python3 -c " + shlex.quote(
            "from pathlib import Path; print(' '.join(p.name.split('-', 1)[1] for p in Path('/sys/class/drm').glob('card0-*') if (p/'status').read_text().strip() == 'connected'))")).split()
        assert primary_connectors, "No connected virtio primary connector"
        secondary_connectors = machine.succeed("${pkgs.python3}/bin/python3 -c " + shlex.quote(
            "from pathlib import Path; print(' '.join(p.name.split('-', 1)[1] for p in Path('/sys/class/drm').glob(" + repr(card + '-*') + ") if (p/'status').read_text().strip() == 'connected'))")).split()
        print("DRM connector ownership:", primary_connectors, secondary_connectors)
        assert not set(primary_connectors) & set(secondary_connectors)
        layouts = []
        for x, y, scale, transform, primary, specs, _properties in initial["logical"]:
            modes = []
            for spec in specs:
                monitor = next(m for m in initial["monitors"] if m[0] == spec)
                current = next(m for m in monitor[1] if m[6].get("is-current"))
                modes.append([spec[0], current[0], {}])
            primary = all(spec[0] in primary_connectors for spec in specs)
            layouts.append([x, y, scale, transform, primary, modes])
        primary_only = [l for l in layouts if l[4]]
        assert len(primary_only) == 1
        primary_only = [[0, 0, *primary_only[0][2:]]]
        display("apply", layouts)
        machine.screenshot("both-before")
        for cycle in range(3):
            with subtest(f"Virtual KMS removal/return cycle {cycle + 1}"):
                display("apply", primary_only)
                assert len(display("snapshot")["logical"]) == 1
                # Refuse removal while ANY guest process still has a secondary FD.
                owner_check = "${pkgs.python3}/bin/python3 -c " + shlex.quote(
                    "import os,pathlib; target=" + repr(device) + "; owners=[]; "
                    "\nfor fd in pathlib.Path('/proc').glob('[0-9]*/fd/*'):"
                    "\n try:"
                    "\n  if os.readlink(fd)==target: owners.append(str(fd))"
                    "\n except OSError: pass"
                    "\nassert not owners, owners"
                )
                machine.wait_until_succeeds(owner_check, timeout=30)
                # Third cycle queues remove/add before the disposable GNOME
                # processes either event. This tests reused paths explicitly.
                # No host process is stopped and no GPU owner is bypassed.
                queued_events = cycle == 2
                if queued_events:
                    machine.succeed(f"kill -STOP {pid}")
                try:
                    machine.succeed(owner_check)
                    machine.succeed(remove_command)
                    machine.wait_until_succeeds("test ! -e " + shlex.quote(device), timeout=10)
                    if not queued_events:
                        assert_session(pid)
                    machine.succeed(add_command)
                    machine.wait_for_file(device, timeout=10)
                finally:
                    if queued_events:
                        machine.succeed(f"kill -CONT {pid}")
                machine.succeed("udevadm settle")
                ready_command = "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus " + shlex.join([
                    "${pkgs.gjs}/bin/gjs", "-m", "${display}", "expect-connectors",
                    json.dumps(primary_connectors + secondary_connectors)])
                machine.wait_until_succeeds("su - alice -c " + shlex.quote(ready_command) + " 2>&1", timeout=10)
                assert_session(pid)
                display("apply", layouts)
                assert len(display("snapshot")["logical"]) == 2
                assert_session(pid)
                machine.screenshot(f"both-after-{cycle + 1}")
        # Match the compositor itself, not gnome-shell-calendar-server (which
        # can emit an unrelated missing-timezone assertion in minimal VMs).
        machine.fail("journalctl -b --no-pager | grep -E 'gnome-shell\\[[0-9]+\\].*(segfault|assertion.*failed)|Process.*gnome-shell.*dumped core'")
    finally:
        if booted:
            machine.succeed("journalctl -b --no-pager > /tmp/lifecycle-journal.txt")
            machine.copy_from_vm("/tmp/lifecycle-journal.txt")
  '';
}
