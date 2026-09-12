# Newly approved CPU-copy physical session test — 2026-09-12

COMPLETED: physical HDMI and temporary owner-release/restore checks passed;
full GPU handoff remains incomplete. Read SCANOUT-CPU-SESSION-RESULT.md.
Temporary authority/timers were removed16:07:20, counters1/0/0 retained.
The recovery commands below are HISTORICAL and no longer available. Never
recreate this consumed helper or repeat its activation/logout.

The user answered YES to one ADDITIONAL controlled logout/login of the changed
CPU-copy candidate, without reboot. This is a fresh grant, not reuse/reset of
the consumed first scanout test. Manual login and manual conversation resume;
no Codex startup service/autostart or automatic graphical login is installed.

## Fixed scope

- Candidate: `/nix/store/vzw5risximxbvjwr73s3drxvarf4wlf2-nixos-system-precision7560-26.05.20260611.a037402`.
- Baseline/rollback: `/nix/store/c4d4khxkv2bj5m1k6gvh3v5576hmcpw0-nixos-system-precision7560-26.05.20260611.a037402`.
- Saved/booted generation154: xkga9k4w11g6yzbzp0pgwgsfg7p1c5cw, UNCHANGED.
- New mapped Mutter must be3aqmvipyf4b9357yg55p48m4whhfdhk8; new GNOME8cgs3ki2f0k1rjwmg2aaxpmv9m9alj6z.
- Original GNOME147739, start1515021, bootec89b2a7-35c8-44cc-8ee9-0ccb1419e153.
- Immutable tools: `/nix/store/f70wi9abzf2q4j8z8v6qjkf6rx14gynk-precision-scanout-cpu-session-test/bin/`.
- Transient root unit `precision-scanout-cpu-session-test.service`, one-hour
  maximum, Restart=no, socket `/run/precision-scanout-cpu-session-test/control.sock`.
- Exclusive persistent root record:
  `/var/lib/precision-scanout-cpu-session-test-20260912`. Never reset/delete it.

Only fixed previews, ONE candidate `test`, ONE rollback `test`, exact NVIDIA
card0 udev refresh/identity check after activation, and observation of the old
normal logout. **No GDM restart capability is used by this configuration.**
The helper waits90seconds after arming; timeout never forces or repeats logout.
No GPU detach, VM start, process killing, reboot, encryption, firmware or TPM
operation is authorized by this test. Only UID1001 can request fixed actions.

Keep HDMI unplugged through activation and login. The original running session
still maps the failed GPU-copy candidate6vc083... until normal logout.

## Recovery from text console

If login fails, unplug HDMI, Ctrl+Alt+F3, log in normally, inspect helper status.
While the one-hour helper is alive, fixed rollback needs no new sudo prompt:

```sh
/nix/store/f70wi9abzf2q4j8z8v6qjkf6rx14gynk-precision-scanout-cpu-session-test/bin/precision-scanout-cpu-session-control status
/nix/store/f70wi9abzf2q4j8z8v6qjkf6rx14gynk-precision-scanout-cpu-session-test/bin/precision-scanout-cpu-session-control rollback
```

Rollback restores configuration without killing/restarting any desktop. If
expired, local sudo can activate the fixed baseline. No automatic recovery
restart, second logout or reboot: inspect and obtain fresh direction instead.

## After manual login/resume

1. Read newest checkpoint and this file; inspect actual unit/state/journal.
   Never call activate again if its counter is1. No old helper may be revived.
2. Verify actual GNOME executable and mapped Mutter3aqm..., Intel primary,
   PaperWM/indicator ACTIVE, eDP state, NVIDIA owners and power. Check journal
   for `Using CPU copy for scanout-only device`; this is selection, not scanout.
3. Only then begin a physical HDMI test. Preserve a fresh guarded snapshot and
   original monitors.xml hash66db6c80178131fa3037e1982d2600ccdf0c365810cadbdd467187ba66b0a8b0.
   Never apply a previous session's saved display state. Initially only eDP
   was active and Windows stopped. The user needs to confirm physical pixels;
   do not count D-Bus topology or fresh login alone as HDMI success.
4. Abort further display changes on any compositor warning/error consistent
   with the prior failure, lost responsiveness or crash. Preserve logs; use
   the one rollback if needed. No repeated failed logout or plugin loop.
5. Full KMS-device teardown/re-add is STILL absent. Even if HDMI CPU copy and
   zero-owner idle both work, do NOT unbind NVIDIA or run Gaming. No GPU owner
   bypass. Test only safe monitor disable/restore if session remains healthy.
6. Record result accurately and `finish` root helper, verify unit/runtime/socket
   and one-shot logout timer gone. Keep consumed record. No autostart to remove.

## Current stage

UPDATE16:02: normal logout completed ONCE16:01:00. New GNOME189534 maps correct
Mutter3aqm..., Intel primary, CPU copy selected. PaperWM/indicator ACTIVE;
internal-only D3cold/zero owners verified; real host CUDA probe passed/exit0.
See SCANOUT-CPU-SESSION-RESULT.md. Physical HDMI plug requested; not yet tested.
Helper counters1/0/0, awaiting-login-no-gdm-restart, live for fixed recovery.
Logout timer/service gone. Do not reactivate, arm or repeat logout.

Logout observation ARMED and one-shot precision-scanout-cpu-logout.timer ACTIVE,
scheduled25seconds after arming. On resume inspect its actual journal/result,
do not repeat logout if failed or inhibited. Root helper never restarts GDM.

ACTIVATED ONCE at15:59:21 CEST, exit0. Local authentication succeeded after the
expired initial prompt was reissued on request; root helper187648. Counters1/0/0,
currentvzw5..., saved/booted154 unchanged. Forward and baseline dry previews
passed, including baseline preview from active candidate. NVIDIA udev flag1
verified. Original GNOME147739 still maps old6vc..., Intelcard1 primary. No GDM
restart. eDP only/HDMI unplugged, PaperWM and indicator ACTIVE, zero GPU owners,
collector shows both functions suspended. Windows stopped; monitors.xml unchanged.
The unarmed logout script refused without logging out, as intended. Preparing
one25-second delayed, identity-guarded normal logout; inspect status and timer
before taking any action on resume. NEVER repeat activation. No physical HDMI
test yet.30 maintenance checks passed earlier, including no GDM restart after
original-session exit or timeout. No autostart/automatic login was installed.

Previously, after three goal turns with authentication still pending, automatic goal work
was marked blocked. Last observed sudo186994 remained live, elapsed4m45s;
new root unit/socket/record were absent. This is NOT a failed activation or
logout attempt. Authenticate locally and resume; inspect the existing process
and helper before taking any action. Do not open a duplicate while it is live.
