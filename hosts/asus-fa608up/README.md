# ASUS TUF Gaming A16 FA608UP — 240 W adapter

Flake target: `asus-fa608up`. Italian keyboard in the console, GDM and GNOME.
The target uses the repository's existing locked inputs; other host targets remain intact.

For this installed laptop, **do not rerun preparation**. See
[installed-system.md](installed-system.md) for verified controls, results and
remaining tests, and [windows.md](windows.md) for the Windows installation plan.

## Prepare on the ASUS

Keep the firmware/MUX in **Hybrid/Standard** mode so both GPUs are visible.
This repository cannot know the new machine's partitions, LUKS UUIDs or PCI topology.
Until prepared, an assertion intentionally prevents building/installing this host.

On an already installed NixOS system, from the repository root:

```sh
sudo python3 hosts/asus-fa608up/prepare.py
git diff -- hosts/asus-fa608up/hardware-configuration.nix hosts/asus-fa608up/machine.nix
sudo nixos-rebuild build --flake .#asus-fa608up
sudo nixos-rebuild boot --flake .#asus-fa608up
```

Reboot into the new generation after the build succeeds. Keep the previous boot
entry available while validating graphics, networking and suspend. The preparation
helper refuses other models and ambiguous/missing GPUs, backs up replaced files,
and runs `nixos-generate-config --show-hardware-config`. It never partitions,
formats, installs, changes firmware or enrolls TPM keys. `--force` regenerates
files with new backups. Review custom mounts because the generator reports the
currently mounted installation; it cannot reconstruct unmounted data partitions.

For a fresh installation, mount the intended root and EFI filesystems under
`/mnt` first, put this repository at `/mnt/etc/nixos`, and run from there:

```sh
sudo python3 hosts/asus-fa608up/prepare.py --root /mnt
sudo nixos-install --flake /mnt/etc/nixos#asus-fa608up
```

The two generated `.nix` files are already tracked, so Git-backed flake evaluation
includes their local modifications. Commit them if you want to preserve this
machine's installation configuration. Set a password for `lexyo` on a fresh install.
For an existing installation, preserve its original `system.stateVersion` and
Home Manager `home.stateVersion` with host-local overrides if they predate 26.05.

## Features carried over

| Precision feature | ASUS profile |
| --- | --- |
| GNOME, PaperWM, themes, shortcuts and apps | Same shared configuration and Home Manager modules; Italian input overrides German dconf settings |
| Firefox, VSCodium, Codex, eduroam, Obsidian, Syncthing and other tools | Same shared package set |
| PipeWire echo cancellation, Bluetooth, GSConnect, Tailscale, Flatpak and Podman | Same shared services |
| Steam, Lutris, Wine, Proton and MangoHud | Preserved with NVIDIA offload |
| Integrated desktop / dedicated apps | AMD Mesa default; `amd-only COMMAND` and `nvidia-offload COMMAND`, including 32-bit Vulkan |
| Stellaris GPU launchers | AMD and NVIDIA entries; quit Steam before changing GPU because an existing Steam process retains its environment |
| GPU indicator and passive process collector | Reused; AMD label and detected NVIDIA PCI address |
| On-demand Ollama/Open WebUI | `ai-start` / `ai-stop`, CUDA package without the A2000-only architecture restriction |
| Battery background policy | Reused with generic AC detection and a 60-second timer, independent of AC/ACAD/ADP0 naming |
| Power, fans, RGB and charge limits | `asusd`, `asusctl` and ROG Control Center, where supported by the firmware |
| Windows/VM tooling | Existing Quickemu/SPICE/USB redirection plus libvirt, virt-manager, software TPM and Looking Glass client |
| TPM-aware encrypted boot | systemd initrd and TPM support; disk definitions and enrollment must come from this machine |
| Face authentication | Opt-in after verifying the IR camera path |

Use ROG Control Center to select charging limits (for example 80%), platform
profiles, lighting and supported fan controls. TLP, thermald and GNOME's
power-profiles-daemon are disabled to avoid fighting ASUS profile management.
The battery charging GNOME extension is disabled for this host because asusd
owns charging. It remains enabled on the existing hosts.

The 240 W designation describes the **adapter**, not a GPU or CPU power limit.
Firmware retains its stock limits. No forced power limits, undervolting, CPU MSR
writes or unverified Dynamic Boost configuration are applied.

## Hardware-dependent follow-up

- The custom Precision Windows Gaming/Light controller is not enabled: it embeds
  A2000 PCI IDs, Intel DRM paths, existing VM/disk locations, a user UID and
  Precision-specific Mutter patches. Libvirt/Quickemu remain available, but no
  Windows image is copied or created. GPU passthrough requires inspecting this
  laptop's IOMMU groups, display wiring and GPU reset behavior before adapting it.
- NVIDIA-backed HDMI/USB-C outputs are not hidden from Mutter. Test each port and
  suspend/resume on the actual laptop. The open NVIDIA modules are required for
  the RTX 5070; NVIDIA driver and kernel versions come from the existing lock.
- For face login, identify and test the IR node with `v4l2-ctl --list-devices` and
  `linux-enable-ir-emitter`, then set `hardware.asus-fa608up.irCamera` in
  `machine.nix` to a stable `/dev/v4l/by-id/...` path if available. Rebuild, enroll
  with `sudo howdy add`, and retain password access. No `/dev/video2` is assumed.
- Hibernation is configured by the imported `hibernate.nix` for the encrypted
  LVM layout: volume group `nixos`, logical volumes `root` and `swap`. Create
  swap at least as large as RAM (20 GiB for this 16 GiB machine). Resume uses
  `/dev/mapper/nixos-swap`; NVIDIA video-memory backups use `/var/tmp` on the
  encrypted root. No separate swap encryption or swapfile offset is needed.
  After installation, save work and test `systemctl hibernate`, then power on
  and unlock the disk. Hardware resume still needs validation.
- TPM unlocking requires separate enrollment after inspecting the generated
  LUKS disk configuration.
- The old shared NTFS UUID and USB network NAT setup are disabled for this host.
  Add this laptop's actual data disks/network-sharing interfaces separately.

## Validate after boot

```sh
localectl status
gsettings get org.gnome.desktop.input-sources sources
lspci -nnk | grep -A3 -E 'VGA|3D|Display'
systemctl status asusd gpu-indicator
cat /run/gpu-indicator/status.json
amd-only vulkaninfo --summary
nvidia-offload vulkaninfo --summary
systemctl list-timers battery-background-policy.timer
```

Also check Wi-Fi, audio/microphone, webcam, keyboard brightness, fan/profile
controls, charging limits, unplug/replug behavior, external displays and
suspend/resume. A connected NVIDIA-wired display or CUDA application can keep
the dGPU awake; the indicator does not actively poll it with `nvidia-smi`.

Development checks:

```sh
python3 -B -m unittest discover -s hosts/asus-fa608up -p 'test_*.py' -v
(cd modules/precision-gpu-indicator && python3 -B -m unittest discover -s tests -v)
# Evaluates the complete host with synthetic hardware, then tests preparation:
nix build .#checks.x86_64-linux.asus-fa608up
# After preparing the host:
nix eval .#nixosConfigurations.asus-fa608up.config.system.build.toplevel.drvPath
```

Reference: [ASUS specifications](https://www.asus.com/it/laptops/for-gaming/tuf-gaming/asus-tuf-gaming-a16-2025/techspec/),
[NVIDIA open kernel modules](https://download.nvidia.com/XFree86/Linux-x86_64/570.144/README/kernel_open.html),
[asusctl manual](https://github.com/OpenGamingCollective/asusctl/blob/main/MANUAL.md).
