# Approved single GNOME session test — 2026-09-12

Result: the patched compositor starts and the existing Intel-primary,
dual-monitor desktop survives the approved normal logout/login. **Full HDMI
GPU handoff is still incomplete and has not passed.** No GPU transfer or actual
display-layout application was performed during this post-login validation.

## Live evidence

- The single candidate activation completed at13:19:48 CEST, exit0. Normal
  logout ran at13:24:38; the authenticated helper observed the old GNOME exit,
  restarted GDM once, and reported exit0 at13:24:39. Counters: activation1,
  rollback0, GDM restart1. No reboot and no repeated logout.
- New GNOME77549 started13:24:50. Its actual executable is
  `/nix/store/fn5k3i2q913r2h5mshxy0hyqjcx5yz4r-gnome-shell-50.1/bin/.gnome-shell-wrapped`.
  `/proc/77549/maps` contains
  `/nix/store/ms7m1bj4x2rw0hsym8lfa7yssrn3znwh-mutter-50.1/lib/libmutter-18.so.0.0.0`.
  This is actual loaded-library evidence, not just configuration evaluation.
- GNOME journal13:24:51: `GPU /dev/dri/card1 selected primary given udev rule`.
  Sysfs identifies card1/renderD128 as Intel00:02.0/i915, card0/renderD129 as
  NVIDIA01:00.0. NVIDIA drives HDMI; its presence in the owner list does not
  mean it became the primary renderer.
- Read-only guarded snapshot: serial1, shell77549, owner`:1.7`; both monitor
  catalogues are consistent. eDP-1 is primary1920x1080@60.003 at(0,1080);
  HDMI-1 LG FULL HD is1920x1080@74.973 at(0,0), both scale1/rotation0.
- PaperWM50.0.1 and `gpu-indicator@alessio.local` both report ACTIVE.
  The indicator collector remained active across logout. Six passive samples
  over25seconds had fresh status, complete visibility, state`nvidia`, and
  readable names: GNOME Shell, systemd, systemd-logind, Xwayland. No store paths
  or wrapper suffixes appeared. Permanent root inspect independently found
  those four holders. No holder was killed, exempted or unbound.
- Both PCI functions retain power/control=`auto`; NVIDIA remains active while
  driving HDMI and its audio function remained suspended. This cannot prove
  GPU idle suspension with HDMI inactive; no such test is claimed. The
  collector's PrivateDevices sandbox and passive sysfs/proc implementation
  remain in place; no NVML/nvidia-smi/CUDA polling was introduced.
- The installed bridge actually rejected a negative serial and a wrong owner
  before display application. The complete before/after snapshot was equal.
  No fresh hot-add, detach/re-add, VFIO, Windows, CUDA or game test was run.
- Automatic continuation succeeded once: the armed marker became consumed,
  cached login check logged success, Kitty77933 launched Codex78401 at13:24:53,
  and this exact conversation continued. No credential contents were read or
  copied. The original GNOME23329/Codex24815 exited.
- monitors.xml remains SHA256
  `66db6c80178131fa3037e1982d2600ccdf0c365810cadbdd467187ba66b0a8b0`.
  Main `/etc/nixos` and its three original untracked input files are unchanged.
  Windows is stopped and its storage/firmware/TPM were not touched.
- Current-system remains the test closure
  `/nix/store/xl5mdhz28nwnr46ydj85cdyb77d77aqq-nixos-system-precision7560-26.05.20260611.a037402`.
  Booted-system and saved generation154 remain
  `/nix/store/xkga9k4w11g6yzbzp0pgwgsfg7p1c5cw-nixos-system-precision7560-26.05.20260611.a037402`.

## Additional safety finding and source-only correction

The old and new display services both reported owner`:1.7` and serial1, while
the GNOME PID changed23329→77549. A bus unique name alone is therefore not a
cross-login identity. New pure regressions reproduced the old guard accepting
a replacement bus with reused name/serial; these failures used injected
callbacks, not actual display mutations.

The isolated source now carries the bus instance ID and shell PID through
snapshot, configuration, apply and restore, rejecting missing or changed
identity. Bus instance identity comes from the documented
[D-Bus GetId method](https://dbus.freedesktop.org/doc/dbus-specification.html#bus-messages-get-id),
not the machine ID. Sixteen GJS guard,32 Python controller/display,17 indicator
and10 helper-budget tests pass. The offline package build passed:
`/nix/store/zv48vpilxycq8hg6s7q2i44l4igrjgv5-precision-windows-1.0`.
Its display tool is `/nix/store/vkkwv2rwxrf3sxhnnrmjgvzz8h0i8zjf-precision-host-display/bin/precision-host-display`.
That tool read the actual new bus ID8540655f57739ed0ebb8e5403124b346 and
shell77549; wrong-bus, old-shell and legacy-snapshot requests were all refused
without applying a display configuration. The complete snapshot remained
unchanged. **This additional correction is not activated**: the
single activation allowance was consumed. Do not use old snapshots or start
Gaming in the current host-HDMI session.

## Warnings and limits

No new compositor core dump or NVIDIA Xid appeared in the inspected post-login
journal through13:29. Startup warnings from HeadsetControl, blur-my-shell,
PaperWM's read-only metadata and AppIndicator's missing gjs also occurred in
the previous GNOME23329 session. PaperWM and the supplied GPU indicator are
ACTIVE; unrelated desktop settings were preserved rather than repaired here.
At13:28:29 libinput logged discarded touchpad jumps and rate-limited the warning;
this is recorded separately, not counted as a GNOME crash or repaired here.

The13:21 device timeout is the existing `/mnt/shared` nofail NTFS entry for
UUID13C004C07DA7D213 in unchanged main configuration.nix. That device is absent
and the mount inactive. It was not mounted, repaired or removed.

Full GPU lifecycle teardown/re-add, Xwayland's retained NVIDIA handle, Gaming
internal/external selection and HDMI-mode repeated VM/CUDA cycles remain
unresolved. A successful fresh login does not reproduce the original hot-add
failure path or establish seamless handoff. Keep the zero-owner gate intact.

## Additional safe live gate after the session test

At13:50 CEST, with a durable snapshot saved, the corrected guarded bridge
temporarily disabled only HDMI-1. The operation succeeded without a compositor
crash: the current logical state became the Intel eDP-1 alone, while the
Mutter serial, D-Bus owner, bus ID, shell PID and monitor catalogue stayed
consistent. After four passive seconds, NVIDIA runtime status was suspended,
but the root owner scan still reported GNOME Shell77549 and Xwayland77994.
Therefore `precision-windows-gpu prepare` correctly must refuse; no VFIO
unbind or VM start was attempted. The original HDMI layout was restored with
the guarded bridge and read back unchanged. This is useful evidence, not a
successful handoff cycle.

The source collector was corrected after this observation: it now scans
procfs handles even while NVIDIA is runtime-suspended (procfs only, no GPU
query), keeps the visible state `intel`, and lists any holders with a detail
that they still hold device handles. The old early return would have hidden
GNOME/Xwayland in this exact safety-critical state. The corresponding17
indicator tests pass; the running installed collector is unchanged until a
future normal declarative switch.

## Withdrawn launcher draft (historical, not installed)

The draft described below was withdrawn in the subsequent activation review.
The Zenity row/return columns were wrong; DisplaySwitch was launched by the
guest agent outside the interactive console and did not identify or verify
the physical HDMI target. Its blocking retry loop also delayed the controller's
viewer-close handling. Passing these mocked tests and building the package
did not validate the feature. Do not deploy dazcsnh... or907y5... .

The isolated source now offers a guarded destination chooser for **Windows —
Gaming**. `--display internal` keeps the Looking Glass presentation on the
Intel-driven laptop panel; `--display external` requests Windows
`DisplaySwitch /external` after the guest agent is ready so the passed-through
NVIDIA HDMI output can be used. The chooser is read-only before handoff and
fails closed on an ambiguous monitor topology. Controller tests cover both
destinations and cancellation; all 35 controller tests, 17 indicator tests and
11 maintenance tests pass. Offline package builds produced
`dazcsnhkb10cp8lqn7n708wkvw4v56d8-precision-windows-1.0` and
`1hmg5nf2sh3ad157mswsvrlsz824jh6p-precision-gpu-indicator-0.1.0`.

These changes are not activated in the current session. A real external-mode
guest boot, physical HDMI output, CUDA recovery cycle, and seamless Mutter
GPU release remain unvalidated because the live zero-owner check correctly
finds GNOME Shell/Xwayland handles after HDMI detach.

## Cleanup

Live results were recorded before relinquishing the helper. At13:30:20 the
fixed `finish` command succeeded, counters1/0/1, phasefinished. The journal
records successful deactivation. Verified afterward:

- Helper unit LoadState=not-found, ActiveState=inactive, MainPID=0; rootPID75606
  gone. New runtime directory/socket and the old stale activation directory
  are both absent. No reactivation, re-arm or rollback was attempted.
- The exact `~/.config/autostart/precision-hdmi-resume.desktop` was deleted.
  No armed marker or logout timer remains. Consumed marker, resume.log and this
  report are retained as evidence; the source still allows reconstructing the
  one-shot launcher, but no autostart is installed.
- The ordinary user application scope created by that successful autostart
  still contains the currently running Kitty/Codex conversation. It has no root
  authority, restart policy or future login trigger. Do not kill the user's
  working terminal as cleanup; the scope ends when its applications exit.
- `sudo -n true` was refused with `a password is required`; sudo listing has
  only the existing permanent GPU inspect/prepare/release NOPASSWD commands.
  No temporary sudoers rule was installed or retained.
- GDM custom.conf remains empty/no autologin; linger=no. No maintenance sleep
  inhibitor appears; ordinary GNOME/NetworkManager/UPower inhibitors remain.
  This test never changed login, sleep, disk encryption or firmware settings.
- GNOME77549, mapped patched library, current test closure, booted/saved154 and
  original monitors.xml hash remained unchanged after cleanup. No test/build
  process remains pending. Source is isolated, uncommitted and unmerged;
  `git diff --check` passed.
