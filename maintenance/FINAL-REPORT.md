# Precision GPU handoff — final maintenance report

Job: `precision-gpu-handoff-20260911`. Branch: `codex/precision-gpu-vm-handoff-20260911` in `/home/lexyo/worktrees/precision-gpu-vm-handoff`.

**Status: blocked on a fresh full-configuration boot and remaining Gaming USB validation.** The authorized three-reboot budget is exhausted. All temporary maintenance access has been removed. No completion marker is written.

## Verified results

| Requirement | Actual evidence |
| --- | --- |
| Windows installation preserved | Original qcow2, OVMF variables and swtpm state used by both modes; cold byte-verified backups retained. |
| Windows Light | Two overnight clean shutdown cycles; full 180-second paused-guest timeout preserved the actual QEMU process, then clean shutdown after resume. Morning launch on final controller displayed normal Windows desktop. |
| TI-Nspire in Light | User selected the actual 0451:e022 CX II in remote-viewer's USB prompt and confirmed recognition in existing TI CAS Student Software. No calculator firmware, documents, application installation or licensing changes. |
| NVIDIA busy refusal | Actual CUDA owner was named and handoff refused; its work exited naturally. |
| VFIO isolation | On full boot149, IOMMU group17 contained only A4000 GPU01:00.0 and its audio01:00.1. Direct reservation/release passed. |
| Gaming hardware/display | Healthy signed Windows NVIDIA580.92 A4000 driver, problem0; actual Windows CUDA kernel verified32 values; hardware Looking Glass IDD and Intel EGL/KVMFR client. Captured real Looking Glass frame stream, not just QXL. |
| Two Gaming cycles | First viewer exit01:07:30, QEMU0 about01:07:36, Linux CUDA+suspension01:08:03. Second viewer exit01:12:33, QEMU0 about01:12:39, Linux CUDA+suspension01:13:06. Second IDD hardware selection was automatic. |
| Host shutdown explanation | Previous boot ended in normal GNOME/logind poweroff, not an observed GPU crash. Second GPU return completed during orderly shutdown. No kernel Oops/Xid found in that boot. |
| Linux AI/graphics | Post-Gaming CUDA kernel, finite Vulkan offload selected A4000; Ollama qwen3:0.6b generated CUDA_OK with GPU-resident model. Model unloaded naturally and GPU/audio suspended. Morning CUDA also passed alongside Light. |
| Indicator | On full boot: visible Intel, named Ollama, VFIO reservation, actual VM owner, GPU ? when collector stopped, recovery and extension re-enable.17 backend tests pass. |
| Controller |10 offline regressions pass: stale process/socket states, bounded memlock preflight, failed guest reporting, explicit USB identity/cancel behavior. |
| Reboot recovery/auth | Three authorized reboot attempts used; TPM encrypted unlock, network, authenticated exact-session continuation and PaperWM validated. This morning booted the retained recovery generation145 after normal poweroff. |

Two distinct USB paths are present. Three SPICE redirection channels and the original manual selector are restored, with automatic attachment disabled. Its actual Light application check passed. A separate TI-Nspire chooser uses per-device QMP forwarding without another SPICE client; healthy Windows enumeration passed, including refusal of a stale selection and removal of a disconnected old attachment. **Direct-path Student Software recognition and Gaming USB are not validated.** Use the proven Light SPICE path for the calculator.

Looking Glass is pinned to upstream development snapshot B7-826-236efcb1 with matching signed IDD/input drivers and Linux kvmfr. First driver installation needed one IDD refresh after NVIDIA became healthy; the second start selected hardware automatically. The first guest CUDA test passed; an extra second-cycle guest CUDA probe was interrupted by clean viewer shutdown and is not claimed as passing. The user reported that internal-screen responsiveness worked very well; no numerical latency or game benchmark was measured.

## Current boot limitation

Boot `04d8b127-6d38-43d6-ae8a-4c7ea42943d4` is still booted from generation145. Switching installs the full configuration but cannot activate Intel IOMMU in that running kernel. kvmfr is not in the recovery module tree and the current GNOME session has not discovered the indicator. Existing GNOME/Xwayland NVIDIA handles were preserved. The GPU can still runtime-suspend in this session, but Gaming must refuse until a fresh full-config boot/session. No further reboot is authorized: counter **3/3**.

The permanent configuration leaves NVIDIA with Linux by default, retains finegrained power management and auto runtime policy, and sets the bounded Gaming memlock allowance needed for16GiB guest RAM. A failed first launch exposed the original8MiB memlock limit; it failed before Windows boot, automatically restored Linux CUDA/suspension, and was corrected before the two successful Gaming cycles.

## Cleanup verification

Clean generation154 is active: `/nix/store/xkga9k4w11g6yzbzp0pgwgsfg7p1c5cw-nixos-system-precision7560-26.05.20260611.a037402`. Finalization exited0. Verified results are saved in `state/cleanup-verification.json` and `state/finalize.log`:

- Temporary bootstrap import, GDM auto-login configuration, linger, root sleep inhibitor, maintenance sudo/helper, dashboard autostart and continuation links are removed. Ordinary noninteractive sudo is denied. Only the permanent inspect/prepare/release helper permissions remain.
- Continuation is disabled and unlinked, still active solely to finish this response. It was not stopped. Its armed marker is removed; it will exit normally.
- The temporary EFI default145 override is removed, so normal boot selection follows the clean generation. Recovery143/144/145 were retained. Selecting an old bootstrap recovery generation also restores its historical maintenance configuration; it is not the cleaned daily configuration.
- GNOME PID2742 and Windows Light QEMU10885/controller10881 survived cleanup. The actual desktop is now locked normally; PaperWM remains enabled and is inactive during lock, after being verified ACTIVE earlier. No session unlock/restart was forced.
- Both NVIDIA functions are currently runtime-suspended with `power/control=auto`. The network is connected; NetworkManager still labels its internet connectivity probe limited. Authenticated tool/network requests succeeded during the run.
- The user's Light/SPICE calculator connection remains available. Windows and encrypted-disk identities, cold backups and existing credentials are preserved. No Windows application or GPU client was killed.

The interactive observer proposed extending the budget to four based on a broad request to finish without prompts. This dedicated continuation retained the explicit three-reboot constraint in its latest direct user instruction. It neither increased the counter budget nor reacquired temporary privileges after cleanup.

## Evidence and later use

See [WINDOWS-GUIDE.md](../WINDOWS-GUIDE.md) for launchers, clean shutdown, USB selection and rebuild instructions. `/etc/nixos` master and its original three untracked files remain untouched. No remote push or merge was performed.

Evidence remains in `/home/lexyo/.local/state/precision-gpu-maintenance/`: `live-tests.jsonl`, `gaming-second-return-journal.txt`, `gaming-second-audit.txt`, `idd-hardware-refresh.txt`, `gaming-lg-first.png`, `calculator-guest-audit.txt`, `calculator-current-audit.txt`, `ti-diagnostic.txt`, the panel captures and cold `windows-backup/`.

Primary implementation references: [SPICE manual USB selection](https://www.spice-space.org/usbredir.html), [QEMU USB devices](https://www.qemu.org/docs/master/system/devices/usb.html), and the pinned Looking Glass source documentation. The result claims above are based on live local evidence and user confirmation.
