# Newly approved scanout-only GNOME session test — 2026-09-12

**CONSUMED and FAILED on physical HDMI.** See SCANOUT-SESSION-RESULT.md.
One activation and one rollback completed; no helper GDM restart occurred.
Do not arm another logout, repeat activation or reset the durable counters.
Keep HDMI unplugged while the failed library remains mapped in this session.

The user approved ONE new controlled logout/login, then explicitly chose to
resume the conversation manually. No automatic Codex continuation/autostart,
auto-login, reboot or old-budget reset is authorized or installed for this test.

## Fixed scope and recovery

- Candidate: `/nix/store/4dmb78ba5n6g8razzv5m2qjpv46dzdkg-nixos-system-precision7560-26.05.20260611.a037402`.
- Rollback: `/nix/store/c4d4khxkv2bj5m1k6gvh3v5576hmcpw0-nixos-system-precision7560-26.05.20260611.a037402`.
- Saved/booted generation154 remains xkga9k4w11g6yzbzp0pgwgsfg7p1c5cw.
- Original GNOME77549, start811511, boot ec89b2a7-35c8-44cc-8ee9-0ccb1419e153.
- New Mutter must actually map6vc083kzfc53j5lnay5798kxrg3pl3yn, new GNOME fppf05j842k5ag62hvh7xddgsw9q5f66.
- New tool package: `/nix/store/vd22jn7vwc1ha92msyh4h3d8fj7328j0-precision-scanout-session-test/bin/`.
- Transient root unit `precision-scanout-session-test.service`, runtime socket
  `/run/precision-scanout-session-test/control.sock`, one-hour expiry, Restart=no.
- Exclusive root record `/var/lib/precision-scanout-session-test-20260912`
  survives service exit and prevents replay. Never delete or reset it.

Only fixed previews, one `test` activation, one fixed rollback, one GDM restart
AFTER the original normal logout. Ninety-second logout deadline; no forced
logout/restart on timeout or if a replacement user GNOME already exists. No
GPU/VM operations. Service/socket authenticate UID1001. No general sudo grant.
Both activation previews reject unapproved service operations. Kernel, initrd,
modules, params and saved boot profile are protected.22 controller/guard tests
passed before local authentication. They are not a physical display test.

If graphical login fails: Ctrl+Alt+F3, log in normally, then while helper lives:

```sh
/nix/store/vd22jn7vwc1ha92msyh4h3d8fj7328j0-precision-scanout-session-test/bin/precision-scanout-session-control status
/nix/store/vd22jn7vwc1ha92msyh4h3d8fj7328j0-precision-scanout-session-test/bin/precision-scanout-session-control rollback
```

Rollback changes configuration only, does not kill any desktop or retry GDM.
If expired, the pinned rollback closure can be activated with normal local sudo.
Inspect evidence and obtain direction for any further session restart; no loop.

## First actions on manual resume

1. Read newest checkpoint, this file and SCANOUT-CANDIDATE-RESULT.md. Inspect
   helper `status`, durable state and journal. Do not run `activate` again.
2. Verify actual mapped Mutter/executable, Intel selected primary renderer,
   eDP and physical HDMI states, PaperWM and indicator, passive GPU owners and
   runtime suspend. A fresh login is NOT full hot handoff validation.
3. Use a fresh guarded monitor snapshot. Previous session serial4/owner:1.7
   cannot be reused. Original monitors.xml SHA256:
   `66db6c80178131fa3037e1982d2600ccdf0c365810cadbdd467187ba66b0a8b0`.
   Before test only eDP was active and HDMI physically unplugged; Windows stopped.
4. Candidate eliminates secondary NVIDIA EGL and lease globals; it still lacks
   full KMS removal/re-add. Do not start Gaming, unbind or bypass ANY GPU owner.
   Safe physical monitor tests only; stop on compositor errors. No second logout
   or reboot. Preserve power/control=auto and finegrained power management.
5. Record actual passed/failed results. Call helper `finish` and verify unit,
   socket and runtime are gone. Keep durable consumed state/journal. No one-shot
   autostart was installed because the user explicitly chose manual continuation.

## Current stage

Local authentication succeeded. Candidate and baseline dry-activation passed;
exactly one candidate `test` activation exit0 at15:15:32 CEST. Original GNOME77549
and GDM77028 survived; mapped Mutter remains ms7m1 until login. Saved154 unchanged.
Rollback dry-activation FROM the now-active candidate also passed. No rollback
was performed. Root helper142252 holds counters1/0/0. No logout yet.

The installed udev rule exists but device database did not get its new property
automatically. A separate local Kitty fixed sudo command refreshes ONLY card0:
`udevadm trigger --action=change --settle /sys/class/drm/card0`.
Refresh completed locally; device database now confirms
`MUTTER_DEVICE_SCANOUT_ONLY=1`, NVIDIA has no current preferred-primary tag,
Intel card1 retains it. GNOME77549 stayed alive; indicator still shows Intel,
runtime-suspended with holders. No driver detach or VM operation occurred.

The identity-guarded `maintenance/scanout-logout-once.py` was live-tested before
arming and correctly refused an unarmed logout. It is scheduled once through
`precision-scanout-logout.timer`, with a25-second delay for transcript flush.
The helper is armed for90s. Inspect actual state and journal after login rather
than assuming the scheduled request succeeded. No retry on failure. User will
resume manually; wait for the GDM restart/login screen to settle before login.
