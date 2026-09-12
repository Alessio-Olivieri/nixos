# Component update and live validation — 2026-09-12 14:28 CEST

The component update succeeded. **The full Gaming/Linux-HDMI handoff remains
incomplete.** This update preserves the current Intel-primary GNOME session
and repairs suspended-owner reporting and cross-session display restoration
guards. It does not implement compositor GPU removal or external guest display
selection.

## Authentication and activation

The repeated instruction to run `sudo -v` in a different terminal was wrong.
The local sudoers configuration has no timestamp-type override; the installed
manual documents separate terminal tickets by default. The user's successful
terminal authentication did not authenticate the agent's no-TTY process.
See [sudo's timestamp documentation](https://www.sudo.ws/docs/man/1.9.14/sudoers.man.pdf).
The password supplied in chat was not used or stored by this update.

The local Kitty command invoked an immutable, fixed update script via sudo.
Its first dry preview was rejected because the parser did not recognize
`would activate the configuration...`; no activation occurred. The exact
preview became a regression fixture, and the correction retained the first
failure record. Only this specific pre-activation parser failure could be
resumed once; an actual activation failure cannot be retried. Six preview and
retry-boundary tests pass.

At14:23:49, activation completed with exit0 and activation_attempts=1:

- Current system: `/nix/store/c4d4khxkv2bj5m1k6gvh3v5576hmcpw0-nixos-system-precision7560-26.05.20260611.a037402`.
- Booted system and saved profile154: `/nix/store/xkga9k4w11g6yzbzp0pgwgsfg7p1c5cw-nixos-system-precision7560-26.05.20260611.a037402`.
- GNOME PID77549, start tick811511, remained alive. It still maps
  `/nix/store/ms7m1bj4x2rw0hsym8lfa7yssrn3znwh-mutter-50.1/lib/libmutter-18.so.0.0.0`.
- The candidate's kernel/initrd/module tree, kernel parameters, GNOME executable,
  GDM configuration/service, user-manager dropin and udev rules match the prior
  active system. No logout, reboot or saved boot-generation update occurred.
- Collector PID92079 runs
  `/nix/store/1hmg5nf2sh3ad157mswsvrlsz824jh6p-precision-gpu-indicator-0.1.0/bin/gpu-indicator-collector`,
  with PrivateDevices=yes. Controller is
  `/nix/store/0xzy14psywp0nf9vq9rnrhz0ak3pl0f8-precision-windows-1.0/bin/precision-windows`.

The actual activation log stopped/started accounts-daemon and gpu-indicator,
reloaded system/user D-Bus, restarted Home Manager/polkit and the ordinary user
activation unit. NetworkManager-dispatcher started; NetworkManager and the
desktop were not restarted. The unpatched907y5... candidate was not used.

## Tests that actually passed

- Journal evidence still identifies Intel card1 as the preferred primary;
  the loaded NVIDIA module is595.71.05. PaperWM50.0.1 and the supplied GPU
  indicator both report ACTIVE. AT-SPI reads the live panel label `NVIDIA · 4`
  and its awake/device-holder description when HDMI is active.
- A real host CUDA kernel produced and verified32 values after activation,
  then passed again concurrently with Windows Light.
- The corrected installed display bridge matched the durable recovery snapshot
  before temporarily disabling HDMI. Four distinct collector samples over15s
  reported `intel`, both PCI functions `suspended`, complete process visibility,
  and names `GNOME Shell`/`Xwayland`. Root inspect independently confirmed the
  same two holders. This proves the new collector exposes holders while the
  device suspends; no NVML, CUDA or GPU ioctl polling was used by monitoring.
- The original HDMI/eDP layout restored successfully and its complete D-Bus
  snapshot matched. NVIDIA then correctly reported awake for active HDMI.
  Bus ID8540655f57739ed0ebb8e5403124b346, owner:1.7 and shell77549 are unchanged.
  monitors.xml SHA256 remains
  `66db6c80178131fa3037e1982d2600ccdf0c365810cadbdd467187ba66b0a8b0`.
- Actual Gaming display preflight refused Xwayland77994 before any monitor or
  GPU change; complete before/after snapshots matched. No VFIO prepare/unbind
  was attempted around a holder.
- Windows Light started14:26:16 (controller92921, QEMU92923). QMP reported
  running, the guest agent answered OS information, and a real QXL screenshot
  showed the Windows sign-in/PIN screen. Both Linux monitors remained active;
  QEMU arguments contained no VFIO device. No guest sign-in was required.
- Exiting only the test-created remote-viewer process exercised the controller's
  viewer-exit path: clean shutdown requested14:27:56; stopped14:27:59; QEMU0,
  swtpm exited, status has no error. No forced guest poweroff was used.

The compiled package/build tests also passed:17 collector tests,32 controller
and host-display tests, the existing11 maintenance tests and6 new preview tests.
These are distinguished from the live results above. No new Ollama generation,
Gaming cycle, physical guest HDMI, USB application or game test is claimed;
their earlier results are historical. Ollama was inactive and left inactive.

## Remaining blocker, reproducibility and cleanup

The GPU can runtime-suspend while GNOME/Xwayland retain open device handles.
Suspension is not permission to unbind it. The zero-owner gate remains intact.
Seamless Gaming from an HDMI-owning GNOME session requires a compositor GPU
release/re-add implementation that has not been supplied or validated. Another
logout or reboot was not attempted.

The earlier external selector draft was withdrawn: malformed Zenity columns,
an unverified DisplaySwitch request from QGA's noninteractive session, and a
blocking wait before normal controller shutdown handling. Windows display
configuration requires access to the console desktop; see
[Microsoft's QueryDisplayConfig contract](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-querydisplayconfig).
No external-mode success follows from that draft's mocked tests or Nix build.

Source remains in the isolated worktree/branch and is not merged into
`/etc/nixos`. Its original three untracked files retain their recorded hashes.
**Do not activate the normal unpatched `#precision` output as the completed
HDMI solution.** The current c4d4... closure was built with the explicit patched
configuration output; `test` deliberately left boot generation154 intact.

The activation commands have exited and their terminal windows are gone. No
new sudoers, root service, socket server, autostart, autologin or sleep override
was installed. The former session-test helper is not-found/inactive and its
one-shot autostart is absent. Linger=no. Only permanent inspect/prepare/release
NOPASSWD permissions remain. The ordinary current Codex application scope
persists, but has no future startup trigger.

Activation records are retained in `/run/precision-gpu-component-update-20260912`
and copied into `~/.local/state/precision-gpu-maintenance/component-update-*`.
The Windows sign-in capture is `component-light.png` there. Do not remove or
reset the consumed attempt record to retry this update.
