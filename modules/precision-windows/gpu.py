#!/usr/bin/env python3
"""Restricted root helper for this laptop's NVIDIA pair. No process killing."""
import fcntl
import json
import os
from pathlib import Path
import stat
import subprocess
import sys
import time

sys.path.insert(0, "@lib@")
import collector

CONFIG = json.loads(Path("@config@").read_text())
DEVICES = {"0000:01:00.0": ("0x24b7", "nvidia"), "0000:01:00.1": ("0x228b", "snd_hda_intel")}
SYS = Path("/sys/bus/pci/devices")
STATE = Path("/run/precision-windows-gpu")


def drivers():
    return {bdf: collector.basename(collector.read_link(SYS / bdf / "driver")) for bdf in DEVICES}


def active_displays():
    # Passive sysfs state, not a DRM/NVML probe: a Linux HDMI scanout is real
    # work and must not be misreported as failed runtime power management.
    return [path.parent.name for path in (SYS / '0000:01:00.0').glob('drm/card*/card*-*/enabled')
            if collector.read_text(path) == 'enabled'
            and collector.read_text(path.parent / 'status') == 'connected']


def device_targets():
    targets, vfio = set(), set()
    for bdf in DEVICES:
        linux, group = collector.device_targets(SYS / bdf, "/dev/nvidia0")
        targets |= linux
        vfio |= group
    # This is the only NVIDIA adapter; also refuse global CUDA/control users.
    targets |= {str(p) for p in Path("/dev").glob("nvidia*") if p.is_char_device()}
    for sound in (SYS / "0000:01:00.1" / "sound").glob("card*"):
        # ALSA control handles only observe mixer/device metadata and routinely
        # survive device removal. Refuse PCM/hwdep streams, not WirePlumber's
        # idle control subscription; never stop the user's audio server.
        targets |= {str(p) for p in Path("/dev/snd").glob(f"*C{sound.name[4:]}*")
                    if not p.name.startswith("controlC")}
    return targets, vfio


def owners():
    targets, vfio = device_targets()
    apps, visibility, _ = collector.scan_processes(Path("/proc"), targets, vfio)
    if not visibility["complete"]:
        raise RuntimeError("Cannot safely inspect every GPU owner; refusing handoff")
    return apps


def validate():
    for bdf, (device_id, _) in DEVICES.items():
        device = SYS / bdf
        if collector.read_text(device / "vendor") != "0x10de" or collector.read_text(device / "device") != device_id:
            raise RuntimeError(f"Hardware identity mismatch at {bdf}")
    display_gpus = {p.name for p in SYS.iterdir()
                    if collector.read_text(p / "vendor") == "0x10de"
                    and collector.read_text(p / "class").startswith("0x03")}
    if display_gpus != {"0000:01:00.0"}:
        raise RuntimeError("NVIDIA topology changed; refusing global module changes")


def prepare():
    if not CONFIG.get('gaming_enabled', False):
        raise RuntimeError('GPU handoff is disabled: the NVIDIA return path is not validated for this configuration. No GPU changes were made.')
    from compositor_guard import verify
    verify(CONFIG)
    validate()
    for bdf in DEVICES:
        group = SYS / bdf / "iommu_group" / "devices"
        if not group.exists():
            raise RuntimeError("IOMMU is not active; boot the configured IOMMU generation first")
        if {p.name for p in group.iterdir()} - set(DEVICES):
            raise RuntimeError(f"Unsafe IOMMU group for {bdf}; unrelated devices share the group")
    if any(v != DEVICES[k][1] for k, v in drivers().items()):
        raise RuntimeError("NVIDIA is not fully owned by its Linux drivers; recovery is required")
    busy = owners()
    if busy:
        raise RuntimeError("NVIDIA is in use: " + "; ".join(f"{a['name']} (PID {','.join(map(str, a['pids']))})" for a in busy))

    # Close the new-open race for normal Linux clients, then rescan existing fds.
    permissions = {}
    targets, _ = device_targets()
    for target in targets:
        path = Path(target)
        if path.exists() and path.is_char_device():
            permissions[target] = stat.S_IMODE(path.stat().st_mode)
    (STATE / "permissions.json").write_text(json.dumps(permissions))
    try:
        for target in permissions:
            os.chmod(target, 0)
        busy = owners()
        if busy:
            raise RuntimeError("A Linux application acquired NVIDIA during handoff: " + ", ".join(a["name"] for a in busy))
        subprocess.run([CONFIG["modprobe"], "vfio-pci"], check=True)
        for bdf in DEVICES:
            (SYS / bdf / "driver_override").write_text("vfio-pci\n")
        # With all users refused and device opens gated, retire the NVIDIA
        # kernel clients before removing its PCI device. Never force unload.
        subprocess.run([CONFIG["modprobe"], "-r", "nvidia_drm", "nvidia_modeset", "nvidia_uvm", "nvidia"], check=True)
        for bdf in DEVICES:
            device = SYS / bdf
            if (device / "driver/unbind").exists():
                (device / "driver/unbind").write_text(bdf)
            Path("/sys/bus/pci/drivers_probe").write_text(bdf)
        if any(v != "vfio-pci" for v in drivers().values()):
            raise RuntimeError("VFIO driver binding did not complete")
        subprocess.run([CONFIG["udevadm"], "settle"], check=True)
        for bdf in DEVICES:
            group_id = (SYS / bdf / "iommu_group").resolve().name
            node = Path("/dev/vfio") / group_id
            os.chown(node, 1001, 302)
            os.chmod(node, 0o600)
        print(json.dumps({"state": "vfio", "drivers": drivers()}))
    except Exception:
        restore(run_probe=False)
        raise


def restore(run_probe=True):
    validate()
    busy = owners()
    if any(a["kind"] in {"vm", "vfio"} for a in busy):
        raise RuntimeError("A process still owns the VFIO device; Windows has not released NVIDIA")
    for bdf, (_, expected) in reversed(list(DEVICES.items())):
        device = SYS / bdf
        actual = drivers()[bdf]
        if actual == "vfio-pci":
            (device / "driver/unbind").write_text(bdf)
        elif actual and actual != expected:
            raise RuntimeError(f"Unexpected driver {actual} at {bdf}")
        (device / "driver_override").write_text("\n")
        subprocess.run([CONFIG["modprobe"], expected], check=True)
        if not (device / "driver").exists():
            Path("/sys/bus/pci/drivers_probe").write_text(bdf)
        (device / "power/control").write_text("auto\n")
    subprocess.run([CONFIG["modprobe"], "--all", "nvidia", "nvidia_modeset", "nvidia_drm", "nvidia_uvm"], check=True)
    subprocess.run([CONFIG["udevadm"], "settle"], check=True)
    saved = STATE / "permissions.json"
    if saved.exists():
        for target, mode in json.loads(saved.read_text()).items():
            if Path(target).exists() and Path(target).is_char_device():
                os.chmod(target, mode)
        saved.unlink()
    if any(v != DEVICES[k][1] for k, v in drivers().items()):
        raise RuntimeError("NVIDIA did not return to Linux; no additional reset will be attempted")
    if run_probe:
        subprocess.run([CONFIG["cuda_probe"]], timeout=40, check=True)
        deadline = time.monotonic() + 60
        while time.monotonic() < deadline:
            displays = active_displays()
            if displays:
                print(json.dumps({'state': 'linux', 'cuda': 'passed', 'power': 'awake',
                                  'reason': 'active-display', 'displays': displays}))
                return
            if all(collector.read_text(SYS / bdf / "power/runtime_status") == "suspended" for bdf in DEVICES):
                print(json.dumps({"state": "linux", "cuda": "passed", "power": "suspended"}))
                return
            time.sleep(1)
        print(json.dumps({"state": "linux", "cuda": "passed", "power": "awake", "owners": owners()}))
        raise RuntimeError("CUDA recovered, but NVIDIA has not suspended after 60 seconds; see owner report")


def main():
    if os.geteuid() != 0 or len(sys.argv) != 2 or sys.argv[1] not in {"inspect", "prepare", "release"}:
        raise RuntimeError("Use the configured sudo rule: precision-windows-gpu inspect|prepare|release")
    STATE.mkdir(mode=0o755, exist_ok=True)
    with (STATE / "lock").open("w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        if sys.argv[1] == "inspect":
            validate()
            print(json.dumps({"drivers": drivers(), "owners": owners()}))
        elif sys.argv[1] == "prepare":
            prepare()
        else:
            restore()


if __name__ == "__main__":
    try:
        main()
    except Exception as error:
        print(str(error), file=sys.stderr)
        sys.exit(1)
