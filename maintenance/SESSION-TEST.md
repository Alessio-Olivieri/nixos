# One approved GNOME/Mutter session test — 2026-09-12

**Completed and temporary authority removed at13:30:20 CEST.** Read
[SESSION-TEST-RESULT.md](SESSION-TEST-RESULT.md) for live results and remaining
limitations. The instructions below describe the consumed one-test mechanism;
do not recreate it or reset its counters. No further logout/reboot is authorized.

The user answered **yes** to fresh local sudo authentication and one controlled
GNOME logout/login after saving work. This is a new, separate one-test grant,
not a reset of any old reboot or activation budget. No reboot is allowed.

## Fixed objects and bounds

- Candidate: `/nix/store/xl5mdhz28nwnr46ydj85cdyb77d77aqq-nixos-system-precision7560-26.05.20260611.a037402`.
- Pre-test live rollback: `/nix/store/zkvp6nbpf6swkm281sfpanvwkm2bhn3k-nixos-system-precision7560-26.05.20260611.a037402`.
- Saved/booted154 remains `/nix/store/xkga9k4w11g6yzbzp0pgwgsfg7p1c5cw-nixos-system-precision7560-26.05.20260611.a037402`.
- Patched Mutter library: `/nix/store/ms7m1bj4x2rw0hsym8lfa7yssrn3znwh-mutter-50.1/lib/libmutter-18.so.0`.
- Patched GNOME: `/nix/store/fn5k3i2q913r2h5mshxy0hyqjcx5yz4r-gnome-shell-50.1`.
- Tools: `/nix/store/3hvi6da4piy6rv7md7yrag1rlpayqh4x-precision-hdmi-session-test/bin/`.
- Root transient unit: `precision-hdmi-session-test.service`; socket
  `/run/precision-hdmi-session-test/control.sock`; state beside it. This unit
  survives logout, has Restart=no, RuntimeMaxSec=3600, and is not enabled at boot.
- Allowed: fixed dry-activation previews, exactly one candidate `test`, exactly
  one fixed rollback `test`, one GDM restart **after** old GNOME has exited
  normally. Ninety-second logout deadline; no forced logout on timeout, no
  automatic retry. Rollback never kills a replacement desktop.

No new sudoers rule, autologin, linger, sleep change, arbitrary root command,
disk/firmware operation or credential copy is involved. Password goes only into
the local Kitty sudo terminal. The old dead activation socket is removed only
after checking its root-protected directory, exact sole socket, ownership and
connection-refused result. Remaining state is logged to the system journal.

## Continuation

Temporary one-shot autostart:
`/home/lexyo/.config/autostart/precision-hdmi-resume.desktop`.
State/logs:
`/home/lexyo/.local/state/precision-hdmi-session-test-20260912/`.
It acts only when armed, waits for the original GNOME23329 and Codex24815 exact
process identities to disappear, consumes its marker, checks cached login, then
opens Kitty running **this exact conversation**:
`01a09263-e6f0-7983-b528-09146e982e9f`.
It does not create a second simultaneous coordinator or retry indefinitely.
User logs into GNOME normally. Existing Codex authentication passed an actual
transient user-service `codex login status` check; no token contents were read.
The user's existing Codex config is retained (gpt-6-astra).

The default Precision flake output stays unpatched. Explicit candidate build:
`nix build --no-link .#precision-hdmi-session-test`.
The test module prevents activation from stopping/restarting display-manager.
Inspect preview output before activation and verify the old GNOME PID survives.
Then arm the root wait, write the continuation marker, and schedule normal
`gnome-session-quit --logout --no-prompt` with enough delay to flush this transcript.

## First actions after login

1. Read the newest checkpoint, then inspect the root controller `status` and
   `journalctl -u precision-hdmi-session-test`. Confirm the one test actually
   activated and GDM restarted after normal logout.
2. Verify current vs booted closure; inspect the NEW GNOME executable and mapped
   libmutter path (not just package versions). Confirm journal-selected primary
   is Intel00:02.0, both monitors are correct, PaperWM and indicator ACTIVE.
3. Read the guarded display snapshot. Do not count fresh-login dual-display
   success as hot-add/re-add validation. Preserve monitors.xml SHA256
   `66db6c80178131fa3037e1982d2600ccdf0c365810cadbdd467187ba66b0a8b0`.
4. The patch fixes the observed null-monitor path and reloads initial GPU-add
   state. It does NOT remove Xwayland's NVIDIA handles or implement complete KMS
   teardown/re-add. Keep the final zero-owner refusal. Do not start Gaming or
   unbind around GNOME/Xwayland/logind. No forced module removal, second logout
   or reboot is authorized. Meaningful safe live tests can include guarded
   temporary display layout operations only with consistent state and durable
   recovery geometry; abort on any compositor error/crash.
5. Record passed/failed tests precisely and continue safe source work as needed.
   Remove the one-shot autostart and any unused armed marker. Use root controller
   `finish` to relinquish its authority when the attended test is done. The
   transcript/state logs are evidence, not active privileges; preserve them.

## Historical recovery from a text console

The helper has now been finished and removed. Its command below no longer
works; it is retained as a record of the test's recovery arrangement, not an
instruction to re-enable temporary authority. Generation154 remains saved.

If graphical login fails, Ctrl+Alt+F3 and normal login as lexyo. While the helper
is alive, the fixed rollback is available without another password prompt:

```sh
/nix/store/3hvi6da4piy6rv7md7yrag1rlpayqh4x-precision-hdmi-session-test/bin/precision-hdmi-session-control rollback
```

This rolls back configuration, not a running desktop. If GDM then needs a fresh
start, do not loop automatically: use the local console to inspect its journal
and obtain explicit direction for recovery. If the temporary helper has expired,
the same pre-test closure can be activated with normal local sudo. The tested
boot generation154 remains a fallback, but it intentionally isolates NVIDIA and
therefore does not supply Linux HDMI. Do not alter Windows disk, firmware or TPM.

## Current gate

The one activation and one normal logout/login completed. New GNOME77549
actually maps the patched Mutter, Intel is primary, both monitors and saved
geometry are preserved, PaperWM and indicator are ACTIVE. Automatic continuation
worked once. Root helper/runtime/socket and one-shot autostart are removed.

Full HDMI handoff remains incomplete. The fresh session reused the previous
D-Bus owner and serial, exposing an additional cross-login identity gap; that
guard is corrected, built and checked in isolated source, NOT activated. No
GPU unbind, Windows cycle or actual display-layout application was attempted
during post-login validation. All budgets remain consumed; no worker is armed
to continue automatically after this conversation ends.
