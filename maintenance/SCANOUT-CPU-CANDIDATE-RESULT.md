# CPU-copy follow-up: built, isolated checks passed, NOT activated

2026-09-12, after the failed physical test documented in
[SCANOUT-SESSION-RESULT.md](SCANOUT-SESSION-RESULT.md).

## Scope

The original scanout-only patch correctly removed the compositor's private
NVIDIA EGL handles and Xwayland's NVIDIA lease in an internal-only native
session. It nevertheless crashed on HDMI: PRIMARY copy mode still submitted an
Intel GPU blit into a NVIDIA buffer. The crash was in Mesa iris batch submission,
not the earlier null-monitor dereference. Neither issue constitutes working
GPU removal/re-add.

The new separate `mutter-scanout-cpu-copy.patch` sets the existing
`copy_mode_primary_force_cpu` on the opted-in secondary device only. This
bypasses cross-GPU import/blit in `update_secondary_gpu_state_pre_swap_buffers`
and uses Mutter's existing CPU read-pixels/dumb-buffer path. Intel remains the
desktop renderer. No global application EGL/Vulkan/CUDA settings are changed.
This may affect Linux HDMI performance; frame rate, cursor, physical pixels
and full handoff remain **UNVALIDATED**. It must not be promoted as production.

Mutter's [50.1 multi-GPU documentation](https://github.com/GNOME/mutter/blob/50.1/doc/multi-gpu.md)
explains that PRIMARY includes both GPU and CPU implementations.
[NVIDIA issue1037](https://github.com/NVIDIA/open-gpu-kernel-modules/issues/1037)
reports the same Intel submission error after importing NVIDIA allocations on
a different driver version. This corroborates a mechanism, not exact root-cause
proof for this machine's dumb-buffer path.

## Built outputs

```sh
nix build --offline --no-link .#precision-mutter-scanout-cpu-candidate
nix build --offline --no-link .#precision-scanout-cpu-session-candidate
```

Both completed successfully. Mutter:
`/nix/store/3aqmvipyf4b9357yg55p48m4whhfdhk8-mutter-50.1`.
Full system:
`/nix/store/vzw5risximxbvjwr73s3drxvarf4wlf2-nixos-system-precision7560-26.05.20260611.a037402`.
The full candidate's kernel, initrd, modules and kernel parameters match the
current baseline. No activation or root test authority was created for it.
The original failed candidate4dmb78... remains reproducible separately.

## Actual isolated checks

The existing bounded headless probe ran the new Mutter159635 at15:31:34, using
render nodes, a private session bus/runtime/settings and800x600 virtual display.
It logged the CPU-copy policy, Intel primary, no NVIDIA private context handles
and one lease global (Intel). It retained one plain NVIDIA render-node FD as
expected in the isolated KMS bookkeeping, then exited normally, overall exit0.
There was no physical KMS output, secondary framebuffer readback, Xwayland
process, driver bind/unbind or physical HDMI test in this probe. The CPU-copy
selection is tested; its real output is NOT.

24 maintenance guard tests,32 Windows/display tests,17 collector tests and16
GJS consistency tests passed (89 total). The collector tests require running
from their module directory; the initial repository-root invocation failed to
import `collector`, then the documented module-context invocation passed.
Two new maintenance regressions distinguish the real GNOME executable from
its calendar-server companion. Source helper detection was corrected, but no
new helper was built/started and consumed budgets remain untouched.

## Current live recovery evidence

Root rollback to c4d4khx... completed15:23:48. Root helper finished15:27:16;
unit not-found/inactive/PID0, runtime/socket absent, logout timer absent. Durable
record remains counters1/1/0, phasefinished. No autostart/auto-login was installed.
Generic noninteractive sudo requires authentication; Linger=no.

After rollback, a new real CUDA32-value kernel probe completed with exit0 and
normal context release. Passive samples at15:31:35,15:31:40,15:31:45 and15:34:29
showed both NVIDIA functions suspended/D3cold/auto, complete process visibility
and no owners. The live AT-SPI panel read Intel/runtime-suspended. This proves
host CUDA and return to suspend with HDMI unplugged, NOT recovery from VFIO.

GNOME147739 still maps the failed6vc083... library despite configuration rollback;
keep HDMI unplugged for this session. It remains alive on Intel with PaperWM
and the indicator ACTIVE. No new warning entries were found after15:27.
monitors.xml retains SHA66db6c80178131fa3037e1982d2600ccdf0c365810cadbdd467187ba66b0a8b0.
Saved/booted generation154xkga9k4... and original `/etc/nixos` inputs are unchanged.
Windows is stopped. No VM, GPU transfer, new logout, reboot or startup was run.

## Remaining gate

The sole approved session test and rollback are consumed and cleaned up. A
further physical test needs a NEW explicit session-test approval, not Full
Access alone or a reset of old counters. Do not activate automatically from
this report. Full inactive KMS-device removal/re-add, guest internal/external
selection, repeated HDMI-mode VM cycles and final normal-host integration are
still incomplete. The full goal is not achieved.
