#!/usr/bin/env python3
"""Report NVIDIA runtime state and device-file owners without GPU ioctls.

Only sysfs metadata and procfs process metadata are read. Device nodes are never
opened; nvidia-smi, NVML, CUDA and graphics libraries are never loaded.
"""

import argparse
import json
import os
from pathlib import Path
import re
import signal
import sys
import tempfile
import threading
import time
import unicodedata


def read_text(path, default=""):
    try:
        return path.read_text(errors="replace").strip()
    except OSError:
        return default


def read_link(path):
    try:
        return os.readlink(path)
    except OSError:
        return ""


def children(path):
    try:
        return list(path.iterdir())
    except OSError:
        return []


def tidy(value):
    value = "".join(c for c in value if unicodedata.category(c)[0] != "C")
    return " ".join(value.split())[:80]


def basename(value):
    return value.removesuffix(" (deleted)").replace("\\", "/").rsplit("/", 1)[-1]


def unwrap(value):
    return re.sub(r"(?:-wrapped|\.wrapped)(?:_\d+)?$", "", basename(value).lstrip("."))


def clean_name(executable, arguments, comm, virtual_machine=False):
    """Keep only app names, never a complete command or store path."""
    if virtual_machine:
        # -name is QEMU's explicit guest label. Other arguments may be secrets.
        for index, arg in enumerate(arguments[:-1]):
            if arg == "-name":
                guest = arguments[index + 1].split(",", 1)[0]
                guest = guest.removeprefix("guest=")
                guest = tidy(basename(guest))
                if guest:
                    return f"VM: {guest}"
        return "Virtual machine"

    name = unwrap(executable or (arguments[0] if arguments else comm))
    low = name.lower()
    # Current Ollama embeds llama-server under its own package directory.
    # Standalone llama.cpp keeps its own name; inspect only executable identity.
    if low == "llama-server" and re.search(r"/[^/]*-ollama-[^/]+/", executable):
        return "Ollama"

    if low.startswith(("wine", "wineserver")) or low in {"preloader", "proton"}:
        candidates = [basename(arg) for arg in arguments if arg.lower().endswith(".exe")]
        if candidates:
            return tidy(candidates[-1]) or "Windows application"
        return "Wine" if "server" not in low else "Wine server"

    aliases = {
        "firefox": "Firefox", "firefox-bin": "Firefox",
        "chrome": "Chrome", "chromium": "Chromium",
        "steam": "Steam", "steamwebhelper": "Steam",
        "lutris": "Lutris", "stellaris": "Stellaris", "showtime": "Showtime",
        "ollama": "Ollama", "ollama_llama_server": "Ollama",
        "llama-server": "llama.cpp", "gnome-shell": "GNOME Shell",
        "xwayland": "Xwayland",
        "looking-glass-client": "Looking Glass", "code": "VS Code",
        "nvidia-persistenced": "NVIDIA persistence service",
    }
    if low in aliases:
        return aliases[low]
    if low.startswith("python"):
        # Distinguish script entrypoints without displaying arguments or paths.
        for arg in arguments[1:]:
            if arg.startswith("-"):
                if arg in {"-c", "-m"}:
                    break
                continue
            script = unwrap(arg)
            if script.lower() in aliases:
                return aliases[script.lower()]
            if script.endswith((".py", ".pyw")):
                return tidy(f"Python: {script}")
            break
        return "Python"
    return tidy(name or comm) or "Unnamed process"


def device_snapshot(device):
    runtime = read_text(device / "power/runtime_status", "unknown")
    driver = basename(read_link(device / "driver")) or "unbound"
    slot = device.name.rsplit(".", 1)[0] + "."
    functions = {
        item.name: read_text(item / "power/runtime_status", "unknown")
        for item in children(device.parent)
        if item.name.startswith(slot)
    }
    return runtime, driver, functions


def device_targets(device, nvidia_node):
    targets = {nvidia_node}
    for node in children(device / "drm"):
        if re.fullmatch(r"(?:card\d+|renderD\d+)", node.name):
            targets.add(f"/dev/dri/{node.name}")
    vfio_targets = set()
    group = basename(read_link(device / "iommu_group"))
    if group.isdigit():
        vfio_targets.add(f"/dev/vfio/{group}")
    for node in children(device / "vfio-dev"):
        if re.fullmatch(r"vfio\d+", node.name):
            vfio_targets.add(f"/dev/vfio/devices/{node.name}")
    return targets, vfio_targets


def scan_processes(proc, targets, vfio_targets):
    applications = {}
    denied = 0
    try:
        entries = list(proc.iterdir())
    except OSError:
        return [], {"scanned": True, "complete": False, "denied": 1}, 0
    for entry in entries:
        if not entry.name.isdigit():
            continue
        relevant = False
        vfio_owner = False
        try:
            fds = list((entry / "fd").iterdir())
        except PermissionError:
            denied += 1
            continue
        except OSError:
            continue  # Process exited between directory reads.
        for fd in fds:
            try:
                target = os.readlink(fd).removesuffix(" (deleted)")
            except PermissionError:
                denied += 1
                continue
            except OSError:
                continue
            if target in targets or target in vfio_targets:
                relevant = True
                vfio_owner |= target in vfio_targets
        if not relevant:
            continue
        try:
            arguments = (entry / "cmdline").read_bytes().decode(errors="replace").rstrip("\0").split("\0")
        except OSError:
            arguments = []
        executable = read_link(entry / "exe")
        virtual_machine = vfio_owner and unwrap(executable).startswith("qemu-system-")
        name = clean_name(executable, arguments,
                          read_text(entry / "comm"), virtual_machine)
        kind = "vm" if virtual_machine else "vfio" if vfio_owner else "application"
        key = (name, kind)
        app = applications.setdefault(key, {"name": name, "kind": kind, "pids": []})
        app["pids"].append(int(entry.name))
    ordered = sorted(applications.values(), key=lambda app: app["name"].casefold())
    for app in ordered:
        app["pids"].sort()
        app["pid_count"] = len(app["pids"])
        app["pids"] = app["pids"][:64]
    return ordered[:64], {"scanned": True, "complete": denied == 0, "denied": denied}, max(0, len(ordered) - 64)


def collect(bdf="0000:01:00.0", nvidia_node="/dev/nvidia0", interval=5,
            sys_root=Path("/sys"), proc_root=Path("/proc")):
    device = sys_root / "bus/pci/devices" / bdf
    result = {
        "version": 1, "updated_at": time.time(), "interval": interval,
        "device": bdf, "state": "unknown", "runtime": "unknown",
        "driver": "unknown", "functions": {}, "applications": [],
        "visibility": {"scanned": False, "complete": False, "denied": 0},
        "omitted_applications": 0, "detail": "",
    }
    if read_text(device / "vendor") != "0x10de":
        result["detail"] = "NVIDIA device not found at the configured PCI address."
        return result
    before = device_snapshot(device)
    runtime, driver, functions = before
    result.update(runtime=runtime, driver=driver, functions=functions)
    if driver not in {"nvidia", "vfio-pci"}:
        result["detail"] = "NVIDIA is unbound or its Linux driver is unavailable."
        return result
    if driver == "nvidia" and functions and all(state == "suspended" for state in functions.values()):
        result["state"] = "intel"
        result["detail"] = "NVIDIA is runtime-suspended."
        return result  # In particular, do not scan processes or invoke any GPU query.

    targets, vfio_targets = device_targets(device, nvidia_node)
    if driver != "vfio-pci":
        vfio_targets = set()
    apps, visibility, omitted = scan_processes(proc_root, targets, vfio_targets)
    if device_snapshot(device) != before:
        result["detail"] = "GPU state changed during this sample; refreshing."
        return result
    result.update(applications=apps, visibility=visibility, omitted_applications=omitted)

    if driver == "vfio-pci":
        result["state"] = "passthrough"
        result["detail"] = ("A virtual machine holds this GPU's VFIO device."
                            if any(app["kind"] == "vm" for app in apps)
                            else "Reserved for passthrough; no VM owner identified.")
        if functions and all(state == "suspended" for state in functions.values()):
            result["detail"] += " NVIDIA is runtime-suspended."
    elif apps or "active" in functions.values():
        result["state"] = "nvidia"
        if runtime == "suspended":
            result["detail"] = "NVIDIA graphics is suspended; another PCI function is awake."
        elif apps:
            result["detail"] = "Applications holding NVIDIA device handles."
        else:
            result["detail"] = "NVIDIA is awake; no application owner identified."
    else:
        result["detail"] = "NVIDIA runtime state is unavailable or changing."
    return result


def write_status(path, status):
    # Parent must be a root-owned RuntimeDirectory in the installed service.
    fd, temporary = tempfile.mkstemp(prefix=".status-", dir=path.parent)
    try:
        with os.fdopen(fd, "w") as stream:
            json.dump(status, stream, ensure_ascii=True)
            stream.write("\n")
            stream.flush()
            os.fchmod(stream.fileno(), 0o644)
        os.replace(temporary, path)
    finally:
        try:
            os.unlink(temporary)
        except FileNotFoundError:
            pass


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--device", default="0000:01:00.0")
    parser.add_argument("--nvidia-node", default="/dev/nvidia0")
    parser.add_argument("--interval", type=int, default=5)
    parser.add_argument("--output", type=Path)
    parser.add_argument("--once", action="store_true")
    args = parser.parse_args()
    if not re.fullmatch(r"[0-9a-fA-F]{4}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}\.[0-7]", args.device):
        parser.error("--device must be a full PCI address")
    if not re.fullmatch(r"/dev/nvidia\d+", args.nvidia_node):
        parser.error("--nvidia-node must identify a specific NVIDIA device")
    if not 2 <= args.interval <= 30:
        parser.error("--interval must be between 2 and 30 seconds")
    if not args.once and not args.output:
        parser.error("continuous operation requires --output")

    stopping = threading.Event()
    signal.signal(signal.SIGTERM, lambda *_: stopping.set())
    signal.signal(signal.SIGINT, lambda *_: stopping.set())
    while not stopping.is_set():
        status = collect(args.device, args.nvidia_node, args.interval)
        if args.output:
            write_status(args.output, status)
        if args.once:
            print(json.dumps(status, ensure_ascii=True, indent=2))
            return 0
        stopping.wait(args.interval)
    return 0


if __name__ == "__main__":
    sys.exit(main())
