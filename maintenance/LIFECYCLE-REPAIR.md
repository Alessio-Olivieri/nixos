# GPU return repair — work in progress, 2026-09-12

## Actual failure and containment

The user launched Gaming16:12:24; Windows worked with NVIDIA. QEMU exited0,
NVIDIA driver reload began16:13:20, and GNOME189534 SIGSEGV16:13:24 during KMS
resource reassignment. Its stack includes meta_crtc_kms_assign_extra, g_set_error
and strlen. CUDA passed16:13:27, but the original desktop was lost. The CPU-copy
HDMI display-only test had passed; it did not validate GPU removal/return.

The16:45:19 controller-only test activation now refuses Gaming in both controller
and root prepare, without changing GNOME/GDM/kernel/login. Currentxh1bs... uses
controllerjaxm9... and the same GNOME192901/Mutter3aqm. Linux dual-monitor layout,
PaperWM/indicator and monitors.xml survived; real CUDA32-value kernel passed.
The temporary local launcher bridge was removed; Gio resolves the declarative
per-user launcher. The154 boot entry/default/profile remains unchanged.

No owner was bypassed, no process work killed, no host GPU detached and no host
logout/reboot attempted. All prior helper budgets remain consumed. One ordinary
sudo authentication was used only at its terminal input, with no credential in
files/scripts/config. The temporary root shell exited16:49; no new sudoers,
autologin, startup service, sleep override or persistent agent was installed.

## Source changes, not a claim of physical success

The explicit lifecycle candidate builds on the separately reproducible CPU-copy
candidate, pinned to Mutter50.1. It holds strong references to KMS CRTCs,
connectors and assigned planes while their main-thread wrappers remain live;
reconciles CRTC wrappers using object identity, not reused kernel IDs; rebuilds
CRTC/plane/capability resources on return; discards stale queued flush callbacks;
and handles same-path scanout-device re-add without adding a duplicate GPU.

The second revision also retires connector timers and FD holds in the KMS thread
before surviving main-thread references can be finalized, and rejects incomplete
resource reconstruction. These are implementation changes under test, not a
complete upstream-supported hot-unplug implementation or an update guarantee.
The version assertion intentionally requires review if the pinned Mutter changes.

- First lifecycle build:3j76lv9pwdm0qqvjad1ygwlb7kzy49r5; headless probe206910
  exited0 at16:37:46, Intel primary, no NVIDIA private handles, one lease global.
- Second lifecycle build:pzibpsikbqi8nfad1bnl706lh4c7si0w; headless probe272654
  exited0 at17:04:13, with the same checks passing. One normal NVIDIA render-node
  FD is expected in headless mode; this is not a zero-owner physical-KMS test.
- Neither lifecycle build is mapped by the real GNOME session.
- Controller fixes preserve display-recovery-failed separately from successful
  GPU/CUDA return, detect a replacement GNOME session even with HDMI inactive,
  and tolerate a guest exiting between poll and the QMP shutdown request.

## Tests and their limits

43 Python Windows tests,17 indicator tests,31 maintenance tests and16 GJS display
guard tests pass directly. Flake checks now build the controller/display and
indicator tests so later rebuild validation can repeat them. No synthetic/unit
test is counted as physical VM or GPU handoff success.

The isolated Linux VM fixture uses no host PCI device and no Windows disk,
firmware variables or TPM. It runs GNOME on a virtual primary GPU, disables a
secondary display, requires zero process owners, then attempts up to3 driver
removal/return cycles while checking the same GNOME PID and mapped library.
It has a360-second total deadline and shorter stage deadlines. Autologin and
VKMS policy overrides exist only inside this disposable fixture.

Recorded fixture limitations:

- Minimal Nix test QEMU lacked QXL; switched the fixture to the full QEMU package.
- Exact process-name matching failed for Nix's wrapped GNOME; replaced it with
  the actual DisplayConfig D-Bus owner's PID. The blocked fixtures were cancelled.
- With QXL, BOTH baseline CPU-only3aqm and first lifecycle3j76 retain four device
  handles across GNOME/systemd/logind after display disable. Both tests refused
  removal at their30-second owner deadline. This does not isolate a lifecycle
  regression and does not validate driver return. Logs/screenshots are under
  /tmp/precision-kms-vm-20260912.af6Z2U and
  /tmp/precision-kms-baseline-20260912.ockWmu.
- VKMS was loaded but ignored by Mutter's packaged udev policy. A TAG-= override
  removed CURRENT_TAGS but not historical TAGS; GUdev's get_tags still returned
  mutter-device-ignore. The fixture now replaces only the VKMS-ignore lines in
  its packaged61-mutter.rules, preserving other rules. No laptop rule was changed.
  Audit log: /tmp/precision-vkms-audit-20260912.37DqOu/lifecycle-journal.txt.
- The corrected VKMS fixture's outcome is pending. Do not count any earlier
  fixture boot or fresh login as a successful removal/return cycle.

Reproducible commands from this worktree:

```sh
nix build --no-link .#checks.x86_64-linux.precision-windows-safety
nix build --no-link .#checks.x86_64-linux.precision-gpu-indicator
nix build --no-link .#precision-mutter-lifecycle-candidate
nix build --no-link .#precision-mutter-lifecycle-vm-test
```

For a streamed diagnostic run, build .#precision-mutter-lifecycle-vm-test.driver
and run its bin/nixos-test-driver with a fresh private XDG_RUNTIME_DIR and output
directory. The baseline fixture is .#precision-mutter-cpu-vm-test. Neither output
activates a NixOS host configuration. Preserve failures and stop on any owner or
compositor failure; never force an unbind to make a test pass.
