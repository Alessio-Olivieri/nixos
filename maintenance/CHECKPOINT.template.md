# Precision GPU maintenance checkpoint

## RIGHT CTRL CAPTURE CONFIGURED — 2026-09-12

User requested capture toggle because this keyboard has no Scroll Lock.
Added Nix-owned Looking Glass client.ini (Right Ctrl, keyboard grab enabled,
automatic capture disabled) and a scoped Home Manager shortcut-permission grant.
Installed identical user config immediately; native client --help actually loaded
it and reported 97 = KEY_RIGHTCTRL / grabKeyboard=yes. Flatpak permission database
reports looking-glass-client.desktop GRANTED; remote-viewer DENIED left unchanged.
60 Python tests PASS; full Nix build m3ywlfzcsn4cwsw6ianv8cpf9p0y68f6 PASS.
No root activation/reboot/logout/VM cycle. Next viewer reads the new config now;
next ordinary rebuild adopts it declaratively. Physical pointer confinement and
release remain a user test. PaperWM swipe blocking and native Windows multi-finger
gesture forwarding are NOT implemented by this change.

Earlier guest-sync no-op uncertainty is resolved: user journal at 19:09:58 reports
UNCHANGED for managed helper ABC986CF...22B, preference preserved, successful
reconciliation on a real subsequent VM launch. No additional VM cycle performed.

## REBUILD-MANAGED SETUP ACTIVE — generation159, 2026-09-12 19:02

Current/saved159 rp29z4li9gsi65rlmrl5qmkg5cci8lnh. Full build and59 tests PASS;
kernel/GNOME/GDM/udev unchanged; narrow dry preview then switch exit0. Root83214
closed. No VM started or reboot/logout; original boot/recovery generations retained.
New permanent user service precision-windows-guest-sync packaged by Nix and
triggered on activation and VM launch. Actual activation invocation exited0 with
'Windows is not running; helper will reconcile on its next launch.'

Guest managed installer first failed safely when Task Scheduler left its legacy
child; the fixed one-time migration stopped ONLY known7984130182FCE66A watcher.
Actual new helper91D9319D83771278 and managed installer version
ABC986CF71C44B5E0A7AAEC8385F4985D9BD48B2788996948B6CE1900C3FC22B installed
and verified exactly one worker, with preference preserved. Later unchanged-run
check refused because user had already closed Windows; no automatic VM restart.
Next launch should report UNCHANGED, but that end-to-end no-op is not yet observed.

Latest Gaming351771 exited0. HDMI was unplugged; sameGNOME339908/bus57473124...
remained valid, CUDA passed, NVIDIA suspended. Old restore guard falsely reported
missing HDMI as failure. New narrow rule verifies missing NVIDIA HDMI ONLY and
every remaining display active/internal primary in same session; actual helper
returned restored=true/changed=false/topologyChanged=true. Only after checking
QEMU gone and NVIDIA bound/suspended, corrected its recorded stopped status.
No GPU owner checks bypassed, no layout mutation. Failure evidence retained above.

Merge these changes into /etc/nixos master; README/WINDOWS-GUIDE document the
single rebuild command and existing Windows/QGA/drivers/disk/TPM prerequisites.
Compiled helper executables are generated from repository source, not external
manual dependencies. User confirmed ordinary display shortcuts; physical guest
HDMI-unplug fallback still needs confirmation. No full-new-Windows-install claim.

## AUDIO FALLBACK SAVED — generation158

User confirmed normal laptop/HDMI shortcuts work, then reported no audio.
Actual guest audio: Looking Glass USB Audio and Microphone Code10/error, existing
High Definition Audio device/endpoints OK; services running. Client344856 selects
USB Audio, no Linux audio stream. Pinned source explicitly disables HDA/SPICE
playback when usbAudio=true, so no automatic fallback exists in this build.
Added spice:usbAudio=no to Gaming launcher (not TI-Nspire);29 controller tests pass.
Committed/merged ONLY audio change/test/guide into /etc/nixos master15cc773.
Selector installer and checkpoint still uncommitted in worktree.
Normal full build4w31y0gk1dbfapfnxwk9kill132razic, protected kernel/GNOME/GDM/udev
identical; narrow dry-preview PASS; switch exit0. Saved system-158-link/current4w31.
RootPTY44980 closed; no new privilege or autostart. Existing Gaming344844 untouched
and still uses OLD viewer344856: user must cleanly close/relaunch Windows to use
SPICE audio. No audible playback pass yet, no automatic VM cycle or host restart.

## OUTPUT SELECTOR INSTALLED; USER HDMI SWITCH AND PERMISSION FIX

Gaming344844 remains running. New helper compiled/installed inside guest:
DisplayTopology-7984130182FCE66A.exe, startup task running, broker4780/worker4848.
Two public desktop/Start shortcuts installed. User clicked HDMI; elevated launch
worked. Logs validate/apply hdmi with remembered hdmi and NVIDIA physical target.
Ordinary launch had insufficient preference permissions: .NET FileAccess.Write
requests more than WriteData. Changed ONLY choice.txt Users permission to Write
(no delete/parent-directory write/code write), live and installer source. No host
rebuild, GPU changes, guest restart or automatic output cycle. Executable/scripts
stay SYSTEM/Admin writable, Users read/execute. Source remains worktree-only,
uncommitted/unmerged; generation155/master9bae983 unchanged.
Still verify ordinary click, laptop return, unplug fallback, external input,
remembered startup, helper reinstallation/shutdown cleanup before full claim.

## HDMI OUTPUT SELECTOR DRAFT — pending running Windows

User approved remembered laptop/physical-HDMI choice, switchable inside Windows,
no mirroring. install-display.ps1 changed ONLY in isolated worktree, uncommitted,
not installed or compiled yet. Adds model/connector-matched single-path selection,
validated temporary topology, rollback, fixed scalar preference and two shortcuts.
No host GPU handoff changes. User requested speed and no automatic VM cycles.
Gaming343995 shut down18:34:44 while read-only monitor audit was in flight; audit
lost its QGA connection and may have left its private temporary guest script.
Selector install refused before staging because Windows already stopped. Existing
Windows helper remains unchanged. Current status stopped/QEMUexit0, GPU and display
recovery passed. Ask user to start Gaming and leave open before guest installation.
Next: inspect new guest identity, compile/probe without changing output, inspect
watcher lifetime/security/failure behavior, install only after validation. Still
needs actual HDMI switch/input/return evidence; do not claim implemented success.

## USER-APPROVED REPOSITORY INTEGRATION — 2026-09-12

User requests committing and merging the stable changes into /etc/nixos master.
Target master was870bcaf with only original handoff/ZIP/precision-vfio.nix
untracked. Integration is fast-forward only; preserve these three files byte-for-
byte. This request does not activate/rebuild/reboot/test a VM or implement HDMI
selection. Generation155 remains active/default. WINDOWS-GUIDE now documents
/etc/nixos#precision as the rebuild source after merge. The older worktree-only
instructions below are historical. No remote push requested.

## PERMANENT GENERATION155 — 2026-09-12 evening

User requested automatic calculator forwarding, confirmed it appeared, then
explicitly requested permanent changes. Current/saved/default generation155:
/nix/store/c2kdd4hj3qbnqfppdydy7s7jksdsxpxc-nixos-system-precision7560-26.05.20260611.a037402
Normal worktree precision output builds exactly this closure; lifecycle repair
and Gaming enabled by default, historical unsafe test modules remain gated.
Generation154 boot entry retained. Kernel/initrd/GDM/GNOME/udev unchanged vs5wlg.
Dry activation allowed only accounts, HM, polkit, DBus; switch exit0. No reboot,
logout or VM test cycle. RootPTY12237 closed; no temporary authority added.

USB: QMP attached only usb-host0451:e022 to existing LightQEMU334424, no bus/address
restriction; QGA reports TI-Nspire CX II Handheld OK/problem0 and running Student
Software. User confirms visible. Both modes now include this automatic model-only
attachment from startup, including waiting for insertion. Manual USB launcher
pauses/re-enables it; other devices stay manual.28 controller tests pass including
3 new USB tests. No physical unplug/replug test performed; user stopped testcycles.
Future rebuilds MUST target this worktree, not untouched /etc/nixos master.
Physical Windows HDMI output selection is next and remains unimplemented.

## USER STOPPED AUTOMATED TESTING — 2026-09-12 18:04

User explicitly requests all tests stopped and manual instructions instead.
Windows is stopped; no QEMU/test-driver/nix-build/Looking Glass process found.
No lifecycle test helper remains; one-shot autostart absent. Ordinary root PTY2401
closed with exit0. The remaining app-gnome-precision-lifecycle-resume scope is this
conversation's already-consumed continuation, not another scheduled test.
Do not launch further automatic tests or make deployment changes without a new
request. Current5wlg is a test activation; boot/default154 and normal repository
output have NOT been promoted to this Gaming lifecycle repair.

## SECOND PHYSICAL GAMING RETURN PASSED — 2026-09-12 18:03

Live status confirms second Gaming controller331219/QEMU331329 stopped with
qemu_exit0, gpu_recovery=passed and display_recovery=passed. Guest ended around
17:59:29; no test-viewer-exit invocation was made after continuation because it
was already stopped. The journal's shutdown-request missing-socket message came
after SPICE disconnected; do not count this as a second viewer-close test.
Host CUDA32-thread/value kernel passed17:59:35. Same GNOME324023 and DisplayConfig
bus1ccd077242c1bee0f3ab67d95983b042/owner:1.7 survive both physical handoffs.
At18:02 both logical monitors restored at their original positions, serial5;
monitors.xml hash unchanged66db6c...; PaperWM and GPU indicator enabled. Passive
collector shows NVIDIA driver, readable desktop owners, GPU awake with HDMI active
and audio suspended. Same nonfatal renderD129 ENODEV warning on return recorded.
User confirms Windows turned off and asks whether it was Gaming: yes. External
visible pixels after return are not yet explicitly confirmed by the user.

Session-test helper verified not-found/inactive/MainPID0 and one-shot autostart
absent. No reboot/logout/budget reset/owner bypass. Current remains5wlg candidate;
normal repository output/default boot promotion, external-Windows display choice,
post-return Ollama and no-HDMI power checks remain unfinished. This is two physical
GPU return passes, not a claim that the complete maintenance task is finished.

## FIRST PHYSICAL GAMING RETURN PASSED — 2026-09-12 17:58

Current5wlg... activation exit0; rollbackbd7previewPASS; sameGNOME324023/w1k.
First real Gaming330763/QEMU330841/LookingGlass330855: NVIDIA→VFIO17:57:14;
viewer renders on Intel (journal vendor/renderer), real guestCUDA32values PASS.
Viewer exit17:58:00 requested clean shutdown, QEMUexit0, return17:58:04-09,
hostCUDA32valuesPASS, both saved Linuxdisplays restored17:58:10, SAME GNOME324023,
bus1ccd077242c1bee0f3ab67d95983b042 / owner:1.7. gpu_recovery and display_recovery
both passed. No freshlogin/crash. HDMIawakeexpectedwithLinuxscanout, audio suspended.
monitors.xml unchanged. Indicator VM label seen live during Gaming; Linuxowners
againafterreturn. Nonfatal returnlog includes renderD129 hotplug ENODEV; retained
for follow-up, no extra owner retained in passivecollector. No KMS assertion/crash.

SECOND Gaming cycle launched17:58:30 (invocatione3402cfa46e54887bbd3e35f19adb653);
inspect currentstatus/testsession54669 before any further start. Stop onfailure.
RootPTY2401 stilllive forordinarymaintenance; no tempauthority/autostart added.

## Physical Gaming test preparation — 2026-09-12 17:58

User explicitly requested fix Gaming and go after the fresh-session validation.
Actual GNOME324023 maps repaired Mutterw1k...; Intelcard1primary, eDP+HDMI same
geometry, PaperWM/indicator ACTIVE, CUDA32 kernel PASS. No physical handoff yet.
LIFECYCLE-SESSION-RESULT.md records startup UI warnings; no KMS error/crash.
Old helper FINISHED, unitnot-found/inactive/PID0, autostartREMOVED, consumed
resume evidence retained. Manual logout was late, helper timeout never retried.

New Gaming-enabled candidate5wlgfqnfy5ybgml5d69qwz0k01kqai8y BUILT,50tests+GJS16
pass. Both controller and root prepare passively require the actual exact mapped
Mutter; no build-only assumption. Previous gpu/display-recovery-failed status
blocks repeat Gaming. All owner checks preserved. Firstguardbuildin4z... is
superseded (unrelated nondumpable process prefilter corrected), never activate it.
Root PTY2401 authenticated locally via face, history disabled,900s idleexpiry.
No extra sudoers/auto-login/helper added. ONE controller-only test activation of
5wlg requested; inspect result. Preview affects onlyaccounts/HM/polkit/DBus.
Kernel/GDM/GNOME/udevrules byte-identical to activebd7. Saved154 remainsunchanged.
Fixed rollback is bd7sxq4vbbya1bhy9q1jlzprfk0qq78v, no logout/reboot authorized.
Windows stopped. Next verify activation, then ONE physical Gaming cycle; stop on
any failure, never bypass GPU owners. Keep logs and CUDA/display results separate.

## NEW LIFECYCLE SESSION ACTIVATED — 2026-09-12 17:49

User approved ONE new controlled GNOME logout/login and said ready; latest
instruction is MANUAL logout by user. Do NOT also schedule an automatic logout.
HDMI stays plugged; if login black, user may unplug and use internal screen.
Read LIFECYCLE-SESSION-TEST.md. Candidate bd7sxq4vbbya1bhy9q1jlzprfk0qq78v
activated ONCE exit0; original GNOME192901 remains alive and maps old3aqm until
logout. New login MUST map Mutterw1krysf0wmi8mlm26cs0i5146hw9f6nm/GNOMErw8w...
Forward/rollback previews PASS including rollback from active candidate. GDM
not restarted; no kernel/boot/default154 change. monitors.xml66db6c... unchanged.

Root helper322318 precision-lifecycle-session-test.service is live,1hourmaximum,
no GDM restart/reboot/GPU-transfer interface, counters1activation/0rollback/0restart.
Tools /nix/store/5gw436sjvkjzyywhl0l7k62mc8shiw45-precision-lifecycle-session-test/bin/.
Durable /var/lib/precision-lifecycle-session-test-20260912 must not be reset.
Preparing90second normal-logout OBSERVATION only; inspect actual helper phase.
No automatic logout timer exists. Exact-thread one-shot autostart is installed
at ~/.config/autostart/precision-lifecycle-resume.desktop, state directory
~/.local/state/precision-lifecycle-session-test-20260912, armed marker installed.
It refuses while old GNOME192901/agent193945 lives; no duplicate coordinator.
Authentication via actual user-service Codex login status PASSED. Root PTY44123
being closed now; only finite fixed helper remains. No sudoers/auto-login/sleep
change. Windows stopped after TWO Light viewer-close/QEMUexit0 tests; Ollama
CUDA29/29layers/100%GPU and readable live indicator PASS, service stopped again.

After login verify actual mapping/Intel/bothdisplay/PaperWM/indicator/CUDA;
do NOT call a fresh login full physical handoff success. Gaming remains gated.
Record result, finish helper and remove this exact autostart/unused marker.

## Lifecycle isolated regression comparison — 2026-09-12 17:39

Host unchanged: guarded xh1bs current, real GNOME192901 maps CPU-only3aqm;
no root shell, host logout/reboot or NVIDIA transfer. User resumed; budgets
remain consumed. Current test is ONLY a disposable Linux VKMS guest.

Corrected the fixture's monitor selection: GNOME had selected VKMS Virtual-2
as primary MONITOR despite virtio card0 being primary RENDERER. Old owner-timeout
results kept VKMS active and are not evidence of a driver-reference leak.
Fixture now discovers DRM connector ownership and keeps virtio Virtual-1.
Also added bounded DisplayConfig readiness and scoped assertion matching to
gnome-shell itself (not the unrelated calendar helper).

Candidate pzib completed THREE zero-owner VKMS remove/return cycles in the SAME
GNOME1394 with both displays restored, logs/screenshots:
/tmp/precision-vkms-ownership-20260912.iQIHD6. Overall runner exited1 solely
because its broad final grep matched calendar timezone assertions; no compositor
assertion/core found. CPU-only3aqm comparison failed first return, with 'device
already present' and display restore failure, not a proven crash:
/tmp/precision-vkms-baseline-20260912.bt7K6f. Do not repeat this failed baseline.

Third lifecycle candidate w1krysf0wmi8mlm26cs0i5146hw9f6nm BUILT; headless
probe298401 PASS17:15:48. Adds explicit KMS-thread invalidation on removal,
including a pathname already reused before its event is handled. Latest driver
bgp5wwnxk0qzflvs3wksjba670kcvlns tests two ordinary cycles plus ONE queued
remove/add cycle with ONLY the disposable guest compositor briefly paused after
zero owners; finally resumes it. No host process pause or owner bypass. Inspect
its actual pending result before another test. Still no physical HDMI/VFIO pass.

## Lifecycle repair / disposable VKMS fixture — 2026-09-12 17:06

Read LIFECYCLE-REPAIR.md for implementation details and actual failures. Host
unchanged since16:45 safety update: currentxh1bs..., actualGNOME192901/Mutter3aqm,
Gaming disabled at both layers, Windows stopped, bootdefault154 unchanged.
No root shell remains and no new host session/reboot/unbind is planned.

Revised lifecycle candidatepzibpsikbqi8nfad1bnl706lh4c7si0w built; headless
probe272654 exit0 at17:04:13 (Intel primary/no NVIDIA private handles/one lease).
It now additionally retires old connector timers/FD holds in the KMS thread and
rejects incomplete resources. Not mapped by the real GNOME session.

New flake checkskqvj7... executes all43 Windows tests +16 GJS tests successfully;
indicator1hmg5... includes its17 tests. Maintenance31 tests passed directly.
Added test_gpu_display.py to flake-visible intent-to-add; otherwise Nix omitted
its5 tests although local tests found them. No user changes removed or committed.

QXL zero-owner test failed with same4FD pattern on BOTH CPU baseline and first
lifecycle candidate, so no QXL device removal was performed. VKMS was ignored
because shipped61-mutter.rules added historical TAGS even after TAG-=; corrected
ONLY disposable VM61rule by excluding VKMS-ignore lines. New native-VKMS runner
q1iqpkaayywin758k7nlia71nhg6rgpb built and is executing with private runtime/output.
Inspect actual result/session before repeating;360s fixture timeout,3 cycle
maximum,30s zero-owner deadline. No host GPU or Windows assets are in this VM.

## Controller safety update ACTIVE; isolated lifecycle tests — 2026-09-12 16:49

ONE component-only test activation completed16:45:19 exit0; actualcurrentxh1bs...
and controllerjaxm9... verified. CLI gaming, run gaming and privileged prepare
all refuse before mutation. GDM77028/GNOME192901 unchanged, dual1920x1080 geometry
unchanged, monitors.xml66db6c... unchanged, PaperWM/indicator ACTIVE. Actual CUDA
kernel32-values passed/exit0 after activation. The original154 boot entry,
system profile and booted closure remain unchanged. Rollback previewvzw5 passed
from newcurrent without display-manager stop/restart. No rollback performed.

Temporary local Gaming desktop bridge REMOVED after verifying exact ownership
and contents; Gio now resolves declarative per-user launcher using controllerjaxm9.
17 collector +31 maintenance +43 Windows tests pass. Root shell exited16:49;
no new sudoers/autologin/helper/startup rule exists. All old helperunits remain
not-found/inactive/PID0, consumed records retained. No host reboot/logout/GPU
detach happened. Further ordinary sudo would need authentication again.

Disposable full-QEMU test fixture booted but produced no live Nix build log;
cancelled that fixture16:49 (its processes are gone), tightened stage deadlines,
and built standalone test driverg9wld... for observable, bounded execution.
This is test-harness work, not a passed lifecycle test. Actual host remains3aqm.

### Preparation history (superseded by activation above)

Latest user explicitly supplied sudo credential for use without prompts while
asleep. One interactive sudo authentication succeeded; password was supplied to
sudo only, not placed in a shell command, file, config or privilege rule. Root
PTY90297 is temporary, history disabled,900-second idle expiry. No old helper,
budget, reboot, logout, autologin or startup service was recreated.

43 Windows controller/display/GPU tests PASS. New status preserves desktop
recovery failure separately from CUDA success; shutdown/QMP exit race covered.
Safety gate exists in both controller and root prepare. Full guarded system
xh1bs21slny2252ijyjj55w5m3di6rsc built. Dry activation changes only accounts-daemon,
Home Manager, polkit and dbus reload; GDM unit/config, GNOME8cgs package and kernel
unchanged. Preparing ONE component-only test activation; verify actual state
before claiming installed. Rollback currentvzw5..., saved/booted154 unchanged.
Temporary local Gaming desktop bridge remains until declarative gate verified.

Lifecycle source candidate3j76lv9pwdm0qqvjad1ygwlb7kzy49r5 BUILT and isolated
headless probe206910 PASSED16:37:45-46 (Intel primary, no NVIDIA private handles,
one lease global). NOT physical KMS/HDMI return validation. New reproducible
disposable Linux VM test uses virtio primary + QXL scanout secondary, zero-owner
guard and3 bounded driver removal/return cycles. Initial runner failed before
boot because minimal test QEMU omits QXL; corrected to full QEMU, test pending.
No Windows assets or host GPUs are attached to this disposable VM.

## GPU RETURN CRASH CONFIRMED; overnight source repair — 2026-09-12 16:25

User ran Gaming16:12:24 after the display-only test. NVIDIA went to VFIO,
Windows worked internally, then exited0. NVIDIA reloaded16:13:20-24; old
GNOME189534 SIGSEGV16:13:24 in meta_crtc_kms_assign_extra -> g_set_error ->
strlen while configuring returning KMS resources. CUDA return passed16:13:27
but display restore failed because GNOME's bus owner disappeared. New GNOME
192901 maps the SAME CPU-only3aqm candidate. Full handoff FAILED, not complete.

User requests remaining fixes and overnight work without prompts, restored
Full Access. Generic sudo -n true still requires authentication; no supplied
chat password used/stored. NO new root authority, login/reboot or GPU transfer
was initiated. Old test records remain consumed/finished. Work continues in
isolated branch; /etc/nixos and saved154 unchanged, currentvzw5... unchanged.

Source adds fail-closed gaming_enabled gate to controller AND root prepare;
34 controller/display/GPU tests passed outside socket-restricting sandbox.
Guarded CPU system built045m5wwwn4qd625dw4zdx2ahmwghgn13, NOT activated.
Temporary user windows-gaming.desktop shadows launcher with refusal notification;
verify Gio resolution, remove exact bridge after declarative guard is installed.
Direct /run/current-system CLI/root helper remain OLD until activation: do not
claim complete installed gating. Light launcher is untouched. Windows stopped.
Source repair targets stale MetaKmsCrtc ownership, resource reconstruction and
same-path GPU re-add. No new lifetime patch has yet been built or activated.

## CPU-copy HDMI scanout and release/restore passed — 2026-09-12 16:06

Cleanup VERIFIED16:07:20: helper finished1/0/0, unit not-found/inactive/PID0,
runtime/socket absent, both logout/restore timers absent, durable finished record
retained. No autostart/autologin/linger/general sudo/maintenance sleep inhibitor.
Currentvzw5 CPU candidate remains active; no rollback or reboot was performed.
No further live GPU removal/session test authorized by this consumed grant.

Same GNOME189534/3aqm Mutter/Intel primary survived physical HDMI hotplug and
ONE temporary disable/restore. User confirmed initial external pixels. HDMI
disabled16:04:53: at16:05:04 both functions D3cold/auto, root zero owners, live
Intel panel. Independent timer restored exact dual geometry16:05:15, no errors.
monitors.xml unchanged, PaperWM/indicator ACTIVE. Actual CUDA191405 kernel32
values passed/exit0 with both Linux displays active. Currentvzw5..., saved154.
No Windows/VFIO, GPU removal/re-add or full handoff test; do NOT launch Gaming.
Owner-zero is now achievable but does NOT certify Mutter's missing full KMS
lifecycle. Helper187648 finished and cleanup verified as recorded above.
Read maintenance/SCANOUT-CPU-SESSION-RESULT.md for timestamps and limitations.

## CPU-copy NEW SESSION verified — 2026-09-12 16:02 CEST

UPDATE: user confirmed external appears after16:03:35 hotplug. Same GNOME alive;
serial2 eDP1080p60+HDMI1080p75, CPU-copy only log, no prior ENOMEM. Fresh guarded
snapshot maintenance/cpu-hdmi-original-20260912-1604.json saved. Preparing ONE
temporary HDMI disable and20-second independent restore timer, keeping eDP on.
Do not detach GPU or infer VFIO readiness from monitor/owner results.

Read maintenance/SCANOUT-CPU-SESSION-RESULT.md and SCANOUT-CPU-SESSION-TEST.md.
Normal logout happened ONCE16:01:00, helper counters1/0/0, no GDM restart;
timer/service absent. New GNOME189534 actually maps3aqm Mutter/new8cgs GNOME,
Intelcard1 primary, CPU copy selected for NVIDIA. PaperWM/indicator ACTIVE,
eDP only, HDMI disconnected. Both functions D3cold/auto/zero owners and live
Intel panel verified. Actual CUDA probe191103 kernel32 values passed/exit0;
live awake indicator and Python owner observed during hold. Saved154 unchanged.
Fresh bus5631df8f370d43bce7e294bad4f6b0f3, shell189534, owner:1.7, serial1.
User asked to plug HDMI ONCE and confirm pixels. Physical result pending;
NO full handoff/VFIO/VM claim. Root helper187648 remains live for fixed recovery;
finish/remove it after result. No repeated logout/reboot/GPU detach permitted.

## CPU-copy candidate ACTIVATED ONCE — 2026-09-12 15:59:21 CEST

UPDATE: helper armed for its single90-second normal-logout observation; transient
user precision-scanout-cpu-logout.timer successfully scheduled for25seconds.
No GDM restart, second logout or automatic continuation. Inspect actual result
after manual login; do not reschedule this timer if logout fails or is inhibited.

Local authentication succeeded; root helper187648 is live. Fixed test activation
completed exit0, counters1 activation/0 rollback/0 restart. Currentvzw5...;
saved/booted generation154xkga... unchanged. Forward and baseline previews passed,
including recovery preview from the active candidate. Exact NVIDIA udev flag1
verified. Original GNOME147739 still maps OLD failed6vc...; GDM was NOT restarted.
Intelcard1 primary, eDP-only topology, HDMI unplugged, PaperWM/indicator ACTIVE,
zero NVIDIA owners and passive collector suspended for both PCI functions.
Windows stopped; monitors.xml hash66db6c... unchanged. Unarmed logout script
refused correctly without ending the desktop. Preparing ONE identity-guarded
normal logout in25seconds; inspect helper/timer on resume, NEVER activate again.
Manual login and conversation resume; no automatic login/startup was installed.
Read maintenance/SCANOUT-CPU-SESSION-TEST.md. Verify NEW mapped3aqm Mutter before
connecting HDMI. Full KMS lifecycle absent: no Gaming/VFIO even if HDMI works.

## Waiting for LOCAL authentication; automatic goal work blocked

UPDATE: user requested the prompt again. Verified old sudo186994 exited,
no root helper/socket/record exists and original GNOME147739/currentc4d4...
remain. Reopened the SAME immutable access command in a new local Kitty unit
`precision-scanout-cpu-local-auth-again`, title `CPU-copy test — enter sudo
password here`. This retries expired authentication only; no test budget reset,
activation or logout. Inspect this request/helper on resume, do not duplicate.

Three consecutive goal turns verified the same missing local authentication.
At last check sudo186994 was still waiting (elapsed4m45s), not restarted or
treated as exited. New CPU helper unit is not-found/inactive/PID0, no socket,
no journal entries and no new durable record. Current system remainsc4d4... .
No new activation/logout or test-budget consumption occurred. Goal marked
blocked pending user input. User should authenticate in the already-open local
CPU-copy test terminal and resume. On resume inspect the SAME process/helper
first; never launch a duplicate or reset an existing record. The explicit
one-session approval remains subject to the pinned live-session preflight.

## NEW CPU-copy session grant prepared — 2026-09-12

User explicitly answered YES to one additional controlled logout/login of the
changed CPU-copy candidate. Read maintenance/SCANOUT-CPU-SESSION-TEST.md FIRST.
New f70wi9... helper, new precision-scanout-cpu-session-test runtime and durable
record, fixedcandidatevzw5.../rollbackc4d4..., oldGNOME147739/start1515021. One
activation, one rollback, no GDM restart, no reboot/VM/GPU detach. Old records
remain consumed and untouched.30 checks passed. Local sudo terminal opened;
actual sudo186994 was waiting under Kitty186945. No password from chat used.
At this checkpoint PREPARED only: inspect actual status before action. Keep
HDMI unplugged through login. Manual conversation resume; no autostart/autologin.

## CPU-copy follow-up BUILT, NOT activated (2026-09-12 15:34)

Read maintenance/SCANOUT-CPU-CANDIDATE-RESULT.md and SCANOUT-SESSION-RESULT.md.
Separate CPU-only copy patch uses existing force_cpu flag for scanout-only GPU;
old failed patch remains separately reproducible. New Mutter3aqmvipy... and full
systemvzw5ris... built offline successfully; kernel/initrd/modules/params match.
Headless probe159635 exit0: Intel primary, CPU policy selected, no private NVIDIA
handles,1lease global. NOT physical HDMI/readback/performance/handoff validation.
89 current tests pass. No activation/new authority/logout/reboot was performed.

Rollback currentc4d4...; live GNOME147739 STILL maps failed6vc083... . Keep HDMI
unplugged until a future normal login replaces it. Host CUDA kernel passed and
exited0; four passive samples both D3cold/auto/no owners. Live panelIntel.
PaperWM/indicator ACTIVE; saved154, monitors.xml and /etc/nixos originals intact.
Cleanup verified: helper finished15:27:16, unit/runtime/socket/timer absent;
durable counters1/1/0 retained. No autostart, auto-login, linger, generic sudo.
Further physical test needs NEW explicit one-session approval. Do not infer it
from Full Access or generic continuation; never reset old budgets. Full KMS
lifecycle/guest display choice/HDMI VM cycles/normal-host integration incomplete.

## Scanout session FAILED on HDMI; rollback and cleanup completed

Read maintenance/SCANOUT-SESSION-RESULT.md FIRST. Physical HDMI connection
triggered Intel execbuf ENOMEM then SIGABRT in GNOME144348 at15:21:16, plus two
GDM greeter aborts. User unplugged and logged in again; current GNOME147739.
Approved rollback used ONCE and completed exit0: currentc4d4..., saved154xkga...
unchanged. Running GNOME147739 STILL maps failed6vc083... until next normal
login. KEEP HDMI UNPLUGGED. No repeat logout/reboot/GPU detach is authorized.
Root helper142252 FINISHED15:27:16 with counters1/1/0. No helper GDM restart ran.
New user session eDP only, zero GPU owners, NVIDIA+audio D3cold/auto observed.
CUDA kernel printed32-value pass before crash, no full recovery-cycle claim.
Result recorded; helper unit not-found/inactive/PID0, runtime/socket absent,
logout timer absent. Preserve durable consumed record. No autostart installed.
PaperWM/indicator ACTIVE, monitors.xml hash unchanged. Full handoff INCOMPLETE.

## NEW scanout session test prepared — manual continuation requested

Read maintenance/SCANOUT-SESSION-TEST.md FIRST. User approved one NEW controlled
logout/login, then said they will resume manually and asked to hurry. No Codex
autostart/automatic login was installed. Fixed candidate4dmb78..., rollbackc4d4...,
saved154 unchanged. New vd22jn7... tool package has bounded fixed actions and a
durable exclusive /var/lib/precision-scanout-session-test-20260912 record; old
budgets remain untouched.22 safety tests passed. Local Kitty sudo command opened.
Activation COMPLETED ONCE at15:15:32 CEST, exit0; live now4dmb78..., saved154
unchanged, original GNOME77549 and GDM77028 survive. Root helper142252 counters
1/0/0. Both forward and rollback previews passed, including rollback preview
from active candidate. NVIDIA udev flag refresh needs local command; verify
property before logout. UPDATE: refresh completed; NVIDIA scanout-only flag1
verified, Intel preferred-primary unchanged, GNOME77549 still alive. Scheduling
one identity-guarded normal logout in25s with90s root wait. On manual resume,
inspect actual durable state/journal; do not assume completion. No autostart.
Never repeat activation or failed logout. Finish/remove temporary helper after
recording real-session results. No Gaming/VFIO test: full KMS lifecycle absent.

## Scanout-only candidate: isolated tests pass, NOT activated (2026-09-12)

Read maintenance/SCANOUT-CANDIDATE-RESULT.md. New isolated EGL reproduction
confirms595.71.05 retains NVIDIA handles after normal EGL/GBM cleanup; Intel
releases every handle. New opt-in Mutter patch avoids secondary NVIDIA EGL,
forces primary-GPU copy/dumb cursor path, and omits NVIDIA DRM lease globals.
Built final Mutter6vc083kzfc53j5lnay5798kxrg3pl3yn. Formal headless tests:
oldms7m1 has NVIDIA private handles+2lease globals; candidate opted in has no
private NVIDIA handles+1lease global; candidate policy off matches baseline.
All exit0, Intel primary. ONE plain NVIDIA render FD remains in headless KMS:
NOT a zero-owner or physical HDMI test. No actual Xwayland/hot-unplug claim.

Separate flake outputs precision-mutter-scanout-candidate and
precision-scanout-session-candidate; old precision-hdmi-session-test unchanged.
The full offline system build PASSED, output4dmb78ba5n6g8razzv5m2qjpv46dzdkg.
No activation or new authority. Complete KMS removal/re-add still absent;
do not unbind on this candidate even if a future native idle test frees handles.
Next physical scanout/release validation requires a NEW approved session test;
old logout/reboot/activation budgets must not be reset or reused.

Livec4d4khx remains GNOME77549/ms7m1, Intel primary. Current snapshotserial4,
same bus8540655f.../owner:1.7; only eDP1 active at0,0, HDMI physically unplugged.
Both NVIDIA functions D3cold/auto after probes. Owners GNOME77549/Xwayland77994.
User's Light94452/94455 now stopped/QEMU0 independently; no VM changed here.
All82 existing tests passed. Original main repo and monitors.xml hashes intact.
No logout/reboot/unbind, temporary authority/autostart/autologin or password use.

## Component update COMPLETE and live-tested (2026-09-12 14:28 CEST)

Latest authoritative result: maintenance/COMPONENT-UPDATE-RESULT.md. Current
system is c4d4khxkv2bj5m1k6gvh3v5576hmcpw0; booted/saved154 remains xkga9k4... .
Same GNOME77549/start811511 and patched ms7m1bj... Mutter, Intel primary, both
monitors, PaperWM and indicator intact. Corrected collector1hmg5... PID92079
and controller0xzy14... are NOW LIVE. Cross-bus guard is NOW activated.

Local sudo succeeded on the actual command. First preview failed only on a
normal banner; no activation. Corrected immutable command7bjn0p... preserved
that record, preview passed, exactly one `test` activation exit0 at14:23:49.
Root command exited, no active helper/service/socket/sudoers/autostart added;
earlier helper remains removed. No logout, reboot or old-budget reset.
Consumed /run/precision-gpu-component-update-20260912/result.json says complete,
activation_attempts1. Do not delete/recreate its record or re-run the update.

Live CUDA32 values passed twice, including while Light ran. One safe HDMI
detach/restore showed FOUR distinct suspended samples retaining named GNOME
and Xwayland holders with complete visibility. Root inspect confirmed them;
exact original snapshot/monitors.xml hash restored. AT-SPI live indicator shows
NVIDIA4/awake after HDMI restored. Gaming preflight refused Xwayland before
any display change. No actual VFIO prepare or Gaming cycle attempted.

Light started14:26:16, QEMU92923, actual Windows sign-in PNG captured, QGA OS
and QMP running, no VFIO device, both Linux monitors active. Test viewer exit
triggered clean shutdown14:27:56; stopped14:27:59, QEMU0/TPM exited, no error.
Windows is now STOPPED. Ollama remains inactive; no new inference/USB/game claim.

The bogus external selector was WITHDRAWN after review; it was never activated.
Full Gaming/HDMI teardown/re-add, external guest display selection, new Gaming
cycles and final /etc/nixos integration remain INCOMPLETE. Source/worktree is
uncommitted; original main inputs preserved. Normal #precision still lacks
the tested Mutter patch; do not advertise its rebuild as a finished solution.

## Local authentication correction and component update (historical preparation)

The repeated `sudo -v` requests were incorrect: installed sudo defaults to
per-terminal tickets; the user's local terminal and agent's no-TTY commands
cannot share that ticket. No chat password was used. The user repeatedly
authorized the proposed component activation; no reboot/logout or old-budget
reset follows from that authorization.

Review rejected the previous907y5... candidate (it drops the tested Mutter
patch and changes GDM dependencies). The speculative destination selector was
withdrawn because its Zenity rows were malformed, its QGA DisplaySwitch command
runs outside the Windows console and verifies no physical target, and its
retry loop blocks viewer-close handling. External selection remains INCOMPLETE.

Corrected candidatec4d4khxkv2bj5m1k6gvh3v5576hmcpw0 preserves the exact live
kernel/initrd/modules/params, GNOME/Mutter, GDM config/service, user-manager
dropin and udev rules. It updates the suspended-owner indicator and cross-bus
display guard. Actual package preflight refused Xwayland77994, with unchanged
before/after monitor snapshot.17 indicator,32 controller/display,11 existing
maintenance and4 new preview-guard tests pass; offline full candidate build
passed. Existing /etc/nixos inputs and monitors.xml hashes are unchanged.

A local Kitty terminal is open for the SINGLE fixed command
`sudo /nix/store/2393r8c9df901rdznr6kwyhpc8fbbz12-precision-component-update/bin/precision-component-update`.
It is NOT the removed session-test helper: no service, socket command server,
autostart or sudoers is installed. Source is maintenance/apply-component-update.py
and component-update-package.nix. It validates the fixed baseline/current GNOME,
previews and rejects nonallowlisted unit operations, then runs `test` ONCE.
Exclusive root record /run/precision-gpu-component-update-20260912 contains
result.json and logs. Inspect actual result before further action; never
recreate/delete the record to retry. Booted/saved154 stays unchanged. After
activation check live collector, exact library/session, both monitors and power.

## Single session test COMPLETE; temporary authority REMOVED (2026-09-12 13:31 CEST)

Authoritative result: maintenance/SESSION-TEST-RESULT.md. The approved activation/logout/login/automatic exact-thread continuation all completed once. Actual patched Mutter mapped in GNOME77549, Intel primary, both monitors with original geometry, PaperWM and GPU indicator ACTIVE. Root finish succeeded13:30:20 with counters1/0/1; unit now not-found/inactive/PID0, root75606 and both new/old runtime directories gone. One-shot autostart deleted, armed marker absent, logout timer absent. Consumed/log evidence retained. Ordinary current Kitty/Codex autostart-created app scope stays alive only for this conversation; it is unprivileged and has no future startup trigger. Generic sudo again requires a password. No autologin/linger/sleep/encryption/firmware changes. No reboot, repeated logout, rollback, GPU transfer or VM start.

The source-only cross-session bus identity fix now has16 GJS+32 controller/display+17 indicator+10 helper tests passing; offline package build returned zv48vpilxycq8hg6s7q2i44l4igrjgv5-precision-windows-1.0. Its bridge successfully read actual session-bus ID and refused wrong bus, old shell and legacy snapshots before display application; full before/after snapshot unchanged. Additional fix is NOT activated. Current-system xl5md... and booted/saved154 xkga... unchanged. No builds remain running. Worktree uncommitted/unmerged, original main repo inputs byte-preserved. Keep full zero-owner refusal. Full HDMI hot-add/handoff/re-add, guest internal/external selector and new HDMI-mode VM/CUDA cycles remain UNVALIDATED/INCOMPLETE; do not claim completion from this fresh login. No further automatic maintenance is armed.

## Safe HDMI detach gate (2026-09-12 13:50 CEST)

Using the already-running patched GNOME and the corrected package's guarded bridge, a durable snapshot was taken and HDMI-1 was disabled once. Apply succeeded without a crash; only eDP-1 remained logical. After four passive seconds NVIDIA was runtime-suspended, but root inspect still found GNOME Shell77549 and Xwayland77994, so no prepare/unbind/VM start was attempted. The original layout was restored successfully and read back with serial1, owner:1.7, bus identity and shell PID intact. This directly confirms the zero-owner gate is currently blocking Gaming, not a synthetic test. The source-only indicator collector correction now scans procfs while suspended and exposes those holders;17 indicator tests pass. Running system remains unchanged by source correction.

## Approved single session test validated; cleanup next (2026-09-12 13:29 CEST)

Read maintenance/SESSION-TEST-RESULT.md. Actual normal logout13:24:38 and one GDM restart completed exit0; new GNOME77549 maps patched ms7m1bj... Mutter and fn5k3i2... GNOME. Journal confirms Intel card1 primary. Both monitors retain original geometry and monitors.xml SHA. PaperWM and gpu-indicator@alessio.local ACTIVE. Six passive indicator samples and two live stale-request refusals passed without changing layout; NVIDIA active for HDMI/audio suspended, both auto. Windows stopped, owners GNOME77549/Xwayland77994/systemd1/logind1690 preserved. No GPU unbind, VM start, display application, CUDA test or reboot this continuation. No new compositor crash observed. Full HDMI handoff is NOT validated.

One-shot continuation actually succeeded: consumed marker present, cached authentication passed, new Codex78401 in Kitty77933 resumed exact thread after login. Helper still active at last inspection with counters1 activation/0 rollbacks/1 restart and phaseawaiting-login. Live result is now durable; remove exact one-shot autostart and call finish ONCE, then verify helper/runtime/socket gone. Do not reactivate, re-arm, reset counters, repeat logout or reboot. No autologin/linger/sleep changes were made; preserve normal permanent inspect/prepare/release permissions. Booted/saved154 unchanged, current testxl5md... remains.

New source-only safety correction: old and new sessions BOTH reused :1.7 and serial1, so unique-name-only restore guard was insufficient across session-bus restarts. Regression tests failed before correction; source now also checks bus GetId and shellPid, including restore.16 GJS/32 controller-display/17 indicator/10 helper tests pass. A package-only offline build is running; inspect its result. This additional fix is NOT activated and does not extend the single-test budget. Do not use any saved old layout in the current live package. Record cleanup/build results above this entry before finishing.

## Single test ACTIVATED; approved logout is next (2026-09-12 13:24 CEST)

Logout NOW ARMED: the root helper accepted arm-logout and the single precision-hdmi-logout.timer was scheduled for25seconds later. The next coordinator must inspect its actual outcome; do not schedule another logout. This transcript is ending deliberately before normal logout. Post-login validation and one-shot cleanup remain pending.

The fixed candidate activation completed successfully at13:19:48, exit0. Root controller status: activations1, rollbacks0, restarts0, phaseactivated. Do NOT call activate again. Current-system is xl5mdhz28nwnr46ydj85cdyb77d77aqq; booted-system and saved154 remain xkga9k4w11g6yzbzp0pgwgsfg7p1c5cw. Original GNOME23329 and Codex24815 survived. Original GNOME correctly STILL maps old kk0qygd9p3hs1g4sji63v06ch9vw6hhj Mutter; patched code is NOT live until a fresh session. Display-manager, indicator and scoped helper are active. Read-only guarded snapshot remains serial1, owner:1.7, shell23329, both HDMI-1 and eDP-1 with original geometry. monitors.xml SHA256 remains66db6c80178131fa3037e1982d2600ccdf0c365810cadbdd467187ba66b0a8b0.

The temporary one-shot resumer is armed and unconsumed; its current-session invocation correctly did nothing. Candidate and baseline previews passed. Next action is arm-logout ONCE, then a single transient user timer precision-hdmi-logout invoking normal gnome-session-quit --logout --no-prompt after25seconds. Root helper waits at most90seconds for exact old-shell exit, then restarts GDM ONCE. Check actual status/journal/timer before assuming logout happened or scheduling anything further. No second logout/reboot or activation is authorized. The user signs into GNOME normally; the pinned autostart is intended to reopen the exact Codex thread automatically, but this post-login continuation is NOT yet validated.

After login follow SESSION-TEST.md: verify NEW mapped patched Mutter, Intel primary, PaperWM/indicator, both monitors; keep final zero-owner refusal and do not attempt VFIO around Xwayland or GNOME. The system journal at13:21:17 also recorded a device wait timeout for /dev/disk/by-uuid/13C004C07DA7D213; inspect its origin read-only before any Windows start, do not mount or alter Windows storage as a response. D-Bus reload logged duplicate service-name warnings and systemd-stdio-bridge gkr-pam unlock warnings; existing Codex authentication check passed separately. No new compositor crash was seen in the inspected activation interval. Cleanup the temporary autostart/unused marker and finish root helper after validation; retain logs as evidence. Worktree remains isolated, uncommitted and not merged.

## NEW approved single session test ready for activation (2026-09-12 13:18 CEST)

User explicitly answered YES to fresh LOCAL sudo authentication and one controlled GNOME logout/login after saving work. New grant: ONE fixed candidate test activation, ONE fixed rollback, ONE GDM restart only after normal original-session exit. This does not reset old budgets or authorize any reboot. Root helper is now actually authenticated and running as transient system unit `precision-hdmi-session-test.service`, PID75606, outside the graphical session, Restart=no, RuntimeMaxSec1hour. No sudoers/autologin/linger/sleep changes. The old `/run/precision-hdmi-activation/control.sock` and its empty parent were verified stale and removed by the root helper. The new endpoint is `/run/precision-hdmi-session-test/control.sock`; it checks UID1001 and only fixed actions.

Read `maintenance/SESSION-TEST.md` before the next action. Tools are `/nix/store/3hvi6da4piy6rv7md7yrag1rlpayqh4x-precision-hdmi-session-test/bin/precision-hdmi-session-control`. Candidate is `/nix/store/xl5mdhz28nwnr46ydj85cdyb77d77aqq-nixos-system-precision7560-26.05.20260611.a037402`; rollback is exact pre-test LIVE zkvp6nb..., not booted154. Patched Mutter `/nix/store/ms7m1bj4x2rw0hsym8lfa7yssrn3znwh-mutter-50.1`; patched GNOME `/nix/store/fn5k3i2q913r2h5mshxy0hyqjcx5yz4r-gnome-shell-50.1`. Expected old shell23329 identity bootec89b2a7...start465804, oldCodex24815 start469484. Saved/booted154 xkga9k4...unchanged; candidate/current kernel byte-identical.

Actual candidate `preview` passed: would NOT stop display-manager, would stop/start accounts-daemon and gpu-indicator, reload system dbus, restart Home Manager/polkit/udevd. No user-manager or GNOME restart listed. Root activation counters still0/0/0 at this checkpoint; query status before assuming the next operation happened. Do not rerun activation if counter already1.

Temporary one-shot `/home/lexyo/.config/autostart/precision-hdmi-resume.desktop` installed, pinned immutable script. State `/home/lexyo/.local/state/precision-hdmi-session-test-20260912/`; armed marker written for planned OR unexpected session loss. It refuses to launch while original GNOME identity is alive and waits for old agent exit, then consumes marker and opens Kitty resuming exact thread01a09263-e6f0-7983-b528-09146e982e9f with full-access settings already authorized. No concurrent coordinator, no retry loop. Actual Codex login-status check in a transient user service succeeded; no credential contents read/copied. Normal manual GNOME login is expected; no automatic login enabled.

Build/test progress: explicit flake package `precision-hdmi-session-test` extends Precision with only the tested local Mutter patch and display-manager restart/stop suppression. Normal Precision output stays unpatched. Ten new root-controller budget/timeout tests passed (mocked commands, no privilege);30 controller/display and17 indicator tests passed again. Indicator package now filters Python caches so impure/path and Git-flake builds produce the same candidate (verifiedxl5md...). The valid unified patch context whitespace is exempted via task-scoped .gitattributes. Work remains isolated/uncommitted; original main files preserved.

NEXT: verify armed resumer refuses current session, activate ONCE through fixed helper, verify old GNOME survived/current-system changed/newlibraryNOTyetmapped. Then arm-logout, schedule normal logout with a delay allowing final transcript flush, and end this turn with concise login instructions. Root helper waits up to90seconds for normal old-shell exit then restarts GDM ONCE to refresh static session paths. After login, resumed agent must verify actual mapped patched library/Intel/rendering/PaperWM/indicator and both monitor states. A new login alone does NOT validate hot-add/handoff. Keep zero-owner safety and do not try VFIO while any holder remains. Remove temporary resumer and finish root helper after attended validation, retaining evidence. No reboots or repeated logout attempts.

## Resumed source repair, no live display mutation (2026-09-12, after user asks "are you doing it?")

The user asked whether work was actually continuing. Clarified that no work continued after the previous final response, then resumed this interactive turn. `get_goal` reported PAUSED; no automatic worker was armed or resumed, and status was not changed through unsupported goal APIs. No new root authorization was obtained. Do not imply ongoing background work after a final response.

Confirmed exact fault by offline GDB17.1 on the locally retained GNOME3544 core: `rdi=0`, `rip=meta_monitor_is_for_lease+7`, faulting instruction reads `0x50(%rdi,%rax,1)`, called from lease `update_resources`. Source confirms missing monitor null check and no monitor-manager reload after GPU hot-add. Also found a separate lifecycle obstacle: Xwayland holds NVIDIA card0 (Intel renderD128), consistent with its long-lived DRM lease-device descriptor. Mutter retains known GPU paths across removal; native KMS error clears CRTC/plane/connector objects that ordinary update does not fully reconstruct. Do not claim an extra udev event/reload alone implements full GPU return or exempt any holder.

Source work completed this turn:

- New `modules/precision-windows/display-guard.js`, imported by the GJS bridge and packaged together. Compare GetResources outputs against GetCurrentState monitors, serials, connector uniqueness and identities. Pin unique D-Bus owner; reject operations crossing a GNOME restart. Pure injected apply is never called on mismatch. Unsupported/tiled ambiguous connector mappings fail closed.
- `host_display.py` refuses restoration across session changes and skips already-current layout applications. Busy preflight still refuses Xwayland; zero-owner root gate unchanged.
- Removed failed `refresh_display`, root-only refresh-display hook, forced off/detect and synthesized HOTPLUG from candidate source. Nothing was activated; the current live closure still has the older code.
- Foreground activation-helper source now handles HUP/TERM/INT through exact cleanup after any in-flight activation. One unprivileged temporary-directory test with all three actual signals passed. The stale ROOT socket in /run is untouched; no helper was restarted and no budget reset.
- Build-only `maintenance/mutter-gpu-add-monitor.patch` adds the null check and reload after successful secondary GPU add. `maintenance/mutter-hdmi-candidate.nix` pins50.1, is NOT imported by NixOS and builds successfully to `/nix/store/ms7m1bj4x2rw0hsym8lfa7yssrn3znwh-mutter-50.1`. Nixpkgs disables Mutter runtime tests; build success is compilation only, not live crash/handoff validation. Patch does NOT release Xwayland or implement complete GPU removal/re-add.
- Updated FINAL-REPORT and WINDOWS-GUIDE with prominent INCOMPLETE/current HDMI warnings, preserving older154 successes as historical. Full detailed local evidence/links in `maintenance/HDMI-CRASH-INVESTIGATION.md`.

Validation actually passed:30 Python controller/display tests,17 indicator tests,12 GJS guard tests (59 total), plus the separate activation cleanup signal test; full offline Nix system build `/nix/store/4cjjywpnwafm66wzps45zb326ny4sxs9-nixos-system-precision7560-26.05.20260611.a037402`; packaged guarded display snapshot on actual session gives shell23329, uniqueowner:1.7, serial1, HDMI-1+eDP-1. `git diff --check` passed. Original three untracked /etc/nixos files and monitors.xml SHA256 all remain byte-identical. Worktree dirty/unmerged, no new commit or push. The display guard and its GJS tests were intent-to-added for Nix visibility.

Current LIVE system still zkvp6nb..., booted/saved154 xkga9k4..., same boot ec89b2a7..., GNOME23329 unchanged. No new crashes in journal since12:28. Windows still stopped. No display application, GPU transfer, VM start, root activation, logout or reboot this turn. No processes/builds need continuation after completion of the listed builds. A future actual compositor test needs fresh legitimate LOCAL sudo authentication and a deliberate session restart after the user's work is saved; do not surprise-log-out or use a password from chat. All former budgets remain exhausted; no new authority has yet been granted. The crash fix is only one milestone; HDMI-safe GPU lifecycle, guest internal/external selector, reproducible provisioning, main-repo integration and new real cycles remain outstanding.

## STOP: live Mutter crash during HDMI test (2026-09-12 12:27 CEST; authoritative)

The user resumed and asked whether GNOME crashed, then whether all GNOME was now on NVIDIA and whether to unplug HDMI. Pause further display/GPU mutations. At12:27:00, the attempted temporary reapplication of the identical current internal layout through `ApplyMonitorsConfig` triggered SIGSEGV in GNOME3544. The tool call was interrupted, but the operation DID reach Mutter: coredump stack is `meta_monitor_is_for_lease -> update_resources -> meta_monitor_manager_notify_monitors_changed -> meta_monitor_manager_rebuild -> meta_monitor_manager_native_apply_monitors_config -> meta_monitor_manager_handle_apply_monitors_config`. Core retained by systemd; `coredumpctl info 3544` works. This is NOT a successful hot-handoff test and NOT just an indicator refresh. No repeat of that operation. The old session ended; new GNOME PID23329 started12:27:13 on the SAME boot ec89b2a7-35c8-44cc-8ee9-0ccb1419e153.

Verified restarted session: journal12:27:14 explicitly says `GPU /dev/dri/card1 selected primary given udev rule`; card1 is Intel i915 at00:02.0. NVIDIA card0 at01:00.0 drives HDMI, not the primary renderer. Both monitors now active using the unchanged saved monitors.xml: Intel eDP1920x1080 at(0,1080), primary; LG HDMI1920x1080 at(0,0). PaperWM ACTIVE. monitors.xml size1028, mtime2026-07-10T11:01:27+02:00, SHA25666db6c80178131fa3037e1982d2600ccdf0c365810cadbdd467187ba66b0a8b0. NVIDIA indicator is expected while it drives HDMI. User was advised to leave HDMI connected while crash is investigated, not to interpret the indicator as renderer selection.

Current test system `/nix/store/zkvp6nbpf6swkm281sfpanvwkm2bhn3k-nixos-system-precision7560-26.05.20260611.a037402`; booted/saved generation154 `/nix/store/xkga9k4w11g6yzbzp0pgwgsfg7p1c5cw-nixos-system-precision7560-26.05.20260611.a037402` unchanged. All3 test-activation slots were used (first2c2cd35..., second82jzkk71..., thirdzkvp6...). Third includes root-only refresh-display activation hook and bounded off/detect reprobe of inactive HDMI. Neither udev HOTPLUG nor reprobe fixed the stale monitor catalogue in the original GNOME session; only the crash/new session made both monitors active. Do not count this as automatic display restoration success. No new VM start/detach test has passed under host-HDMI configuration.

Windows was cleanly shut down12:16:46..56, QEMU exit0. CUDA32-value kernel and NVIDIA/audio suspension passed12:17:22 before the crash. The old controller recorded a spurious second-shutdown missing-socket error after QEMU exited; current candidate source fixes that race. Windows remains STOPPED. Current NVIDIA owners are GNOME23329, PID1, logind1690 and Xwayland23758. Do not bypass owner refusal or kill them. Gaming internal/external selection remains unimplemented.

The foreground temporary activation process died with the graphical session. No helper process remains; `/run/precision-hdmi-activation/control.sock` is STALE and returns connection refused. There are no added sudoers rules or startup services; only the original permanent inspect/prepare/release privileges work. The root-owned stale socket/directory still need exact cleanup under legitimate root authentication or disappear at reboot. Do not claim cleanup complete or re-arm the original bootstrap. No further reboot or activation was authorized by the finite helper; its remaining rollback could not be used after the root process died. Generic sudo still requires local authentication.

Offline source tests:27 controller/display/connector tests +17 indicator tests pass. Builds succeeded. None substitutes for the failed live test. Source/worktree remains dirty and unmerged; /etc/nixos master/original untracked inputs preserved. Before future deployment, guard against a Mutter `GetResources` output lacking a matching `GetCurrentState` monitor, and investigate/fix Mutter GPU-add catalogue/DRM-lease behavior. Do not retry configuration application against inconsistent live metadata. Last user questions are about the crash and renderer, not permission to restart the desktop again.

## Latest direction: HDMI display ownership (2026-09-12; supersedes display assumptions below)

User wants Gaming to offer internal Looking Glass or direct external HDMI, and Linux to automatically use both monitors whenever NVIDIA is back with Linux. Starting Gaming from that extended Linux desktop must safely release HDMI/NVIDIA while preserving Intel GNOME/PaperWM and refusing other GPU users. User correctly reports HDMI worked before this task. Confirmed: the explicit `mutter-device-ignore` rule in precision-windows.nix:19 was introduced by task commit b95fe8c8; the same tag was commented out in original master precision-nvidia.nix. The current regression is caused by our isolation policy, not faulty HDMI hardware. Physical HDMI ownership remains exclusive while NVIDIA is passed through.

Live refresh: generation154 current/booted, boot ec89b2a7-35c8-44cc-8ee9-0ccb1419e153, GNOME50.1 PID3544, Gaming controller9953/QEMU9991. Keep the running guest open during preparation. Linux currently only has Intel eDP-1, DP-1/DP-2 disconnected; NVIDIA is VFIO. No host display policy, BIOS, layout, drivers or VM state has been changed in this HDMI investigation.

Verified upstream Mutter50.1 `free_unused_gpu_datas()` releases unused secondary renderer resources, and KMS uses bounded fd holds. Therefore test temporary HDMI disable followed by *all-owner* verification; do not claim that monitor disable alone proves safe GPU removal. GPU re-add/resource recovery must also be live tested. Never exempt GNOME from the root helper's final all-owner check, force unload, kill the compositor, or log the user out. Current root helper treats awake-after-return as failure even for an active HDMI display; that must distinguish expected scanout from idle before enabling host HDMI.

Ordinary `sudo -n true` is denied. Only permanent inspect/prepare/release permissions remain. One local sudo authentication is required for a new host activation; do not use the password in chat, revive historical unattended/autologin bootstrap, or reboot. Prepare and build source changes before asking for that local activation. No safe live host HDMI handoff test has passed yet.

### HDMI candidate prepared; waiting for local authentication

Candidate system built successfully, offline: `/nix/store/2c2cd35bgjsbz38ailwmjg46adayagbc-nixos-system-precision7560-26.05.20260611.a037402`. NOT activated. Current/booted remains154. Candidate display-manager.service is byte-identical to current. Source changes remove the unconditional NVIDIA ignore policy, explicitly prefer Intel, add temporary HDMI disable/restore via documented Mutter D-Bus methods, preserve modes/scales/rotation/color/range, and keep the root helper's zero-owner check. Other applications are refused before even disabling Linux HDMI. Root CUDA return now distinguishes active NVIDIA scanout from an idle GPU that failed to suspend. New files host_display.py, host-display-bridge.js and test_host_display.py were intent-to-added for Nix visibility, not committed.

Tests actually passed: 22 controller/display offline tests,17 indicator offline tests, full Nix build, live packaged D-Bus snapshot, and no-HDMI `detach` no-op with unchanged GNOME serial1/PID3544. No real HDMI disable, GPU release/re-add, unplug/replug or Windows external-mode test has passed. Existing guest helper still forces LG-only at startup: Windows internal/external selector is NOT implemented yet. Existing VM9953/9991 remains running, untouched.

Opened a Kitty window titled `HDMI maintenance — local sudo authentication`; exec session52386. It runs `sudo /nix/store/wkxlk421qr946d03vyj876x0xwxrvwdq-precision-hdmi-activation-session/bin/precision-hdmi-activation-session`. Password entry is only local, never captured/stored. Last check: `/run/precision-hdmi-activation/control.sock` absent, so authentication is pending. The reviewed source is maintenance/hdmi-activation-session.py. It is a foreground root process, with no sudoers, startup services, auto-login or boot writes. Allows at most3 `test` activations of immutable Precision closures and1 rollback to154; stops accepting operations after2hours (an in-flight activation is allowed to finish). `finish` removes its exact socket/directory and exits. No reboots. Do not revive old bootstrap.

When authenticated, the Unix socket accepts one JSON request from UID1001 per connection: `{"action":"status"}`, `{"action":"activate","system":"/nix/store/2c2cd35bgjsbz38ailwmjg46adayagbc-nixos-system-precision7560-26.05.20260611.a037402"}`, `{"action":"rollback"}`, or `{"action":"finish"}`. Activation uses `switch-to-configuration test`; saved boot generation154 is unchanged. Use an asynchronous exec client for activation and keep commentary flowing. Verify current-system and actual services after every activation; do not mistake the build for activation. Preserve the running Windows session until an explicitly announced clean-shutdown validation step. GNOME's handling of NVIDIA removal/re-add remains uncertain; final all-owner gating must never be bypassed, and a failed handoff must restore the original Linux monitor layout. Full source integration into /etc/nixos remains pending until validation.

Pending reproducibility work remains: scripts were moved to modules/precision-windows/guest/install-display.ps1 and qga-runner.py, with maintenance/guest-agent.py now a shim; manifest.json added. No provisioning app or source integration commit exists yet. Preserve all pending work and the three original untracked /etc/nixos inputs documented below. Main repo remains master870bcaf.

## Latest user request: integrate reproducibly into /etc/nixos (2026-09-12 11:46 CEST)

User said "perfecto. now make everything reproducible and in my nixos repo". Main is sole coordinator; no subagents. `/etc/nixos` is owned by lexyo, master870bcaf, so local fast-forward integration is possible without sudo. Its only uncommitted entries remain the three original untracked files. Their SHA256 values before integration: gpu-vm-handoff.md `9b68ea4e57f260a656c5113ca914dc7a5bb011046e1e6852a2ba7fd92b02e32b`, precision-gpu-indicator.zip `7d6fc142af5436a324dce46d90337a321e62c4dae02ff07cd4413a94905dd2f9`, precision-vfio.nix `040458c30bc1b4fe352ee47373264ec2ca1247aa4a957c6eba0e430fb622c78e`. No AGENTS.md found.

Current Gaming controller9039/QEMU9079/viewer9093, boot ec89b2a7-35c8-44cc-8ee9-0ccb1419e153, generation154. LEAVE WINDOWS OPEN: the user is running FurMark; no more VM cycles or GPU resets promised. Real FurMark GL rendering is now confirmed in LGMP capture and logs: RTX A4000, NVIDIA580.92, frontend OpenGL4.6 and stress-scene OpenGL3.2,100% GPU utilization. The previous OpenGL1.1 report coincided with Light-mode validation. Three complete Gaming returns on154 passed CUDA32-value kernel and suspension; Light passed concurrent Linux CUDA, busy refusal and clean shutdown. Two Gaming starts with the new startup task automatically displayed sign-in, including after Light. See GENERATION-154-VALIDATION.md; its tail needs final results added.

New guest display fix is installed and works: SYSTEM startup task `Precision Windows Gaming Display`, admin-only `C:\ProgramData\PrecisionWindowsDisplay`, source/exe `DisplayTopology-0203F006FA71261E.cs/.exe`, script `startup.ps1`. Task applies a temporary LG-only topology before sign-in (does not persist topology or change credentials), skips Light,75second readiness deadline/2minute task limit. Main script is currently untracked `maintenance/guest-display-console.ps1`; documentation WINDOWS-DISPLAY-FIX.md. It must be promoted into permanent guest provisioning. Older generated debug folders `C:\ProgramData\PrecisionDisplayProbe-22f36613e1354f8e9eb6a05454f5fefc` and `...-8cec3272b7ad4618bafbcf123dc6c2d2`, plus obsolete DisplayTopology-EC8DCB01325C5059.cs/.exe, may be cleaned after exact validation; do not touch current helper or user files.

Next implementation: promote scripts into modules/precision-windows/guest; add a Nix `windows-provision` app with read-only check and idempotent apply, pinned LG IDD archive SHA25634daa6ddb403c1f503fb2ace94360159818fda1795fc5c2be5cec1f4391d5d57. Existing validated Windows NVIDIA580.92 came from its pre-existing driver store and must be preserved, not silently replaced/downgraded. Reproducibility explicitly assumes the existing Windows installation/QGA/NVIDIA dependency; Windows disk/TPM/credentials stay out of Git. Run check/apply/check without restarting guest drivers when already correct, package/offline tests and Nix build, then commit only task files and fast-forward /etc/nixos master preserving those original untracked files. Do not remote-push unless asked. Generic sudo still unavailable; no host activation is needed if only flake app/provisioning/docs change. The full Linux system previously rebuilt to the exact current154 path.

maintenance/guest-agent.py has been improved to transfer scripts via QGA private staging to avoid Windows32K command-line limit; process-only PowerShell execution policy for reviewed scripts, cleanup after exit. It can be refactored into reusable qga.py with import-safe CLI shim. Serialize QGA access. No passwords or security-policy persistence. Temporary host maintenance privileges/autologin/continuation remain removed. TI-Nspire now physically3:12 but re-enumerate; no new Gaming application-recognition claim. The old blocked/progress markers in maintenance state still describe boot145 and need final reconciliation.

## Resumed on clean generation 154 (2026-09-12; latest)

User booted generation154 and said "ok.. .continue". Main interactive agent is now the sole coordinator; the former continuation service is inactive, unlinked, and not being restarted. Boot ID `ec89b2a7-35c8-44cc-8ee9-0ccb1419e153`; current and booted system both `/nix/store/xkga9k4w11g6yzbzp0pgwgsfg7p1c5cw-nixos-system-precision7560-26.05.20260611.a037402`. No further reboot is planned or needed for the current tests.

Pre-launch checks: Intel IOMMU parameters present, GPU/audio only in their IOMMU group; `/dev/kvmfr0` correct character device owned by lexyo:kvm mode0600; PaperWM and GPU indicator both ACTIVE; NVIDIA595.71.05, both PCI functions suspended, permanent GPU helper reported correct Linux drivers and no owners. Calculator0451:e022 is NOT currently enumerated, so do not request a device-selection prompt or claim a new physical USB test passed. Existing Light/SPICE TI CAS application recognition remains a historical passed test.

Latest live state: Gaming is running (controller5430, QEMU5470, Looking Glass5473). First enumeration initially showed NVIDIA error and CUDA cuInit100; NVIDIA subsequently became healthy without a driver reinstall. One reviewed IDD device refresh after NVIDIA was healthy changed software capture to hardware. User then confirmed "seems like it shows". A fresh audit reports NVIDIA580.92, problem0, 307MiB used, Looking Glass hardware frame graph at1920x1057, and the actual Windows CUDA kernel verified32 values. No guest credentials, sign-in policy, firmware or TPM changes. User is checking the Windows GPU; leave the working viewer open during that interaction.

Remaining safe work: verify subsequent startup does not require another IDD refresh, clean viewer-exit return, CUDA and idle confirmation on154; update the otherwise stale final report. Eight passive pre-launch idle/UI samples already passed. Preserve all cleanup and login/security settings. Only permanent scoped GPU permissions remain; no routine sudo or device prompts are to be opened. Record any unavailable optional USB/application checks accurately. See GENERATION-154-VALIDATION.md for the sequence and evidence; do not treat the manual display recovery as an automatic-start reliability pass.

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

## Source launcher selector and package follow-up (2026-09-12)

The isolated controller now exposes a guarded Gaming destination chooser and
explicit `--display internal|external` options. Internal remains Looking
Glass on the Intel laptop panel; external requests Windows `DisplaySwitch
/external` after the guest agent is ready for the passed-through NVIDIA HDMI
output. It refuses ambiguous monitor topology before any handoff. Controller
tests (35), indicator tests (17), and maintenance tests (11) pass. Offline
package builds returned `dazcsnhkb10cp8lqn7n708wkvw4v56d8-precision-windows-1.0`
and `1hmg5nf2sh3ad157mswsvrlsz824jh6p-precision-gpu-indicator-0.1.0`.
The source-only changes are not activated; real external HDMI output and
repeated HDMI-mode VM/CUDA cycles remain unvalidated because GNOME/Xwayland
retain NVIDIA handles after the safe HDMI detach gate.
