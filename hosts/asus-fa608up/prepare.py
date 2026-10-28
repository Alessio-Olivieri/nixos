#!/usr/bin/env python3
"""Collect this ASUS's installation data; never partition or format disks."""
import argparse
from datetime import datetime, timezone
from pathlib import Path
import re
import subprocess


def detect_gpus(pci_root):
    found = {"0x1002": [], "0x10de": []}
    for device in sorted(pci_root.iterdir()):
        if not re.fullmatch(r"[0-9a-f]{4}:[0-9a-f]{2}:[0-9a-f]{2}\.[0-7]", device.name):
            continue
        try:
            vendor = (device / "vendor").read_text().strip()
            device_class = int((device / "class").read_text().strip(), 16)
        except (OSError, ValueError):
            continue
        if device_class >> 16 == 0x03 and vendor in found:
            found[vendor].append(device.name)
    if any(len(devices) != 1 for devices in found.values()):
        raise ValueError("Expected exactly one AMD and one NVIDIA display controller. "
                         "Use Hybrid/Standard GPU mode, disconnect eGPUs and retry. "
                         f"Detected: {found}")
    return found["0x1002"][0], found["0x10de"][0]


def machine_config(amd, nvidia):
    return ("# Generated on the ASUS; keep these addresses local to this host.\n"
            "{ ... }: {\n"
            "  hardware.asus-fa608up = {\n"
            "    configured = true;\n"
            f'    amdPciAddress = "{amd}";\n'
            f'    nvidiaPciAddress = "{nvidia}";\n'
            "    # irCamera = \"/dev/v4l/by-id/REPLACE-WITH-VERIFIED-IR-DEVICE\";\n"
            "  };\n}\n")


def prepare(root, output, sysfs=Path("/sys"), force=False):
    model = (sysfs / "class/dmi/id/product_name").read_text().strip()
    if "FA608UP" not in model.upper():
        raise ValueError(f"This helper is for FA608UP only; detected {model!r}.")
    amd, nvidia = detect_gpus(sysfs / "bus/pci/devices")
    output = output.resolve()
    if not (output / "default.nix").is_file():
        raise ValueError("Output must be the repository's hosts/asus-fa608up directory.")
    machine = output / "machine.nix"
    if not force and "configured = true" in machine.read_text():
        raise ValueError("Already configured. Use --force to regenerate with backups.")
    # --show-hardware-config prints only; it does not overwrite /etc/nixos.
    result = subprocess.run(
        ["nixos-generate-config", "--root", str(root.resolve()), "--show-hardware-config"],
        check=True, text=True, capture_output=True,
    )
    if not result.stdout.strip():
        raise ValueError("nixos-generate-config returned an empty configuration.")
    contents = {"hardware-configuration.nix": result.stdout,
                "machine.nix": machine_config(amd, nvidia)}
    stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S%fZ")
    for name in contents:
        path = output / name
        if path.exists():
            path.with_name(f"{name}.{stamp}.bak").write_bytes(path.read_bytes())
    # Keep configured=false until the matching disk configuration is in place.
    for name, content in contents.items():
        path = output / name
        temporary = path.with_suffix(".nix.tmp")
        temporary.write_text(content)
        temporary.replace(path)
    print(f"Prepared {output}: AMD {amd}, NVIDIA {nvidia}.")
    print("Review both generated files, especially mounts/LUKS/swap, then build before switching.")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path("/"),
                        help="Installed root, or /mnt when running from the installer")
    parser.add_argument("--output", type=Path, default=Path(__file__).resolve().parent)
    parser.add_argument("--force", action="store_true", help="Regenerate with timestamped backups")
    args = parser.parse_args()
    try:
        prepare(args.root, args.output, force=args.force)
    except (OSError, ValueError, subprocess.CalledProcessError) as error:
        parser.exit(1, f"Preparation failed: {error}\n")


if __name__ == "__main__":
    main()
