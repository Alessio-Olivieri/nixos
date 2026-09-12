# Scanout-only physical session test: FAILED — 2026-09-12

The candidate is **not safe for HDMI**. Fresh internal-only login and zero
NVIDIA owners did not establish working scanout or handoff.

## Actual sequence

- Candidate4dmb78... activated once15:15:32; saved/booted generation154 unchanged.
- Identity-bound normal logout request ran15:18:31. The root helper declined
  its GDM restart15:18:33 (`replacement-session-present-no-restart`). GDM77028
  stayed running. The helper's substring process-name match can mistake a
  GNOME Shell companion for a replacement compositor; no restart is claimed.
- New user GNOME144348 started15:18:43, executable fppf05..., actually mapped
  Mutter6vc083.... Journal confirmed card0 scanout-only/no EGL/leases and Intel
  card1 primary. PaperWM and indicator ACTIVE. eDP1920x1080@60 primary, HDMI
  initially unplugged. Root inspect found zero NVIDIA owners; collector agreed.
- A real CUDA probe145912 printed a32-value verified kernel pass while running
  its20-second hold. Its normal completion was not observed across the crash;
  this is NOT a completed CUDA recovery/lifecycle test.
- HDMI was connected at approximately15:20:59. New renderer creation was
  followed15:21:01 by `intel: the execbuf ioctl keeps returning ENOMEM`.
  GNOME144348 aborted15:21:16 with SIGABRT. The retained coredump's main-thread
  trace goes through Mesa iris `_iris_batch_flush.cold`, EGL swap and Mutter's
  `meta_onscreen_native_swap_buffers_with_damage`.
- GDM greeter compositors146230 and146729 also aborted at15:21:35 and15:21:54.
  These were GDM's own recovery attempts, not repeated helper logout/restart
  commands. The user reports black screens/text console while connected and
  recovery to login after unplugging HDMI.
- User GNOME147739 started15:22:05. At15:23 actual host checks confirmed it is
  alive, eDP only, zero NVIDIA holders and both functions suspended/D3cold/auto.
  Windows remained stopped. No VFIO preparation or GPU detach occurred.
- The approved fixed rollback completed exit0 after the failure. Current system
  is c4d4khx..., saved/booted154 still xkga9k4.... Root counters1 activation,
  1 rollback,0 GDM restarts. No second logout or reboot was requested.

## Recovery limits

Configuration rollback does not replace a library mapped into a running
process: GNOME147739 still uses the failed scanout candidate until a future
normal login. Keep HDMI unplugged for this session. No further session restart
is authorized by the consumed test. The preserved baseline takes effect on
the next normal login; saved generation154 remains the boot fallback.

## Evidence and next source investigation

Read system journal for boot ec89b2a7-35c8-44cc-8ee9-0ccb1419e153, GNOME PID144348
and `COREDUMP_PID=144348`. The systemd coredump remains under
`/var/lib/systemd/coredump/`; no raw process memory or credentials were copied
into the repository. No kernel Xid/Oops was observed in the narrow failure
interval examined. This does not identify an out-of-system-memory condition:
the specific failure was Intel execbuf submission during the cross-GPU copy.

The source already exposes `copy_mode_primary_force_cpu`, but this candidate
selected PRIMARY without setting it. PRIMARY first attempts a GPU blit into
the secondary buffer; errors may surface asynchronously at EGL swap rather
than trigger its synchronous CPU fallback. This is a source-supported suspect,
not yet a verified fix. Investigate and build in isolation; do not re-run the
physical HDMI experiment or unbind the GPU on this grant.

Primary references: Mutter50.1 documents that PRIMARY tries GPU blitting before
CPU readback in its [multi-GPU documentation](https://github.com/GNOME/mutter/blob/50.1/doc/multi-gpu.md).
[NVIDIA issue1037](https://github.com/NVIDIA/open-gpu-kernel-modules/issues/1037)
reports the same Intel error after successful import of a NVIDIA-allocated
buffer. That report uses a different driver version/allocation path, so it
supports the mechanism hypothesis rather than proving this exact root cause.

The separate build-only CPU follow-up is `mutter-scanout-cpu-copy.patch` and
flake output `precision-mutter-scanout-cpu-candidate`. It sets the existing
`copy_mode_primary_force_cpu` only for opted-in scanout-only devices, skipping
the GPU-blit attempt. Original failed candidate/patch remain reproducible.
Neither the current desktop nor normal host output has this new change.

## Cleanup

Cleanup VERIFIED15:27:16: helper `finish` returned counters1/1/0; transient unit
not-found/inactive/PID0, runtime directory and socket absent, logout timer absent.
PaperWM and indicator ACTIVE; root inspect zero owners. monitors.xml SHA still
66db6c80178131fa3037e1982d2600ccdf0c365810cadbdd467187ba66b0a8b0. Linger=no,
no automatic/timed login in active GDM config. Preserve the exclusive consumed record
`/var/lib/precision-scanout-session-test-20260912`. No Codex autostart or temporary
auto-login was installed for this test; manual continuation was the user's choice.
