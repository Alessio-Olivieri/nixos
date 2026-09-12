# Windows on the Precision 7560

The two launchers use the existing Windows installation, disk, OVMF variables and TPM. Choose a mode before starting Windows; another launch is refused while it is running.

- **Windows — Gaming** lends the NVIDIA A4000 to Windows and opens Looking Glass on the laptop's Intel-driven internal screen. Close Linux programs that use NVIDIA yourself before starting it. A refused launch identifies the owners and leaves their work running.
- **Windows — Light** opens the normal virtual display. NVIDIA remains available to Linux, including Ollama.
- **Windows — TI-Nspire USB** provides a direct per-device connection for the running Windows session. Windows device detection passed, but recognition in Student Software through this path remains unverified. For the validated calculator workflow, use Light's SPICE selector below. The direct chooser does not start Windows or open a second viewer.

Light's viewer also offers its USB selection button in the window header (the sound-card shaped icon in remote-viewer 11). Three redirection channels are available, with automatic attachment disabled. Use either this selector or the TI-Nspire launcher for a given device, not both simultaneously. Looking Glass uses the separate TI-Nspire launcher. No physical USB controller is assigned to Windows.

If you unplug a calculator attached with the TI-Nspire launcher, choose **Disconnect TI-Nspire from Windows** before connecting its newly enumerated entry. This removes the old guest attachment; it does not erase calculator files. The selector rechecks the device identity and refuses stale USB addresses.

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

## Configuration and recovery

Source is isolated in `/home/lexyo/worktrees/precision-gpu-vm-handoff`, branch `codex/precision-gpu-vm-handoff-20260911`. The user's `/etc/nixos` master and its original untracked files are preserved. To rebuild this configuration later with the user's normal sudo authentication:

```sh
sudo nixos-rebuild switch --flake /home/lexyo/worktrees/precision-gpu-vm-handoff#precision
```

Boot-time IOMMU, kvmfr and the fresh desktop session require booting the configured generation. A switch from recovery generation 145 does not enable IOMMU in an already running kernel. Do not try repeated GPU resets to work around this. Generations 143, 144 and 145 are retained as recovery choices; they predate the completed runtime integration.

Cold Windows backups and test evidence remain under `~/.local/state/precision-gpu-maintenance/`. Do not overwrite a live Windows disk or TPM with backups. Linux disk password/TPM enrollments, firmware and battery policy were preserved. Ollama remains manually started with the existing `ai-start` workflow and uses CUDA on the A4000. The small `qwen3:0.6b` model was retained from validation.

See `maintenance/FINAL-REPORT.md` and the durable checkpoint for the actual final state and outstanding validation.
