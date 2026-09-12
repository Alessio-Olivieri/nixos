# NVIDIA handle-retention investigation — 2026-09-12

**Source/build/isolated-renderer result, NOT a completed HDMI handoff.** No
configuration was activated and no physical display, VM, GPU driver binding,
login session, privilege or startup mechanism was changed in this investigation.

## Newly reproduced cause

The live GNOME77549 has numerous `/dev/nvidia*` and two NVIDIA render-node
descriptors, although its NVIDIA KMS card descriptor has already closed after
the user unplugged HDMI. Xwayland77994 separately retains NVIDIA card0, while
its rendering descriptors are Intel renderD128. Both NVIDIA PCI functions can
be D3cold at the same time. These are real owners, not an erroneous launcher
check. The final zero-owner refusal remains necessary and unchanged.

`probe-egl-release.py` was run in separate processes against the EGL and GBM
libraries actually mapped by GNOME (libglvnd1.7.0, mesa-libgbm26.0.3) and loaded
NVIDIA595.71.05. On NVIDIA renderD129, EGL context creation followed by clearing
the current context, destroying it, terminating EGL, destroying GBM and closing
the caller's descriptor **still left NVIDIA device descriptors open**.
`eglReleaseThread()` released some, but not all. The equivalent Intel renderD128
test released every graphics descriptor. The probe processes then exited.

This independently reproduces the behavior described in the
[NVIDIA EGL resource-leak report](https://forums.developer.nvidia.com/t/resource-leak-after-destroying-egl-context/335957).
It is not evidence that NVIDIA is the desktop's primary renderer.

## Candidate implemented, opt-in only

`mutter-scanout-only.patch` adds the explicit `MUTTER_DEVICE_SCANOUT_ONLY` udev
property. Only the separate test module sets it, matched to NVIDIA's exact PCI
ID_PATH, not the Intel upstream PCI bridge. A debug render-node selector exists
only for isolated tests. The normal Precision output and the previous single
session-test output are unchanged.

For the opted-in device:

- Skip NVIDIA EGL initialization, including the EGLStream fallback.
- Keep KMS/GBM/dumb-buffer support for output scanout.
- Use primary-GPU framebuffer copies, with Mutter's existing CPU fallback;
  do not try secondary GPU rendering or speculative secondary GBM imports.
- Allocate cursor buffers through the dumb-buffer path.
- Exclude the device from DRM lease devices/connectors, so Xwayland is not
  handed its DRM descriptor for an unused leasing capability.
- Preserve the policy when renderer data is recreated after monitor changes.

The intent is to keep Intel rendering Linux's desktop while retaining NVIDIA
HDMI scanout. Physical HDMI performance, colors, cursor and release are NOT
yet verified. This can use a different copy path from the current accelerated
secondary-GPU copy; it must not be advertised as performance-neutral without
an actual display test. Linux applications' EGL/Vulkan/CUDA configuration is
unchanged: no global Mesa-only environment override was installed.

Built Mutter output:
`/nix/store/6vc083kzfc53j5lnay5798kxrg3pl3yn-mutter-50.1`.
The earlier fgniz... build preceded the additional primary-copy/cursor guards;
do not confuse it with the final candidate.

Full offline NixOS test-output build also passed:
`/nix/store/4dmb78ba5n6g8razzv5m2qjpv46dzdkg-nixos-system-precision7560-26.05.20260611.a037402`.
Build command: `nix build --offline --no-link .#precision-scanout-session-candidate`.
It is NOT activated or a saved boot generation. No old activation helper may
be reused for it. The kernel, initrd, module tree and kernel parameters match
the current system. The live system and mapped compositor remain unchanged.

## Real isolated tests

`probe-mutter-scanout.py` runs Mutter headlessly, with a separate D-Bus session,
private temporary config/state/cache/runtime directories and an800x600 virtual
monitor. It never takes DRM master or changes a physical display. A child command
inspects its own test compositor parent's graphics descriptors and reads the
Wayland registry without binding lease globals. The child exits normally and
Mutter then exits normally. The audit has a25s timeout and stops only its own
isolated process group on failure; no retry or host recovery is attempted.

All three formal tests exited0:

| Test | NVIDIA private driver handles | DRM lease globals |
| --- | --- | --- |
| Current ms7m1... Mutter, ordinary behavior, PID114184 | Present | 2 |
| Candidate6vc083..., NVIDIA opted in, PID114279 | Absent | 1 |
| Candidate6vc083..., policy disabled, PID114421 | Present | 2 |

All three selected Intel renderD128 as primary and created the virtual monitor.
The opted-in test still retains **one plain NVIDIA render-node descriptor** in
the headless KMS bookkeeping. This is NOT a zero-owner result, nor a test of
physical KMS release. No real Xwayland process or physical HDMI scanout was
tested inside these headless instances; the measured registry change removes
the source of its lease descriptor, not proof of actual Xwayland release.

Reproduce:

```sh
nix build --offline --no-link .#precision-mutter-scanout-candidate
python3 -B maintenance/probe-mutter-scanout.py \
  --mutter /nix/store/6vc083kzfc53j5lnay5798kxrg3pl3yn-mutter-50.1/bin/mutter \
  --scanout-device /dev/dri/renderD129
```

The render-node mapping is live-machine-specific: resolve PCI ownership again
before rerunning, and never substitute a DRM card node into the EGL probe.
The existing32 controller/display,17 collector,17 maintenance and16 GJS tests
passed again. No new VM/CUDA-recovery/Ollama/USB/game test is claimed this turn.

## Preserved live state and remaining gate

Live current-system remains c4d4khx..., with GNOME77549 still mapping ms7m1...
Mutter. The last snapshot has serial4, bus8540655f57739ed0ebb8e5403124b346,
owner:1.7, primary eDP-1 at0,0; HDMI is physically unplugged. Both NVIDIA PCI
functions are suspended/D3cold with power/control=auto. Root inspect still
reports GNOME and Xwayland. The user-started Windows Light94452/94455 is now
stopped, QEMU exit0; it was not stopped by this investigation. PaperWM and the
GPU indicator remain enabled. Original monitors.xml and all three untracked
/etc/nixos inputs have their previously recorded hashes; main remains unchanged.

**This candidate still lacks complete inactive-GPU removal/re-add.** Mutter's
existing device-removed callback only updates resources, and add refuses a
known path. Simply clearing that duplicate check is unsafe: CRTC/connector,
renderer and cursor lifetimes also need handling. Do not unbind NVIDIA to
"see what happens", even if a later no-EGL session achieves zero descriptors.

A physical validation of this smaller release/scanout change needs a newly
approved session test: these libraries cannot replace those already mapped
into GNOME, and the NVIDIA EGL handles cannot be released through the standard
cleanup API tested above. No logout, reboot, helper, autostart, autologin or
budget reset has been armed. The prior one-session authority is still consumed
and removed. Keep the working saved generation154 and all current owner gates.
