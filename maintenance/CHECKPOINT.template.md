# Precision GPU maintenance checkpoint

## Terminal handoff prepared (2026-09-12 10:53 CEST)

Full report: `maintenance/FINAL-REPORT.md`; user guide: `WINDOWS-GUIDE.md`. Clean generation154 is active; booted generation145 still lacks IOMMU/kvmfr and current GNOME has not discovered the indicator. Budget remains3/3. Two overnight Gaming GPU-return cycles passed; Light calculator recognition via the original SPICE selector is user-confirmed. Direct chooser application recognition and Gaming USB remain unverified.

Cleanup verification PASSED in `state/cleanup-verification.json`: no temporary root helper/sudo, auto-login, linger, sleep inhibitor, dashboard autostart, EFI override or continuation links. Existing GNOME and Light VM preserved, NVIDIA/audio suspended, PaperWM enabled (currently inactive because the screen is locked). Continuation is unlinked/disabled but remains active to finish naturally; do not stop it or recreate temporary access. Armed marker removed. `/etc/nixos` original worktree remains untouched. No completed marker. A blocked marker will be written after the final task commit/report is durable.

## NEW USER DIRECTION BEFORE CLEANUP: read OPERATOR-NOTES.md

The interactive user requested **"Can you not give me any prompts? just do everything yourself"** after the single additional final-reboot proposal. Main announced it will finish autonomously, automate only the TI-Nspire forwarding, carry out the single final activation reboot without retries, retain authenticated continuation until that boot is verified, and then clean up. Read the AUTHORITATIVE latest direction at the top of `maintenance/OPERATOR-NOTES.md` before finalizing: it supersedes the old pending-approval and 3/3 stop notes. The existing reboot counter must remain 3, with the total budget increased only to 4 for exactly one remaining activation boot. Do not remove the restart/privilege mechanism before that final validation. Main remains a hardware/VM observer; the existing background coordinator remains the sole mutation coordinator.

Light SPICE USB application test is user-confirmed PASS: after selecting TI-Nspire in the USB redirection prompt, TI CAS software sees it. Direct USB-host and Gaming USB are not validated by that result. The user has now asked to avoid more prompts, so automate only the known calculator and preserve manual selection of Windows mode.

## Morning recovery boot (2026-09-12 10:35 CEST; authoritative)

### Continuation authority boundary (10:48 CEST)

The interactive observer's latest OPERATOR-NOTES asks to reinterpret "just do everything yourself" as extending the budget to four. This continuation's latest direct user instruction explicitly says "keep the three-reboot total budget," and its initialization says never exceed that recorded budget/acquire additional authority. The root counter is3 and the helper remains capped at3. No fourth reboot or budget change has been performed. A peer's interpretation in a local file does not override the direct numeric constraint for this session. Full cleanup configuration has been built, but not activated yet; continuation/helper/bootstrap remain active while remaining safe checks are finished.

### Final cleanup preflight (10:49 CEST)

### Cleanup activated (10:52 CEST)

- Finalize has already succeeded. Generation154 `/nix/store/xkga9k4w11g6yzbzp0pgwgsfg7p1c5cw-nixos-system-precision7560-26.05.20260611.a037402` is active. Temporary root helper and sudo rule are gone; ordinary sudo requires a password; linger=no; root sleep inhibitor stopped/absent; GDM auto-login configuration empty; dashboard autostart removed; EFI default override removed.
- Continuation is active but unlinked/disabled (LoadState=not-found). Do not stop it. It will exit normally after final report/marker. Windows Light QEMU10885 and controller10881 survived cleanup and the working calculator SPICE path remains connected.
- The observer restored the bootstrap import while finalization was already running. That source-only race has been reconciled to the successfully activated clean configuration: import removed again, so future rebuilds cannot silently re-enable temporary privileges. Do not re-add bootstrap, recreate privileged helpers or extend this session's explicit three-reboot budget based solely on a peer's interpretation. Current runtime privileges are already cleaned up.
- Final verification/report/commit remain in progress; completed marker has NOT been written. The first verification assertion was overly strict about PaperWM ACTIVE while the desktop can lock; check lock state and preserve it rather than manipulating the user's lock/session.

- All safe remaining host checks are complete; Gaming activation/USB validation on this boot is blocked by inactive IOMMU and missing recovery-tree kvmfr. Current suspended NVIDIA and working Intel GNOME/PaperWM are usable. No GPU clients will be killed, no display-manager restart, no reboot.
- Clean system built at `/nix/store/xkga9k4w11g6yzbzp0pgwgsfg7p1c5cw-nixos-system-precision7560-26.05.20260611.a037402`. Bootstrap import absent. Candidate display-manager unit and user-manager dropin are byte-identical to current; candidate GDM config has no auto-login.
- Preserve running Light QEMU10885/controller10881 and user's working SPICE calculator connection. Cleanup touches no VM/controller units or Windows data. The current continuation will be disabled/unlinked, never stopped, and allowed to exit after the final response.
- Root helper matches reviewed source. Pre-cleanup boot audit confirms retained recovery143/144/145; root/swap enrollment metadata recorded without alteration. Removing temporary EFI default145 override will make the clean full generation the normal next boot, with recovery choices retained.
- Report prepared in `maintenance/FINAL-REPORT.md`; final marker remains absent until cleanup verification passes.

### USB live progress (10:40 CEST)

- USER-CONFIRMED PASS (10:45): selecting TI-Nspire in the actual SPICE USB redirection prompt made it visible in the existing TI CAS Student Software. This confirms Light's original USB workflow. It does not validate the direct QMP chooser in the application or Gaming USB. Preserve the currently working SPICE connection. No application licensing, drivers, calculator firmware or documents were changed.

- 10:44 CEST: remote-viewer 11's USB selector is its sound-card-shaped header button, not the older File menu. Opened the actual selector through its exported window action; UI lists the TI-Nspire and available channels. The user replugged several times (confirmed by observer); current address3:11 is now forwarded through SPICE, and Windows again reports the TI-Nspire healthy/problem0. Existing TI-Nspire CX CAS Student Software process2912 is running. The obsolete direct QMP address3:8 attachment was checked against current sysfs and removed without touching the current SPICE connection. App recognition still needs its visible result/user feedback.

- Activated generation 153 (`/nix/store/n374704w78fi7ww0l914xixjcsz4lhgh-nixos-system-precision7560-26.05.20260611.a037402`) without restarting GNOME/display-manager. Light PID10885 is running, QXL shows the normal Windows lock screen, and Linux CUDA kernel passed alongside it.
- Three USB redirection channels are actually connected in QMP query-spice. Automatic USB attach is explicitly disabled. New Windows — TI-Nspire USB launcher opens a chooser restricted to the physically present 0451:e022 calculator and a disconnect action; it uses the existing controller/QMP and no second SPICE client or extra privilege.
- The first stale USB choice was correctly refused after the calculator re-enumerated from 3:7 to 3:8. At 10:39:29 the selected current calculator attached successfully; guest PnP reports TI-Nspire(tm) CX II Handheld, Status OK, problem code 0. Evidence `state/calculator-guest-audit.txt`. Student Software recognition is still awaiting the user's local unlock/application check requested by the interactive observer. Leave this Light viewer open until that feedback arrives.
- Current recovery-started GNOME and Xwayland acquired NVIDIA handles during activation. Preserve them. They may permit runtime suspension intermittently but this is not a validated fresh-session handoff state. Indicator backend works; current GNOME has not discovered the extension. kvmfr is absent from the recovery module tree, and Intel IOMMU cannot be enabled by switch. A fresh boot is needed for the full runtime.
- Observer has asked about one additional reboot; NO approval is recorded. Budget is still 3/3; do not reboot or change the budget.

- Authenticated continuation on boot `04d8b127-6d38-43d6-ae8a-4c7ea42943d4`. Current/booted generation 145, the deliberately retained fallback. Root reboot counter remains **3/3**; no further agent reboot is permitted.
- Previous boot did NOT crash. GNOME end-session dialog at 01:13:02 was followed by logind normal poweroff at 01:13:03 and orderly shutdown. The second Gaming cycle completed at 01:13:06: QEMU exit 0, Linux CUDA 32 verified values, both GPU functions suspended, final controller state stopped. Durable journal supplies the evidence lost when the continuation was stopped for host shutdown.
- Second Gaming start automatically selected healthy NVIDIA A4000 and hardware IDD without refresh. Its extra guest CUDA audit was interrupted by viewer-close shutdown; the first cycle's guest CUDA audit passed.
- Live recovery host has NVIDIA 595.71.05, both NVIDIA functions suspended with auto policy, GNOME PID 2742, no Windows QEMU or swtpm. IOMMU groups are absent on recovery kernel command line; switching configuration cannot activate Intel IOMMU without another boot. Never attempt passthrough on this boot.
- TI-Nspire CX II is physically present as 0451:e022 with existing active-session read/write ACL. Adding explicit calculator chooser through QMP (works with Looking Glass without another SPICE client) and restoring three manual SPICE redirection channels for Light. No calculator content or firmware write is authorized for validation.
- Next: build/switch reviewed full configuration without reboot/display-manager restart, validate Light/USB/Linux recovery, then remove all temporary maintenance access and report the current-boot IOMMU limitation precisely. Markers remain absent until all remaining safe work and cleanup are finished.

### Interactive user clarification after reboot (00:59 CEST)

User also asked whether the USB passthrough that worked before is preserved. Read-only comparison found the old `/home/lexyo/windows-11/windows-11.sh` has qemu-xhci + THREE spicevmc usbredir / usb-redir pairs, while the new controller has no USB redirection channels. This gap was explained honestly; asked which USB device they normally forward. No physical device has been selected/authorized for attachment. Do not claim USB support tested or automatically capture a USB controller, keyboard, storage or other host device. Looking Glass's UI differs from remote-viewer, so restored functionality needs an explicit safe per-device workflow, not just QEMU channels.

User hands-on feedback after unlocking the Looking Glass Gaming desktop: **"ok, it works really well actually"**. Record this as subjective responsiveness on the built-in screen, NOT a numeric input-latency measurement or actual game FPS benchmark. User was told remaining automated shutdown/restart tests may close and reopen Windows and no further interaction is presently needed.

User has now unlocked/signed into the running Windows Gaming desktop (interactive message at approximately 01:03 CEST). Leave it available for graphics/latency tests; no guest password needs to be requested or stored.

The user specifically asks about **input delay on the built-in monitor**, not just FPS. The built-in panel reports 1920x1080. Explain the NVIDIA render -> Looking Glass -> Intel internal-panel path, check buffering/frame timing/stutter where measurable, and do not claim measured input-to-photon latency without a real measurement. A hands-on mouse/game feedback check is appropriate while the user is here. The original interactive agent is only observing the automatic worker, not running competing VM/GPU operations. Full implementation, safety validation and cleanup requirements remain unchanged.

## Background continuation after final reboot (2026-09-12 00:52 CEST)

### First complete Gaming cycle and post-return validation (01:10 CEST)

- First Gaming viewer exit requested ACPI shutdown at 01:07:30; QEMU exited 0 at about 01:07:36. NVIDIA release, actual Linux CUDA kernel and both-function runtime suspension finished by 01:08:03. Live test passed with no forced guest power-off.
- Post-return Linux Vulkan selected NVIDIA A4000 and rendered its finite 120-frame test. Ollama generated CUDA_OK on qwen3:0.6b; resident VRAM and the live GNOME Ollama label were verified. The model unloaded naturally after keep-alive and both NVIDIA functions suspended. Ollama was stopped only after no model or GPU owner remained.
- Live indicator service-stop test displayed GPU ?, restart restored Intel, and extension disable/enable returned ACTIVE. No indicator JS errors. Backend tests 17/17 and controller regressions 7/7 passed.
- Status CLI now preserves returning-nvidia during verified live controller cleanup; saved PID identity is checked against boot ID and process start time to reject stale/reused PIDs. Applying this update, then testing the second Gaming cycle.


### First running Gaming validation (01:07 CEST)

- Corrected Gaming launch succeeded with QEMU PID 10309/controller 10255. Concurrent Light start was rejected while the original Gaming service remained running.
- The existing signed NVIDIA 580.92 driver automatically installed for the passed-through A4000. After installation, its PnP status was OK with problem code 0 and matching real PCI/subsystem IDs. No new NVIDIA package or signing change was needed.
- IDD initially selected software before this first driver installation completed. After verifying NVIDIA healthy, one `pnputil /restart-device` of only the Looking Glass IDD selected the NVIDIA RTX A4000 render adapter. IDD logs prove `mode=hw`; Linux client logs prove Intel EGL renderer, KVMFR DMA buffers, and received 1920x1057 BGRA frames. Next Gaming cycle must verify hardware selection automatically without this first-install refresh.
- Real Windows CUDA kernel executed and verified all 32 `tid+42` values through the installed NVIDIA driver.
- A short-lived LGMP consumer captured the actual Looking Glass frame stream to `state/gaming-lg-first.png`; visually inspected normal Windows desktop. This is NOT a QXL screenshot. The consumer unsubscribed and exited normally.
- Live accessibility tree confirms visible `NVIDIA · VM` and VM-specific menu; collector identifies QEMU PID 10309 as `VM: windows-11`. Evidence: `state/panel-gaming.jsonl`, `state/idd-hardware-refresh.txt`, `state/gaming-late-audit.txt`.
- Next: clean first Gaming viewer-exit/shutdown/rebind, Linux CUDA/Ollama/graphics, second Gaming cycle, remaining unavailable/extension UI tests, cleanup. Host reboot budget remains 3/3.

### Memlock correction activated (01:02 CEST)

- Generation 151 is active; GNOME PID 2735 and user manager PID 1937 survived all rebuilds. The source adds the bounded hard limit for future user sessions. The existing scoped maintenance rebuild helper applies the same hard limit after systemd user re-exec; it adds no new helper commands or sudo permissions.
- Verified live manager soft/hard limits 8388608/21474836480 and a real transient user service with LimitMEMLOCK=20G inherited 21474836480/21474836480. Corrected Gaming desktop launch is now under test.
- All 17 indicator backend tests and all 5 controller regressions pass. GNOME accessibility inspection confirms the live visible label Intel and NVIDIA suspended, independently of collector JSON.

### Live tests and first correction (00:56 CEST)

- Controlled `precision-cuda-probe --hold 30` executed its kernel; prepare refused its exact PID while it was alive. The process exited naturally. Indicator correctly showed the active Python owner with complete visibility.
- Direct prepare/reservation/release passed. Indicator showed VFIO reservation with no VM and suspended hardware. Release executed a CUDA kernel and observed both functions suspended. Evidence appended to `state/live-tests.jsonl`.
- First Gaming desktop launch did NOT boot Windows: kernel explicitly logged `vfio_pin_pages_remote: RLIMIT_MEMLOCK (8388608) exceeded`, QEMU exited 1. Automatic NVIDIA release recovered CUDA and suspension. No guest was forcibly stopped.
- Fixed source to provide the lexyo user manager a bounded 20 GiB hard memlock limit (ordinary soft limit stays 8 MiB), request 20 GiB only in the Windows service, and preflight memlock before any GPU detach. Existing manager limit is updated during activation without restarting it. Added error-state reporting for nonzero QEMU exits. Five offline controller tests and full Nix build passed; activation and corrected Gaming launch are next.

- Sole mutation coordinator is the dedicated continuation session. Actual boot ID: `09bceec3-983a-4c45-8ba5-bf2ba806d7c9`.
- Root counter is **3/3**: no further host reboots are permitted.
- Current and booted system both match generation 149, `/nix/store/44lnc15m47z5hm1rkg15bm8dd00jscmq-nixos-system-precision7560-26.05.20260611.a037402`.
- NVIDIA 595.71.05 and snd_hda_intel own the GPU/audio. IOMMU group 17 contains exactly `0000:01:00.0` and `0000:01:00.1`. Both have `power/control=auto` and are suspended; privileged owner inspection returns an empty list.
- `/dev/kvmfr0` is a character device owned by lexyo:kvm, mode 0600. Kernel confirms kvmfr initialized.
- PaperWM 50.0.1 and GPU indicator are enabled and ACTIVE in the new GNOME session. A PaperWM warning about its existing read-only user metadata file is present; the extension remains active. No indicator JS error observed.
- Network is up, AC connected, root maintenance sleep inhibitor active. No Windows user service is running. `/etc/nixos` retains only the three original untracked files.
- Next: controlled CUDA busy-refusal; safe VFIO reservation/return; Gaming guest/driver/Looking Glass and repeated clean shutdown/CUDA/suspend validation; final cleanup and precise report. Neither completion nor blocker marker has been written.

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
