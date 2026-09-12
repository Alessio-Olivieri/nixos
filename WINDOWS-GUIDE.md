# Windows on the Precision 7560

**Maintenance status, September12 evening:** The lifecycle-repaired Mutter is
active. Two physical Gaming GPU-return cycles preserved the same GNOME session,
restored both Linux displays and passed host CUDA; the user also reports their
manual tests working. Automatic TI-Nspire forwarding is now the default in both
modes. Windows now includes remembered laptop/HDMI output shortcuts, without mirroring.
Current evidence and repair status are in [the report](maintenance/FINAL-REPORT.md).

The two launchers use the existing Windows installation, disk, OVMF variables and TPM. Choose a mode before starting Windows; another launch is refused while it is running.

- **Windows — Gaming** passes NVIDIA to Windows. Inside Windows, double-click **Windows on laptop** or **Windows on HDMI**; no administrator prompt. The choice is remembered. If HDMI is absent, Looking Glass is the fallback without forgetting your preference. Linux HDMI returns after Windows stops. Compositor and GPU-owner safety checks remain mandatory.
- **Windows — Light** opens the normal virtual display. NVIDIA remains available to Linux, including Ollama.
- **Windows — TI-Nspire USB** lets you pause or resume automatic calculator forwarding for the running Windows session. No selection is needed normally. The calculator was detected with Windows status OK/problem0, and the user confirmed it appeared in their application.

The automatic rule matches TI-Nspire CX II USB0451:e022 only, not a particular USB
port or changing device address. It is present from startup in both modes and
waits for the calculator if unplugged. QEMU handles subsequent reinsertions.
Only one matching calculator is forwarded. Other USB devices remain manual via
Light's USB selector; do not also select the calculator there. No physical USB
controller is assigned to Windows. This uses QEMU's documented
[vendor/product USB matching](https://www.qemu.org/docs/master/system/devices/usb).

Disconnect in the TI-Nspire launcher pauses forwarding until enabled again or
Windows restarts. Unplug/replug no longer requires clearing a stale USB address.
Physical reconnect behavior remains a manual check; no automated unplug/reset
test was performed after the user's request to stop test cycles.

Closing the viewer requests a normal Windows shutdown. Wait until Windows has actually stopped and Gaming has returned NVIDIA to Linux before starting another mode or powering off the laptop. If Windows delays shutdown, the controller keeps it running and shows a timeout after three minutes; it never forces power off.

Useful commands:

```sh
precision-windows status
precision-windows shutdown
precision-windows view
precision-windows console
precision-windows usb
journalctl --user -u precision-windows
```

`view` reopens the normal viewer; `console` opens the SPICE recovery console when the previous viewer is closed. Neither starts a stopped guest. A console cannot replace an already open Looking Glass connection.

The GPU indicator reports Intel when both NVIDIA functions are runtime-suspended, NVIDIA when awake, and sanitized application names when observable. VFIO reservation is distinct from an identified running VM. GPU ? indicates missing/stale data. Device handles indicate ownership, not GPU utilization. The collector does not poll NVML or nvidia-smi.

Looking Glass uses the pinned upstream development snapshot B7-826-236efcb1 with its matching signed Windows indirect display/input drivers and Linux kvmfr module. The internal-screen path is Windows NVIDIA rendering, shared memory, then Intel presentation. The user reported good responsiveness during hands-on testing; no numeric input-to-photon latency or game FPS was measured.

Windows already has the working NVIDIA580.92 driver. Task Manager's Performance tab should show RTX A4000 in Gaming; NVIDIA is intentionally absent in Light. FurMark/OpenGL games belong in Gaming. Actual FurMark rendering and NVIDIA OpenGL4.6 context creation were verified; seeing QXL or Looking Glass as additional display adapters is normal.

Audio uses the existing Windows High Definition Audio device over SPICE to Linux.
The pinned Looking Glass client's emulated USB audio reported Windows Code10, so
the launcher explicitly sets `spice:usbAudio=no`. This does not change TI-Nspire
USB forwarding. A viewer already running needs a normal Windows shutdown/relaunch
to take this setting. Select Speakers (High Definition Audio Device) in Windows
for Linux speaker/headphone output; audible playback still needs user confirmation.

The Windows startup helper follows the saved display choice and leaves Light
alone. Early firmware boot may still appear on HDMI before Windows drivers load.
Keep Looking Glass open even in HDMI mode for input/audio; closing it requests
Windows shutdown. See [the display-fix guide](maintenance/WINDOWS-DISPLAY-FIX.md).

Linux and the Windows helper version are Nix-managed. Rebuild packages the
installer; `precision-windows-guest-sync.service` reconciles it in a running guest
or after its next launch. Unchanged versions leave the watcher and preference
alone. No manual copying, PowerShell installation or driver download is needed.

This is plug-and-play for the **existing Windows installation**, not installation
onto an empty disk. Its disk, OVMF variables, TPM, license, QEMU Guest Agent and
signed NVIDIA/Looking Glass drivers remain preserved prerequisites. The compiled
Windows helper executables are generated from repository source, not irreplaceable
manually supplied binaries. The saved output choice is mutable user state.

Guest sync never starts/reboots Windows, kills applications or retries endlessly.
Inspect errors with `journalctl --user -u precision-windows-guest-sync.service`.
After correcting an error, retry explicitly with
`systemctl --user start precision-windows-guest-sync.service`.

## Configuration and recovery

Source was developed on the isolated branch `codex/precision-gpu-vm-handoff-20260911`
and integrated into `/etc/nixos` master at the user's request. The original
untracked handoff, indicator ZIP and `precision-vfio.nix` are preserved; the latter
is not the active VM integration module. Use `/etc/nixos` for normal rebuilds:

```sh
sudo nixos-rebuild switch --flake /etc/nixos#precision
```

Boot-time IOMMU, kvmfr and the fresh desktop session require booting the configured generation. A switch from recovery generation 145 does not enable IOMMU in an already running kernel. Do not try repeated GPU resets to work around this. Generations 143, 144 and 145 are retained as recovery choices; they predate the completed runtime integration.

The lifecycle repair and automatic USB rule are now promoted to the normal
worktree output and saved system generation. **Generation154 is retained for
recovery**, with NVIDIA isolated from GNOME and therefore no Linux HDMI.
No reboot is needed to keep using the current session. Mutter updates require
the patch to build and a matching new graphical session; Gaming refuses an old
mapped library rather than bypassing the guard. Future upstream compatibility
is not guaranteed by today's tests.
Older bootstrap recovery generations can restore historical temporary
maintenance settings; they are not the preferred daily configuration.

Cold Windows backups and test evidence remain under `~/.local/state/precision-gpu-maintenance/`. Do not overwrite a live Windows disk or TPM with backups. Linux disk password/TPM enrollments, firmware and battery policy were preserved. Ollama remains manually started with the existing `ai-start` workflow and uses CUDA on the A4000. The small `qwen3:0.6b` model was retained from validation.

See `maintenance/FINAL-REPORT.md` and the durable checkpoint for the actual final state and outstanding validation.
