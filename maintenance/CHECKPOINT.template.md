# Precision GPU maintenance checkpoint

## Final host reboot handoff (2026-09-12 00:47 CEST; authoritative)

The user authorized the overnight job and automatic restarts. This is a continuation of that job, not a request for a plan. Main interactive coordinator is handing ownership to the existing dedicated background coordinator for the final reboot. Read this section first, then inspect the live state. Do not ask repeatedly for routine confirmations. Never use the password present in old chat; sudo is already arranged through the restricted helper.

### Live-tested results before reboot

- Windows Light launched from the installed GNOME desktop entry using `gio launch /etc/profiles/per-user/lexyo/share/applications/windows-light.desktop`. It uses the original 64 GB qcow2, OVMF and TPM, all cold-backed-up and verified. Windows normal desktop was visually inspected and user signed in during first cycle.
- Two complete Light start/stop cycles passed. First: viewer process SIGTERM (not a GUI click) led to ACPI clean shutdown in about 5 seconds, QEMU exit 0. Guest event IDs 1074 and 6006 confirm clean shutdown. Second: QMP-paused the actual guest, terminated only its viewer, waited the full 180-second timeout; explicit shutdown-timeout state and live paused QEMU verified; resumed guest, retried shutdown, QEMU exited 0. Tests and timestamps in state/live-tests.jsonl; script maintenance/test-viewer-exit.py. Never force power off the guest.
- Starting the other mode while Light runs was rejected; the original service remained running. CUDA kernel passed while Light ran, and NVIDIA suspended before the latest rebuilds.
- Ollama CUDA package is LIVE, built for sm_86. `qwen3:0.6b` generated text; journal shows CUDA0 RTX A4000, all 29/29 layers offloaded, 409.29 MiB model + 448 MiB KV on CUDA, API size_vram=930401484. Model is the only test download (about 523 MB). Ollama stays manually started per original config, not enabled at boot. Requests used keep_alive=20s or 45s and model unloaded naturally. Repeat inference after gaming return.
- Indicator root service works, sees both GNOME and the lexyoai Ollama runner with complete cross-user visibility. Fixed embedded llama-server naming to Ollama and added test (17 passing). GNOME extension needs the new graphical session to be discovered; NOT live UI-validated yet.
- After rebuilding, the OLD GNOME process 2733 acquired NVIDIA renderD129 handles. Do not detach it or claim idle power passed on this session. Fresh boot will apply the new Mutter ignore tag. Existing Intel i915 framebuffer remains active; NVIDIA fbdev=0 now configured, modules retain modeset=1, finegrained=true and power/control=auto. Do not disable runtime PM to make tests pass.
- Looking Glass matching client + kvmfr **B7-826-236efcb1** built and installed. This is an upstream DEVELOPMENT snapshot, explicitly chosen because signed IDD creates a virtual monitor without dummy HDMI. Source pinned to sha256-5OnYi9V5pHMkv/9BRw/f5TcUzCPIlKAktZffvkPrkrM=. Client syntax `lgmp:shmDevice=/dev/kvmfr0`; SPICE remains available as recovery console.
- Guest IDD and input drivers installed successfully, both current/present/OK; LGIddHelper running Auto, old Looking Glass (host) stopped/disabled. Original old Host Auto setting saved at C:\ProgramData\PrecisionMaintenance\original-host-service.json. Installer valid HostFission Authenticode; initial silent install failed ONLY for unapproved publisher. Temporarily approved verified leaf thumbprint 57476AACDE410C05A63E9FEC8B97938605B9D8F5 in TrustedPublisher, installed, removed that approval in finally. Confirmed removed. NO root certificate, firmware, TPM, Secure Boot, signing enforcement or encryption setting changed. Guest IDD hardware acceleration and actual LG capture are NOT yet tested.
- Existing Windows has signed NVIDIA driver 580.92 in store (old A2000 ghost device); current A4000 attachment will require checking driver binding/Device Manager error code, not assuming success.

### Final reboot and recovery

- Before reboot, current boot ID is `3238f096-3a82-4893-aea1-0539acb13e36`, booted generation 145. Root count is 2/3. Candidate is generation 149, `/nix/store/44lnc15m47z5hm1rkg15bm8dd00jscmq-nixos-system-precision7560-26.05.20260611.a037402`, full setup including IOMMU kernel args, kvmfr module and helper fixes. One-shot candidate will be selected, with persistent EFI default set to the already successfully booted generation 145. If candidate fails, the next MANUAL boot falls back to 145. No automatic extra reboot beyond budget.
- User tried `precision-windows console` after our clean shutdown and saw raw Connection refused. Fixed and live-validated stopped status and clear stopped-VM guidance; added 3 passing offline controller regressions. Console does not start a guest, it reconnects only when running. Latest controller removes completed control sockets and handles older stale sockets.
- Actual activation rollback to 144 was tested earlier, and 145 completed actual encrypted boot/autologin/agent restart. A failed-boot automatic watchdog recovery is NOT implemented or claimed. Preserve generations 143/144/145.
- Root helper now has `set-tested-fallback`, `set-oneshot ENTRY`, `reboot` (refuses running Windows), `rebuild-switch`, `gpu-to-linux`, `systemctl ACTION UNIT`, and `finalize`. Caller UID is 1001, not root. Use `sudo -n /var/lib/precision-gpu-maintenance/root-helper ...`; never generic sudo shell.
- Continuation exact session `01a09274-3584-7143-921a-a6ea48441100`, pinned authenticated Codex 0.153.4. Full mode loops at most 12 coordinator turns, bounded three failures per boot. On completion write state/completed AFTER cleanup. On genuine blocker restore usable system and cleanup, then state/blocked with precise report. Do not stop your own continuation service: disable/unlink and let current turn exit normally.
- Dashboard autostart is installed. Update state/progress.txt for user-visible progress and this checkpoint regularly. Keyring remains encrypted and may stay locked; agent auth is independent and already reboot-tested.

### Remaining work in the background coordinator

1. Verify candidate boot, IOMMU groups (GPU/audio only), correct NVIDIA and audio drivers, kvmfr0 char device ownership, Intel GNOME/PaperWM, runtime suspend, extension enabled and error-free. Budget will be 3/3: NO additional host reboot. Kernel module source is built for the exact same 6.18.35 kernel. No module/source mismatch assumptions.
2. Verify actual busy refusal with a self-created CUDA hold (`precision-cuda-probe --hold 30`) and/or Ollama; identify names and leave existing applications alone. Perform direct sudo precision-windows-gpu inspect/prepare/release as appropriate, with zero GPU holders before prepare. Module unload is non-forced and only after gated device opens and all owners refused. Refuse active audio PCM/hwdep; idle WirePlumber control-only subscriptions deliberately aren't GPU clients and are left running. One NVIDIA topology validated before global module unload.
3. Test reservation vs VM indicator, then Gaming actual launch (installed desktop entry), guest GPU driver status and real GPU work/rendering, Looking Glass live visible display. QGA scripts under maintenance/ work as SYSTEM through existing agent. Use `precision-windows console` as SPICE recovery when viewer has closed. Diagnostic script imports state/windows-package; this gcroot may be older but socket RPC remains compatible. Prefer installed controller for starts. QMP screendump can save PNG for inspection, but captures QXL, not necessarily the IDD/LG image; don't mislabel it LG proof.
4. Repeat at least two Gaming start/clean viewer-exit shutdown/rebind cycles; prove real CUDA kernel and Ollama CUDA after return and both GPU functions suspended. Do not claim success on configure-only or synthetic tests. If reset/driver hardware fails, stop repeated attempts, restore Linux GPU safely using scoped helpers, leave usable desktop and document precise blocker.
5. Live indicator checks: idle Intel (monitor must not wake GPU), awake named Ollama, VFIO reservation, running VM, unavailable/stale via service stop/start, extension disable/enable without errors. Readable names, no store paths/wrapper suffixes. GNOME50 supported. Synthetic backend tests: `cd modules/precision-gpu-indicator; python3 -m unittest discover -s tests -v` (17 pass).
6. Validate Linux graphics offload with a real OpenGL/Vulkan context if available, and verify no orphan holders prevent next Gaming launch. Preserve user game configs and applications.
7. Final cleanup: remove only `./maintenance/bootstrap.nix` import from flake.nix, not permanent precision-windows import. Disable and unlink temporary user continuation service (do not stop active self). Invoke root-helper **finalize**, which rebuild-switches final config, restores linger=no, clears temporary EFI boot default override to follow clean new loader.conf generation, and removes temp helper/sudoers. Nix removal restores autologin disabled and removes root sleep inhibitor/dashboard autostart. Verify actual sudo rule removal, login and sleep defaults. Keep permanent narrowly scoped precision-windows-gpu inspect/prepare/release permissions needed by launchers. Keep evidence logs/backups; close only task dashboard when finished.
8. Finish report in worktree (and state/progress.txt pointing to it): changes, tests actually passed, launcher use, recovery, how to rebuild the isolated branch, any unresolved hardware limits. User's /etc/nixos master + original untracked handoff/zip/vfio file must remain unchanged. Commit only task work in isolated branch once coherent; no force reset/rebase/push.

## Current state (2026-09-12 00:35 CEST; supersedes historical next steps)

- Reboots used **2 of 3**; one host reboot remains. Boot ID `3238f096-3a82-4893-aea1-0539acb13e36`, current and booted generation 145. Preserve 143/144/145. Actual activation rollback to 144 passed and 145 has booted successfully; boot-menu fallback itself has not been exercised.
- Reboot 2 verified unattended TPM disk unlock, root sleep inhibitor, automatic GDM login, PaperWM, network and authenticated background Astra continuation before graphical login. Evidence: `~/.local/state/precision-gpu-maintenance/boot-validation-3238f096-3a82-4893-aea1-0539acb13e36.md`. Keyring stays encrypted; no keyring password is required by the background agent.
- Background coordinator exact session `01a09274-3584-7143-921a-a6ea48441100` is currently inactive/disarmed, `continuation-mode=verify-only`. Before last reboot update this checkpoint, set full mode, arm current boot ID and use only root-helper reboot. Never run two mutation coordinators concurrently.
- Windows Light is running in user service `precision-windows.service` using the original disk/OVMF/TPM. Recheck live PIDs. The user signed in and the actual desktop was inspected. Original signed QEMU Guest Agent works, so reviewed maintenance PowerShell can run with `python3 maintenance/guest-agent.py SCRIPT.ps1` without guest credentials.
- Byte-for-byte cold disk backup plus matching OVMF/TPM hashes verified under `~/.local/state/precision-gpu-maintenance/windows-backup/`. Keep these backups. Windows BitLocker was already fully decrypted; TPM ready. Linux LUKS slots and firmware remain untouched.
- Live PASS: baseline CUDA kernel, Windows Light boot/desktop, simultaneous mode start rejected, CUDA kernel while Light runs, subsequent NVIDIA runtime suspension. NO viewer-close/shutdown cycle or gaming handoff has passed yet. IOMMU is not enabled on this boot.
- Full Nix build with sm_86-only Ollama CUDA and indicator completed successfully. Latest launcher/controller changes still need full build/switch. Current Ollama service is the old CPU package; test model qwen3:0.6b (about 523 MB) downloaded but CUDA inference not yet tested.
- Existing Looking Glass Host B7 has no capture display in Light. Inspecting pinned development B7-826-236efcb1 client/IDD for headless virtual monitor support. Downloads in state/downloads, extracted source `/tmp/precision-looking-glass.EtZxct`; NOT installed yet. Do not disable Windows driver signature enforcement, Secure Boot, TPM or encryption to install it.
- Implemented `precision-windows.nix`, modules/precision-windows (controller, restricted GPU helper, actual CUDA probe), supplied indicator with 16 passing backend tests. Not yet live installed. One lock and one systemd service protect original Windows installation; never kill GPU holders or force power off Windows. Shutdown timeout must leave VM locked and GPU assigned.
- GC-root package for current tests: `~/.local/state/precision-gpu-maintenance/windows-package`. Commands status, view, console, shutdown communicate with running controller. Current user service started directly with this package. Final launchers will use installed /run/current-system/sw/bin paths.
- Temporary visible dashboard launched in Kitty and declarative autostart prepared. Progress text is `~/.local/state/precision-gpu-maintenance/progress.txt`.
- Still required: complete live Light shutdown/repeat/timeout tests; install and verify CUDA Ollama actual inference and idle; complete LG matching package/guest integration; final host reboot with IOMMU and full continuation; gaming busy-refusal, repeated GPU detach/start/clean stop/rebind/CUDA/suspend; live indicator power and readable-owner checks; clean up temporary bootstrap privileges/login/linger/inhibitor/continuation/dashboard and final report. Preserve user's original repo untracked files and existing desktop settings.

- Job ID: `precision-gpu-handoff-20260911`
- Worktree: `/home/lexyo/worktrees/precision-gpu-vm-handoff`
- Branch: `codex/precision-gpu-vm-handoff-20260911`
- Original worktree: `/etc/nixos` (do not modify or clean its untracked files)
- Reboot budget: 3 total; the root-owned counter is authoritative.
- Known-good recovery entry: `nixos-generation-143.conf`

Read `/etc/nixos/gpu-vm-handoff.md` for the complete user requirements. Verify all recorded assumptions against the live host. Never kill Linux GPU clients to obtain passthrough; report and refuse the gaming launch. Preserve GNOME, PaperWM, disk encryption, the Windows disk, OVMF variables, TPM state, firmware state, and NVIDIA runtime power management.

## Baseline captured before changes

- NixOS 26.05, kernel 6.18.35, systemd-boot generation 143.
- Root is LUKS2 on `/dev/nvme0n1p2`; encrypted swap is `/dev/nvme0n1p3`.
- Intel `00:02.0` drives the internal eDP panel. NVIDIA functions are `01:00.0` (`10de:24b7`) and `01:00.1` (`10de:228b`).
- NVIDIA driver 595.71.05 is currently loaded with `power/control=auto`, but the GPU was active because GNOME Shell and Showtime held device handles.
- IOMMU groups were absent on the baseline boot because IOMMU kernel parameters were not enabled.
- Existing Quickemu installation uses `/home/lexyo/windows-11/disk.qcow2`, `/home/lexyo/windows-11/OVMF_VARS.fd`, and `/home/lexyo/windows-11/tpm2-00.permall`. Preserve these files and their identity.
- Original GDM auto-login is disabled. Original linger is disabled. GNOME idle/lock/sleep values were recorded without changing them.
- `/etc/nixos` had no tracked edits and three untracked files: `gpu-vm-handoff.md`, `precision-gpu-indicator.zip`, and `precision-vfio.nix`.

## Completed

- Created the isolated worktree and branch above.
- Updated only the `nixpkgs-unstable` lock input. Codex changed from 0.151.0 to 0.153.4.
- Built Codex 0.153.4 and successfully ran an authenticated `gpt-6-astra` probe (`ASTRA_OK`).
- Reviewed the supplied handoff and indicator source. The A2000 IDs in the old VFIO draft are invalid for this upgraded A4000.
- Activated bootstrap generation 144 while remaining booted from generation 143.
- Verified Codex 0.153.4 is live and authenticated for `gpt-6-astra`.
- Verified `/var/lib/precision-gpu-maintenance/root-helper` is root-owned and byte-identical to the reviewed worktree source.
- Verified the task-scoped helper is the only passwordless sudo command; ordinary noninteractive sudo is denied.
- Verified user linger is enabled, the temporary sleep inhibitor is active, and the unarmed continuation service exits cleanly.
- Verified the dedicated Astra coordinator resumes successfully from a transient user-systemd service (`SYSTEMD_RESUME_OK`).
- Verified generation 143 is the currently booted known-good recovery entry and generation 144 is the new default. Root and encrypted swap each retain a password slot and three TPM2 slots.

## Reboot 1/3 checkpoint

- Pre-reboot boot ID: `a09c49a5-9c3f-48c4-b3da-d9c0f1ae1cc5`
- Intended entry: `nixos-generation-144.conf`
- Expected after reboot: a different boot ID; generation 144 current; root and encrypted swap unlocked without enrollment changes; networking online; `Linger=yes`; continuation launched before graphical login; resume log contains this boot ID.
- If generation 144 does not boot, select `NixOS (Generation 143...)` from systemd-boot. It is the recovery generation proven by the current boot.

## Reboot 1/3 observed result

- Booted generation 144 with boot ID `5c170293-b71e-4406-9182-3cc9d4425248` and reached the graphical desktop.
- TPM disk unlock succeeded unattended. The boot journal shows both encrypted mappings open at 11.5 seconds, the headless user manager at 15.7 seconds, and the GNOME login at 30 seconds. The password the user entered was for GNOME login/keyring, not LUKS.
- Two TPM token attempts reported stale policy before a later enrolled token succeeded. Preserve every password and TPM slot; no re-enrollment is necessary for this task.
- The continuation unit started before graphical login and authenticated successfully. Its first attempt failed because an inner sleep inhibitor required interactive PolicyKit authorization; the bounded retry resumed the exact Astra coordinator after graphical login.
- The parallel coordinator was stopped while clarifying the prompt. The continuation marker remains disarmed; a later reboot must still be explicitly re-armed only after checkpoint review.

## Next safe actions

1. Fix the headless inhibitor path. Add temporary graphical auto-login only when the next reboot is ready, since GNOME login and keyring did require user input while LUKS did not.
2. Implement and build the full Nix/VM/Looking Glass/indicator setup, then apply and live-test it.
3. Before every later reboot, update this checkpoint, write the current boot ID to `armed`, select a safe boot entry if needed, and call only `/var/lib/precision-gpu-maintenance/root-helper reboot` through sudo.
4. On completion, disable and unlink both temporary user units, remove auto-login/inhibitors, switch the final configuration, call the root helper `cleanup`, and verify sudo no longer works noninteractively.

## Bootstrap correction and recovery test (before reboot 2)

- The root maintenance helper works without a password; session UID remains lexyo (1001).
- Replaced the user sleep-inhibitor service and nested continuation inhibitor with a root system service. Confirmed the active inhibitor is owned by UID 0.
- Enabled temporary GDM auto-login for lexyo in maintenance/bootstrap.nix. Existing keyring encryption and credentials are untouched. Codex uses its existing mode-0600 auth.json independently of the keyring.
- LUKS metadata audit: root and swap each have a password slot plus three systemd-tpm2 tokens; every token uses SHA256 PCRs 0+7. No enrollment changes were made.
- Performed an actual activation rollback with root-helper recovery-test to the booted generation 144. Confirmed /run/current-system returned to its exact store path, GNOME PID 3663 survived, networking was online, and the restricted root helper remained usable. Reapplied the corrected bootstrap using rebuild-switch.
- Reboot 2 is a bootstrap-only check using continuation-mode=verify-only. The automatic coordinator should write a boot-validation report and stop. The interactive goal then continues implementation. Do not infer that any GPU/VM/indicator work is complete.
- Reboot 2 pre-boot ID: 5c170293-b71e-4406-9182-3cc9d4425248. Selected one-shot entry: nixos-generation-145.conf. Expected store path: /nix/store/9l8k7a61fr4apply5kks98dqk8bh9ii8-nixos-system-precision7560-26.05.20260611.a037402. Recovery activation path remains generation 144, with generations 143 and 144 both retained in the boot menu.
