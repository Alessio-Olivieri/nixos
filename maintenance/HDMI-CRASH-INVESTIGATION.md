# HDMI handoff crash investigation — 2026-09-12

Update13:31 CEST: the separately approved single session test completed.
GNOME77549 now maps the patched Mutter, selects Intel primary and preserves
both displays; temporary test authority/autostart were removed. This does not
validate GPU hot-add/handoff. A further bus-identity guard gap was found and
corrected in source only. See [SESSION-TEST-RESULT.md](SESSION-TEST-RESULT.md).
The investigation narrative below records the earlier pre-test state.

Status: incomplete; do not deploy the experimental HDMI worktree or run Gaming
under its current host-HDMI policy. No hardware impossibility is established.
The original task's NVIDIA isolation caused the user's Linux HDMI regression.

## Direct evidence

The temporary ApplyMonitorsConfig request at12:27:00 CEST caused GNOME3544 to
SIGSEGV. Its core is retained locally by systemd. Offline GDB17.1 inspection
(auto-load and debuginfod disabled; no attachment to the live desktop) gives:

```
rdi = 0
rip = meta_monitor_is_for_lease + 7
mov 0x50(%rdi,%rax,1),%eax
meta_monitor_is_for_lease
update_resources
...
meta_monitor_manager_notify_monitors_changed
meta_monitor_manager_rebuild
```

Thus the null-monitor argument is confirmed, not just inferred from a stack
symbol. Before the crash, GetResources exposed NVIDIA HDMI while GetCurrentState
did not list its monitor. The replacement GNOME23329 started on the same boot,
selected Intel card1 as primary, and now has both HDMI-1 and eDP-1 at1920x1080.
The monitor configuration SHA256 remains
`66db6c80178131fa3037e1982d2600ccdf0c365810cadbdd467187ba66b0a8b0`.

## Source explanation and separate lifecycle obstacle

In [Mutter50.1 lease code](https://github.com/GNOME/mutter/blob/50.1/src/backends/native/meta-drm-lease.c#L187),
`is_connector_configured_for_lease()` checks the connector and output but calls
`meta_monitor_is_for_lease()` without checking the monitor returned from the
output. [GPU construction](https://github.com/GNOME/mutter/blob/50.1/src/backends/native/meta-gpu-kms.c)
reads GPU outputs, while the [monitor manager](https://github.com/GNOME/mutter/blob/50.1/src/backends/meta-monitor-manager.c)
associates outputs with monitors during its read-current-state/rebuild path.
The [native hot-add handler](https://github.com/GNOME/mutter/blob/50.1/src/backends/native/meta-backend-native.c#L611)
adds the GPU without explicitly reloading that catalogue. This explains the
observed mismatch. It also rejects a later addition using an already known
device path; adding a catalogue reload alone does not solve full removal/re-add.

There is a second, independent obstacle. The current Xwayland23758 holds the
NVIDIA card device while using Intel renderD128. Mutter's
[Wayland lease implementation](https://github.com/GNOME/mutter/blob/50.1/src/wayland/meta-wayland-drm-lease.c)
sends a nonprivileged card descriptor to lease clients. The upstream
[Xwayland lease implementation](https://github.com/mirror/xserver/blob/master/hw/xwayland/xwayland-drm-lease.c)
keeps that descriptor until the lease device is destroyed, rather than releasing
it just because a desktop monitor is disabled. This source path is consistent
with the observed handle; its provenance has not been instrumented in the live
Xwayland process. Do not exempt it from the final owner check or kill Xwayland.

## Changes prepared, not installed

- `display-guard.js`: before layout mutation, compare hardware-output and
  monitor catalogues, serials and identities; pin the D-Bus owner so an old
  operation cannot target a replacement session. Unsupported/ambiguous tiled
  configurations fail closed. Mutter's own serial validation remains in use.
- `host_display.py`: refuse restoration across GNOME restarts; skip applying an
  already-current layout. No writes to monitors.xml.
- Removed forced connector off/detect and synthesized HOTPLUG from the candidate.
  They did not repair the catalogue during the actual live test.
- `mutter-gpu-add-monitor.patch`: local build-only candidate adds a null check
  and reloads monitor state after a successful secondary GPU add. Not imported
  by the system configuration; not a complete detach/re-add implementation.
- The foreground activation helper now handles ordinary termination signals
  through cleanup in source. It has NOT been restarted; the old stale root-owned
  socket still needs exact authorized cleanup. SIGKILL cannot run cleanup.

Build the isolated Mutter candidate without changing the running system:

```sh
nix build --impure --no-link --cores 4 --max-jobs 1 --expr '
  let f = builtins.getFlake "/home/lexyo/worktrees/precision-gpu-vm-handoff";
  in import /home/lexyo/worktrees/precision-gpu-vm-handoff/maintenance/mutter-hdmi-candidate.nix
    { pkgs = f.nixosConfigurations.precision.pkgs; }'
```

## Validation limits and next gate

Twelve pure GJS guard regressions passed, including the observed catalogue
mismatch and GNOME replacement with a reused serial. The guarded source bridge
read the actual current two-monitor state successfully without applying changes.
Controller/display/indicator tests and Nix build results are tracked in the
checkpoint. These do not prove safe GPU unbind/rebind or live patched Mutter.

No GNOME restart, GPU transfer, VM start, root activation or reboot was performed
during this investigation. Further host activation needs fresh local authority:
the former three-activation helper has expired/died and cannot be reused.
The next live compositor test also needs a deliberately arranged session restart
after user work is saved; no seamless GPU-handoff success can be claimed yet.
Reboot budget remains exhausted. Keep generation154 as recovery, noting that its
intentional GPU isolation prevents Linux HDMI. Preserve all Windows disk, TPM,
firmware, login and encryption state.

The isolated patched Mutter build succeeded at
`/nix/store/ms7m1bj4x2rw0hsym8lfa7yssrn3znwh-mutter-50.1`.
Both patch hunks applied and compiled. Nixpkgs builds this package with
`-Dtests=disabled`; this is **compilation evidence only**, not a passing Mutter
runtime test suite. The default NixOS candidate does not include this patch.

An additional source constraint was confirmed in
`meta_kms_impl_device_update_states()`: on a failed device reopen, Mutter clears
the CRTC/plane/connector collections; ordinary updates do not reconstruct all
of them. Together with the duplicate-path early return on GPU-add, this rules
out claiming that a reload or an extra udev event alone implements GPU return.
A real lifecycle fix needs isolated compositor/native-KMS testing before it can
be deployed on the user's desktop.
