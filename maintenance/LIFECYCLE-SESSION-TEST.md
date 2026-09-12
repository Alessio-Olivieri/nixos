# Newly approved lifecycle GNOME test — 2026-09-12

User explicitly approved the proposed new session and said they are ready.
They will log out MANUALLY after activation is verified; do not schedule an
automatic logout too. No reboot, forced logout or repeated failed logout.
This is a new grant, not a reset of previous consumed test records.

## Fixed scope and recovery

- Candidate: /nix/store/bd7sxq4vbbya1bhy9q1jlzprfk0qq78v-nixos-system-precision7560-26.05.20260611.a037402
- Baseline: /nix/store/xh1bs21slny2252ijyjj55w5m3di6rsc-nixos-system-precision7560-26.05.20260611.a037402
- Saved/booted/default154: xkga9k4w11g6yzbzp0pgwgsfg7p1c5cw unchanged.
- Required new Mutter: /nix/store/w1krysf0wmi8mlm26cs0i5146hw9f6nm-mutter-50.1/lib/libmutter-18.so.0.0.0
- Required GNOME package: rw8wqhrvfqzm4146q8r9b85v9r35q2hp.
- Original GNOME192901/start1824213, bootec89b2a7-35c8-44cc-8ee9-0ccb1419e153.
- Root helper unit: precision-lifecycle-session-test.service, max1hour, Restart=no.
- Durable root record: /var/lib/precision-lifecycle-session-test-20260912.
- Runtime: /run/precision-lifecycle-session-test.
- Tools: /nix/store/5gw436sjvkjzyywhl0l7k62mc8shiw45-precision-lifecycle-session-test/bin/.

The helper allows one fixed test activation, one fixed rollback and90-second
observation of normal logout. It never restarts GDM or reboots. No GPU unbind or
VM-start authority is added. Gaming remains gated in the candidate. Both forward
and rollback previews must pass; saved kernel/boot profile must stay unchanged.
No password storage, sudoers addition, auto-login or sleep-setting change.

If login is black, unplug HDMI, use internal display or Ctrl+Alt+F3 and normal
login. While the helper is alive, fixed recovery needs no additional sudo:

```sh
/nix/store/5gw436sjvkjzyywhl0l7k62mc8shiw45-precision-lifecycle-session-test/bin/precision-lifecycle-session-control status
/nix/store/5gw436sjvkjzyywhl0l7k62mc8shiw45-precision-lifecycle-session-test/bin/precision-lifecycle-session-control rollback
```

Rollback does not kill/restart a desktop. Do not retry a failed logout or recreate
an expired helper. Saved154 remains the previous boot fallback without Linux HDMI.

## Continuation and post-login validation

The one-shot /home/lexyo/.config/autostart/precision-lifecycle-resume.desktop
uses state /home/lexyo/.local/state/precision-lifecycle-session-test-20260912.
It refuses a duplicate while original GNOME192901 or agent193945/start1825062
still lives, then consumes its marker and opens the exact conversation
01a09263-e6f0-7983-b528-09146e982e9f. Installed Codex resume syntax and authentication
were checked; a transient user-service login-status check passed. No token copied.
This mechanism follows the exact-session resume documented at
https://learn.chatgpt.com/docs/developer-commands?surface=cli .

1. Inspect helper status/current closure before any action; never activate twice.
2. Check actual NEW executable and mapped Mutter w1k..., Intel00:02.0 primary in
   journal, eDP+HDMI both active, PaperWM/indicator ACTIVE. The old GNOME mapping
   does not change merely because activation succeeded.
3. Preserve monitors.xml hash66db6c80178131fa3037e1982d2600ccdf0c365810cadbdd467187ba66b0a8b0.
   Previous display snapshots are stale across this logout. Read a fresh one.
4. Ask for actual visible pixels if needed. Fresh-login topology is NOT a full
   NVIDIA/VFIO return test. No owner bypass or ungated Gaming start. Safe initial
   checks include passive owner/power data and a real CUDA probe.
5. Record actual result, then finish helper and remove the exact one-shot
   autostart/unused armed marker. Preserve consumed evidence. Verify no transient
   authority or logout timer remains. Do not leave the helper running indefinitely.

## Pre-session results

Lifecycle candidate passed three real VKMS remove/return cycles, including queued
remove/add while only the disposable guest compositor was paused after zero
owners. Same GNOME and both displays returned; Nix check9p6y4... exit0. CPU-only
baseline failed its first return. This is regression evidence, not laptop proof.
Normal repository output now exactly reproduces current guarded baseline xh1bs.
Two actual Windows Light viewer-close shutdowns passed17:42:55 and17:44:39 with
QEMUexit0. Real host CUDA passed with Light running. Ollama qwen3:0.6b generated
OK with CUDA8.6/A4000,29/29layers offloaded and100%GPU; live indicator showed
readable Ollama321720. Ollama restored to its prior inactive state before logout.
