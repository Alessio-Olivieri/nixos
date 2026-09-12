# Precision GPU handoff — final maintenance report

## Rebuild-managed integration — September12, latest

The Windows output selector is now packaged by Nix. A bounded user service runs
on activation and VM launch, waits for QGA and reconciles the protected helper,
startup task and ordinary-user shortcuts. No manual copying of Windows helper
executables is required; the executable is compiled from the versioned source.
Your laptop/HDMI preference survives updates. Existing Windows installation,
license, disk, firmware variables, TPM and signed drivers remain prerequisites.

Live helper update passed without restarting Windows: the exact legacy watcher
was retired, one new watcher started and the managed version recorded. The first
attempt correctly refused a duplicate when Task Scheduler left the old child;
the migration now handles that known legacy version and newer versions use a
cooperative stop event. Both ordinary output shortcuts are user-confirmed.

Audio now uses SPICE/HDA, not the failed emulated USB audio device. The next real
Gaming launch logged SPICE and an active stereo stream to Linux's analog output.
No numeric latency or sound-quality benchmark is claimed.

The user's later HDMI-unplug/shutdown retained GNOME339908 and passed CUDA with
NVIDIA suspended, but the strict layout guard falsely classified the absent
monitor as failure. The new narrow rule accepts only missing NVIDIA HDMI with
the same session and all remaining displays active, Intel panel primary. Its
actual live validation returned restored=true/changed=false; no stale layout
was applied. The recorded stopped state was corrected after this verification.
59 Windows/controller/sync/display tests pass. No new automatic VM cycle/reboot.
Physical guest HDMI-unplug fallback still needs user confirmation; the latest
guest was closed before an unchanged-version reconciliation could be checked.

## Latest result — 2026-09-12 evening, generation155

The later lifecycle repair supersedes the failures below. Same GNOME324023 with
mapped Mutterw1krysf0wmi8mlm26cs0i5146hw9f6nm survived two physical Gaming return
cycles; saved dual-display layout and actual host CUDA recovered both times.
User subsequently reports manual tests work apart from USB and HDMI selection.
Their later Gaming exit18:06:53 also logged CUDA passed and GPU suspended with
HDMI inactive. These are not numeric gaming latency/FPS measurements.

TI-Nspire is now automatic in both modes, restricted to USB0451:e022 with no
stale host address. The running Light guest detected it OK/problem0 and the user
confirmed it appeared in the app. Physical reconnect is not yet separately tested.
28 controller tests passed; no further automated VM test cycle was run.

Normal worktree precision output reproduces activated/saved/default generation155,
closurec2kdd4hj3qbnqfppdydy7s7jksdsxpxc. Switch exited0 without restarting GNOME or
the user's Windows guest.154 retained for recovery. Source remains on isolated
branch/worktree during development. The user subsequently requested integration
into `/etc/nixos` master; use `/etc/nixos#precision` after that merge. The original
three untracked files are preserved and are not imported into the configuration.
Session-test authority/autostart removed; root shell closed. No reboot performed.
Physical Windows HDMI output selection remains unfinished. A nonfatal render-node
hotplug ENODEV warning remains recorded; no desktop crash on the passing cycles.
Mutter is patched/pinned and future upstream updates need compatibility review.

## Historical result — 2026-09-12 16:49 CEST

**Incomplete: the user's actual Gaming cycle exposed a GPU-return crash.**
At16:13:24 GNOME189534 crashed in meta_crtc_kms_assign_extra when NVIDIA DRM
returned after Windows exited0. CUDA passed afterward, but that did not preserve
the desktop. The earlier display-only success below is not full handoff success.

The controller safety update was activated16:45:19 without restarting GNOME or
GDM. Current system is xh1bs21slny2252ijyjj55w5m3di6rsc; saved/booted154 remains
xkga9k4w11g6yzbzp0pgwgsfg7p1c5cw. The declarative Gaming launcher, direct CLI and
privileged prepare command now refuse before display/GPU changes. Windows Light
is unchanged. The temporary local desktop-file override was removed after the
declarative launcher was verified. GNOME192901 and both monitor layouts survived;
PaperWM/indicator ACTIVE, monitors.xml unchanged, real CUDA32-value kernel passed.

New source distinguishes display recovery failure from CUDA success and handles
a guest exiting between the shutdown check and QMP request.43 Windows tests,
17 collector tests,31 maintenance tests and16 GJS guard tests pass. These do not
certify GPU handoff. A new lifecycle Mutter candidate3j76... builds and passes
the isolated headless Intel/no-NVIDIA-context test; disposable Linux virtual-KMS
removal/return tests are ongoing. It is NOT mapped by the real desktop, which
still uses the CPU-only3aqm candidate. No new host logout, reboot or GPU transfer.

One ordinary local sudo authentication used the explicitly supplied credential
only at sudo's terminal input, never in files/config/scripts. Root shell exited
16:49, no maintenance privilege rule was added. Prior helper units are absent,
consumed records remain; no auto-login or one-shot startup service was installed.

## Historical display-only result — 2026-09-12 16:06 CEST

The CPU-copy candidate is now actually loaded and passed physical Linux HDMI
hotplug, one temporary HDMI disable/restore, zero-owner D3cold with HDMI still
plugged but disabled, and real host CUDA both with and without HDMI scanout.
GNOME189534 stayed alive on Intel; PaperWM/indicator remained ACTIVE; original
monitor geometry and monitors.xml were preserved. User confirmed initial HDMI
pixels. Details: [SCANOUT-CPU-SESSION-RESULT.md](SCANOUT-CPU-SESSION-RESULT.md).

Full Windows HDMI handoff is STILL INCOMPLETE: no GPU removal/re-add or VM cycle
was performed in this candidate. Complete Mutter KMS lifecycle and guest display
choice remain outstanding. Zero owners after display disable do not establish
safe unbind/rebind. Keep Gaming closed under this test candidate. The new
candidate is test-activevzw5..., saved/booted generation154 is unchanged.
Temporary root helper and both one-shot timers were removed16:07:20; durable
consumed counters1/0/0 retained. No auto-login/startup service was installed.
The older sections below are historical and superseded by this result.

## Historical pre-CPU-test status

CPU-copy follow-up built and passed isolated policy/handle checks, NOT activated:
[SCANOUT-CPU-CANDIDATE-RESULT.md](SCANOUT-CPU-CANDIDATE-RESULT.md). Cleanup is
verified and host CUDA/suspension works after recovery with HDMI unplugged.
Full physical HDMI handoff remains incomplete; do not repeat the consumed test.

Latest: the15:18 scanout-only session test FAILED on physical HDMI connection.
GNOME aborted in Mesa iris after execbuf ENOMEM; two greeter attempts also
aborted. Approved configuration rollback completed without restarting the
replacement session. Keep HDMI unplugged until the failed mapped compositor
is replaced at a future normal login. See [SCANOUT-SESSION-RESULT.md](SCANOUT-SESSION-RESULT.md).
The prior evidence below is historical, not proof of current full handoff.

Job: `precision-gpu-handoff-20260911`. Branch: `codex/precision-gpu-vm-handoff-20260911` in `/home/lexyo/worktrees/precision-gpu-vm-handoff`.

**Status: INCOMPLETE.** The later Linux-HDMI handoff test triggered a GNOME crash;
the current patched Intel-primary session has driven both screens, but retains
NVIDIA handles that block Gaming. HDMI is currently unplugged; only eDP is active.
Windows is stopped. The latest component
update succeeded14:23:49 and its live CUDA, indicator suspension/holder,
monitor-restoration and Light clean-shutdown checks passed. See
[COMPONENT-UPDATE-RESULT.md](COMPONENT-UPDATE-RESULT.md) for the actual current
statec4d4..., which differs from saved/booted generation154. The earlier154
Gaming successes used NVIDIA display isolation, which prevented Linux HDMI.
Do not activate the normal unpatched worktree output as a completed solution.

New source progress: [SCANOUT-CANDIDATE-RESULT.md](SCANOUT-CANDIDATE-RESULT.md).
An isolated live reproduction confirms NVIDIA EGL handles survive normal
cleanup. The new opt-in scanout-only candidate builds and passes three isolated
compositor comparisons, avoiding NVIDIA EGL handles and its lease global while
retaining Intel rendering. Full NixOS candidate4dmb78... also builds. It is NOT
activated; physical HDMI release/performance and complete GPU removal/re-add
remain unimplemented/unvalidated. Currentc4d4... and GNOME77549/ms7m1 are unchanged.
No new session test, authority, autostart or reboot has been armed.

## Current HDMI investigation (2026-09-12, through approved13:24 login)

- The agent's temporary display-layout request triggered Mutter50.1 SIGSEGV. Offline GDB examination of the retained core confirms `rdi=0` at `meta_monitor_is_for_lease+7`, called by lease resource updates. Newly added NVIDIA outputs lacked corresponding monitors. This is not a successful handoff test.
- With a new explicit one-session grant and fresh local sudo authentication, the scoped helper activated the patched test system once. Normal logout at13:24:38 and one GDM restart completed; automatic exact-conversation continuation succeeded after normal login. New GNOME77549 actually maps the patched Mutter library. Journal confirms Intel card1 primary; both original monitor positions/modes and monitors.xml hash are unchanged. PaperWM and the supplied indicator report ACTIVE. This is fresh-session validation, NOT full hot-add/handoff validation.
- The local Mutter patch checks the null monitor and reloads the catalogue after successful GPU addition. It is active only in the explicit session-test configuration, not the normal Precision output. It does not implement full GPU detach/re-add. Xwayland's retained NVIDIA DRM handle remains a separate obstacle; final zero-owner refusal is mandatory. No owner was killed/exempted and Windows remains stopped.
- The installed bridge checks both display catalogues, serials and identities; live stale-serial/wrong-owner requests were refused before application. The new session reused the old owner`:1.7` and serial1, revealing that owner alone does not protect across bus restarts. Source now additionally checks bus instance ID and shell PID.16 GJS/32 controller-display/17 indicator/10 helper tests pass; its offline package and read-only/negative live checks passed, but this additional correction is NOT activated. No actual display-layout application occurred during the post-login checks.
- Current live system: `/nix/store/xl5mdhz28nwnr46ydj85cdyb77d77aqq-nixos-system-precision7560-26.05.20260611.a037402`. Saved/booted generation154 remains unchanged. No further activation or reboot allowance remains. Do not restore old snapshots or run Gaming under this host-HDMI configuration.
- Cleanup VERIFIED13:30:20: the new root helper finished, its transient unit/runtime/socket disappeared, and the exact one-shot autostart was deleted. The older stale activation socket was also removed. No armed marker/logout timer, temporary sudoers, autologin, linger or maintenance sleep inhibitor remains. Existing permanent GPU helper permissions and evidence logs were preserved; generic sudo requires a password. The current unprivileged Kitty/Codex application scope is not another startup mechanism.
- Still outstanding: seamless safe Linux HDMI GPU release/return, internal/external
  destination selection and live repeated cycles under the HDMI configuration.
  The earlier draft selector/`DisplaySwitch /external` implementation was
  withdrawn during activation review: its Zenity rows were malformed, QGA runs
  outside the Windows console session, no physical target was verified, and
  its blocking retry loop delayed viewer-close shutdown. Its unit tests and
  successful build did not establish a working external mode. The unpatched
  normal-output candidate907y5... was also rejected for this live update:
  it changes GNOME/GDM dependencies and drops the tested Mutter patch.

Detailed live evidence and limitations: [SESSION-TEST-RESULT.md](SESSION-TEST-RESULT.md).
The following sections are historical evidence, not current-state assertions.

## Historical generation154 results (2026-09-12, before HDMI changes)

Current and booted system both match `/nix/store/xkga9k4w11g6yzbzp0pgwgsfg7p1c5cw-nixos-system-precision7560-26.05.20260611.a037402`; boot ID `ec89b2a7-35c8-44cc-8ee9-0ccb1419e153`. IOMMU, kvmfr, Intel GNOME, PaperWM and the actual visible indicator were verified. An offline Nix build returned that exact system path; only pre-existing VSCode configuration warnings remain.

- Three Gaming viewer-close cycles ended with QEMU exit0, an actual Linux CUDA kernel verifying32 values, and both NVIDIA functions runtime-suspended. GPU return completed at11:24:38,11:36:14 and11:39:32 CEST. No guest was forced off.
- Windows CUDA passed repeatedly. Windows reports RTX A4000 Laptop GPU, NVIDIA580.92, problem0. The Linux driver remains595.71.05 with finegrained runtime power management.
- A real black-screen regression was reproduced despite healthy CUDA: the Windows sign-in screen was on primary QXL and Looking Glass was secondary. A bounded Windows startup task now applies the existing Looking Glass-only layout without saving it or changing authentication. Two subsequent Gaming boots ran this task automatically with result0, including Gaming after Light. Actual Looking Glass frames and the user's confirmation verified visible sign-in, then desktop/rendering. Early boot can still briefly display a black frame while Windows initializes.
- The new task skipped Light with an explicit `Light / no NVIDIA: no display changes` log. Its normal Windows desktop was captured; Linux CUDA ran concurrently, then NVIDIA suspended while Light stayed open. Light closed cleanly before the final Gaming launch.
- A live CUDA holder caused the permanent prepare helper to refuse with its readable process name and PID. The process exited normally; no work was killed.10 controller and17 indicator offline regressions also passed.
- The user's actual FurMark2 GL run rendered on NVIDIA through Looking Glass at1920x1080. Its logs identify `GL_RENDERER: NVIDIA RTX A4000 Laptop GPU/PCIe/SSE2`; the frontend created an OpenGL4.6 NVIDIA context and the GL stress scene an OpenGL3.2 NVIDIA context. A live frame showed the rendered scene and100% NVIDIA utilization. This is real graphics evidence, not merely successful driver configuration or CUDA. No completed benchmark score, game FPS guarantee or input-to-photon latency is claimed.
- The visible panel returned to Intel after shutdown and showed NVIDIA / VM while Gaming ran. Eight pre-launch passive samples remained suspended with monitoring active. PaperWM remained ACTIVE; the desktop was not restarted or reconfigured.

See [GENERATION-154-VALIDATION.md](GENERATION-154-VALIDATION.md) for timestamps and evidence files. Linux is declarative Nix configuration; the Windows drivers and startup display repair are scripted guest provisioning, not a purely Nix-managed Windows installation. [WINDOWS-DISPLAY-FIX.md](WINDOWS-DISPLAY-FIX.md) documents the source, idempotent installer, restricted permissions, finite timeout and removal method.

## Earlier live results retained as historical evidence

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

## Resolved recovery-boot limitation

Earlier boot `04d8b127-6d38-43d6-ae8a-4c7ea42943d4` used recovery generation145, without active IOMMU/kvmfr or the new GNOME extension session. Switching alone could not resolve those boot-time prerequisites. The user subsequently booted the normal clean generation154; the limitation is now resolved and live Gaming tests passed. The agent did not exceed its three-reboot counter or restore cleaned temporary access.

The permanent configuration leaves NVIDIA with Linux by default, retains finegrained power management and auto runtime policy, and sets the bounded Gaming memlock allowance needed for16GiB guest RAM. A failed first launch exposed the original8MiB memlock limit; it failed before Windows boot, automatically restored Linux CUDA/suspension, and was corrected before the two successful Gaming cycles.

## Historical cleanup verification (before the later HDMI test)

Clean generation154 is active and booted. Earlier finalization exited0; detailed original cleanup evidence is saved in `state/cleanup-verification.json` and `state/finalize.log`. Current checks again confirmed ordinary `sudo -n true` denied, `Linger=no`, no maintenance autostart, and inactive continuation:

- Temporary bootstrap import, GDM auto-login configuration, linger, root sleep inhibitor, maintenance sudo/helper, dashboard autostart and continuation links are removed. Ordinary noninteractive sudo is denied. Only the permanent inspect/prepare/release helper permissions remain.
- Continuation is disabled, unlinked and now inactive. Its armed marker is absent. No automatic agent restart is left installed after maintenance.
- The temporary EFI default145 override is removed, so normal boot selection follows the clean generation. Recovery143/144/145 were retained. Selecting an old bootstrap recovery generation also restores its historical maintenance configuration; it is not the cleaned daily configuration.
- The earlier live GNOME and Light VM survived the cleanup operation. On154, PaperWM and the indicator are ACTIVE. No forced session unlock, display-manager restart or password-policy changes were made.
- NVIDIA currently belongs to the intentionally running Gaming VM. Between each completed cycle both functions returned to Linux and suspended with `power/control=auto`. Authenticated tool/network requests continued to work.
- Windows and encrypted-disk identities, cold backups and existing credentials are preserved. Viewer-close tests requested normal guest shutdown, never forced it. The permanent Windows display-startup task is a functional component, not maintenance auto-login or general unattended-agent authority.

The interactive observer proposed extending the budget to four based on a broad request to finish without prompts. This dedicated continuation retained the explicit three-reboot constraint in its latest direct user instruction. It neither increased the counter budget nor reacquired temporary privileges after cleanup.

## Evidence and later use

See [WINDOWS-GUIDE.md](../WINDOWS-GUIDE.md) for launchers, clean shutdown, USB selection and rebuild instructions. `/etc/nixos` master and its original three untracked files remain untouched. No remote push or merge was performed.

Evidence remains in `/home/lexyo/.local/state/precision-gpu-maintenance/`: `live-tests.jsonl`, `gaming-second-return-journal.txt`, `gaming-second-audit.txt`, `idd-hardware-refresh.txt`, `gaming-lg-first.png`, `calculator-guest-audit.txt`, `calculator-current-audit.txt`, `ti-diagnostic.txt`, the panel captures and cold `windows-backup/`.

Primary implementation references: [SPICE manual USB selection](https://www.spice-space.org/usbredir.html), [QEMU USB devices](https://www.qemu.org/docs/master/system/devices/usb.html), and the pinned Looking Glass source documentation. The result claims above are based on live local evidence and user confirmation.
