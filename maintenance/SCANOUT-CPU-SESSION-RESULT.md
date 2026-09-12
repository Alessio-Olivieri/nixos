# CPU-copy physical display test — passed checks, handoff incomplete, 2026-09-12

## Later user Gaming test FAILED — 16:13:24 CEST

The user's16:12 Gaming launch released Linux HDMI, transferred NVIDIA to VFIO
and displayed Windows internally. QEMU later exited0, but reloading NVIDIA caused
GNOME189534 to SIGSEGV in meta_crtc_kms_assign_extra -> g_set_error -> strlen.
The CUDA recovery test passed afterward; the original GNOME session was gone.
The new session192901 still maps CPU-only3aqm Mutter. Therefore the display-only
passes below must not be interpreted as a safe full GPU handoff.

At16:45:19 a component-only safety update installed a fail-closed Gaming gate in
both controller and privileged helper without replacing GNOME/GDM. A lifecycle
repair candidate is being tested separately and is not live. See FINAL-REPORT.md
and the latest checkpoint for the current, incomplete repair status.

## Actual activation and login

Fixed candidate vzw5risximxbvjwr73s3drxvarf4wlf2 activated once at15:59:21
CEST, exit0. Both forward and rollback previews passed. Saved/booted generation
154 xkga9k4w11g6yzbzp0pgwgsfg7p1c5cw unchanged. NVIDIA595.71.05 remains loaded.
Original GNOME147739 exited after one normal logout at16:01:00. Root helper
187648 observed the exit without restarting GDM; counters1 activation/0 rollback/
0 restart, phase awaiting-login-no-gdm-restart. GDM77028 has been running since
13:24:38. One-shot logout service/timer are now absent. No auto-login or startup
service was installed for this test. Temporary root helper was finished and
removed at16:07:20 after recording the display test; rollback was not used.

New GNOME189534 started16:01:11 and actually maps
`/nix/store/3aqmvipyf4b9357yg55p48m4whhfdhk8-mutter-50.1/lib/libmutter-18.so.0.0.0`.
Executable belongs to8cgs3ki2f0k1rjwmg2aaxpmv9m9alj6z-gnome-shell-50.1.
Journal selects Intelcard1 primary and logs CPU copy for NVIDIAcard0, scanout
only/no EGL or leases. No coredump entries since this login were found.

## Internal-only native checks passed

- Fresh snapshot: bus5631df8f370d43bce7e294bad4f6b0f3, owner:1.7,
  shell189534, serial1. eDP-1 1920x1080@60.003, scale1, origin0,0, primary.
  HDMI disconnected. Never reuse snapshots from earlier logins.
- PaperWM and GPU indicator are ACTIVE. Live accessibility tree shows Intel
  and NVIDIA suspended. Root owner inspection is complete and has zero owners.
- NVIDIA and audio both D3cold, power/control=auto. No power policy changes.
- Windows remains stopped. monitors.xml SHA256 remains
  66db6c80178131fa3037e1982d2600ccdf0c365810cadbdd467187ba66b0a8b0.
- Real host CUDA probe191103 ran a32-thread kernel, verified tid+42 for all32
  values, and exited0. During its15-second context hold, root inspection and
  collector identified exactly Python191103. Live indicator showed NVIDIA · 1
  and awake. This is host CUDA, NOT return-from-VFIO validation.

Startup journal also contains extension warnings (PaperWM declarative metadata
not writable, HeadsetControl rejection, appindicator missing gjs), plus pixman
invalid-rectangle and actor-parent assertions at16:01:13. These are recorded,
not silently counted as a warning-free session. No new Intel execbuf ENOMEM,
GPU-copy abort, or coredump was observed in the inspected interval. Desktop
configuration was not changed to suppress these messages.

## Physical HDMI and temporary disable/restore passed

User confirmed "external appears" after plug at16:03:35. Same GNOME189534
remained alive; only CPU-copy renderer recreation logged. Serial2 shows eDP
1920x1080@60.003 at0,1080 primary and LG HDMI1920x1080@74.973 at0,0, both scale1.
Fresh full recovery snapshot is cpu-hdmi-original-20260912-1604.json, bound to
this exact session/bus/monitor catalogue. NVIDIA is D0 with GNOME189534,
systemd1 and logind1690 KMS owners; Xwayland is not an NVIDIA owner.

One temporary external-display disable completed16:04:53 with changed=true,
keeping eDP active at0,0. Independent20-second user restore timer was installed
BEFORE disabling. At16:05:04, complete root inspection found zero NVIDIA owners;
both functions reached D3cold/auto despite HDMI remaining physically connected.
The live panel showed Intel and runtime-suspended. No new compositor log entries
appeared during disable. This establishes owner release without killing anyone.

The restore timer ran16:05:14 and completed16:05:15 with restored=true,
changed=true. Same GNOME189534; original logical geometry compared EXACTLY equal,
including eDP primary at0,1080 and HDMI at0,0, modes/scales/rotation preserved.
Only normal CPU-copy renderer creation logged. monitors.xml hash unchanged.
No persistent layout writes, GPU detach or compositor restart occurred.

A second real CUDA probe191405 completed a32-value kernel test and exited0 with
BOTH Linux screens active. Its Python owner coexisted with normal HDMI KMS owners
GNOME/systemd/logind. PaperWM and indicator remained ACTIVE after restoration.
No kernel NVIDIA/i915/DRM/Xid/Oops/error matches were found since16:01:00, and
no recurring Intel execbuf ENOMEM or coredump appeared in the inspected interval.

The user confirmed initial physical pixels, but restored-display usability and
cursor/window-motion performance have not yet been confirmed or benchmarked.
These are display and host-CUDA tests, NOT a VFIO removal/re-add or Windows cycle.
Full KMS-device lifecycle remains unimplemented/unvalidated: do not invoke Gaming
under this candidate merely because the disabled-monitor owner scan reaches zero.
The current launcher's owner gate alone does NOT certify that lifecycle.

## Cleanup VERIFIED at16:07:20

Helper finish returned phasefinished, counters1 activation/0 rollback/0 restart.
Unit is not-found/inactive/PID0; its runtime directory and socket are absent.
Both logout and display-restore timers/services are absent. No one-shot autostart
remains. The durable record
`/var/lib/precision-scanout-cpu-session-test-20260912/state.json` retains finished
state; all earlier consumed records remain untouched. Never recreate the helper
or reset counters. Its fixed recovery command is no longer available.

Linger=no, ordinary sudo -n true refuses without authentication, no automatic
or timed login in active GDM configuration, and no maintenance sleep inhibitor.
Existing permanent scoped GPU-helper rules remain; no new general privilege was
installed. Windows stopped; both Linux screens left configured and active.
Current remains the tested CPU candidate; saved/booted generation154 unchanged.
Neither normal reboot nor a repeat logout was performed or authorized.
