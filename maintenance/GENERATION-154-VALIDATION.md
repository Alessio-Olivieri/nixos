# Clean generation 154 validation

Boot: `ec89b2a7-35c8-44cc-8ee9-0ccb1419e153`. Resumed by the user after booting generation 154 on 2026-09-12. No additional agent reboot or restoration of temporary privileges.

## Passed before starting Windows

- Current and booted systems both match `/nix/store/xkga9k4w11g6yzbzp0pgwgsfg7p1c5cw-nixos-system-precision7560-26.05.20260611.a037402`.
- Kernel command line has `intel_iommu=on iommu=pt`; the GPU's IOMMU group contains only `0000:01:00.0` and `0000:01:00.1`.
- NVIDIA driver 595.71.05; permanent helper reports Linux graphics/audio drivers and no holders.
- `/dev/kvmfr0` is a character device owned by lexyo:kvm, mode 0600.
- GNOME reports PaperWM and the GPU indicator ACTIVE. Actual accessibility-tree inspection shows the visible `Intel` label and `NVIDIA is runtime-suspended` detail.
- Both GPU functions remained suspended in all eight passive samples, 11:13:09 through 11:13:30 CEST, while the collector and extension were running. No GPU device was opened by this monitoring test.
- Previous Light guest is cleanly stopped, QEMU exit 0. Continuation service is inactive and temporary root privileges remain removed.

## Gaming startup and display recovery

- Installed Gaming desktop launcher started controller5430, QEMU5470 and Looking Glass5473; GPU/audio bound to VFIO. The visible indicator changed to NVIDIA / VM with the actual QEMU owner.
- Initial guest enumeration showed an NVIDIA error and the first CUDA test failed with cuInit100. Later NVIDIA initialized successfully without reinstalling its driver. The new USB controller changes automatic PCI slot assignment compared with the earlier Gaming test; new enumeration is a possible contributor, not a proven sole cause.
- QXL screenshot at11:16 showed the Windows lock screen, while the user reported a blank Looking Glass window. The IDD had initialized in software mode.
- After verifying NVIDIA healthy, the existing reviewed `guest-idd-refresh.ps1` restarted only the Looking Glass display device at11:17:42. The frame graph then reported `mode=hw`; the client received1920x1080 and later1920x1057 frames. User confirmed "seems like it shows". Sign-in and security policy were not changed.
- Actual Windows CUDA kernel passed, verifying32 values. Fresh guest audit reports RTX A4000 Laptop GPU, NVIDIA580.92 (`32.0.15.8092`), problem0, and307MiB used. Looking Glass IDD and QXL also report no PnP errors.
- Evidence in maintenance state: `generation154-gaming-audit.txt` and `generation154-windows-cuda.txt` are the INITIAL failures; `generation154-windows-cuda-ready.txt`, `generation154-idd-refresh.txt`, and `generation154-gaming-healthy-audit.txt` record recovery. `generation154-qxl.png` is a basic-display screenshot, not proof of a Looking Glass frame capture.

## Repeated handoff and automatic sign-in display

- First viewer-exit cycle:11:24:05 close,11:24:11 QEMU exit0,11:24:38 actual Linux CUDA kernel verified32 values and both functions suspended. The actual panel returned to Intel.
- Second cold Gaming boot selected the healthy A4000 and hardware IDD automatically; Windows CUDA again passed. However, a real LGMP capture was completely black and the user confirmed it. This disproved automatic display readiness despite healthy driver/capture logs.
- A short-lived console-session diagnostic found QXL primary (`flags=5`) and Looking Glass secondary (`flags=1`) before sign-in. The normal upstream user helper repeatedly failed WTSQueryUserToken because no user was signed in. A temporary LG-only topology applied from SYSTEM in that console session produced a real Looking Glass lock-screen image. No authentication or saved-topology changes were involved.
- Installed the bounded, administrator-protected Windows startup repair described in `WINDOWS-DISPLAY-FIX.md`. Source is `guest-display-console.ps1`; it is guest provisioning, not a Nix-managed Windows system. The installer recognizes an already-correct layout and makes no display change.
- Second viewer-exit cycle:11:35:44 close,11:35:49 QEMU exit0,11:36:14 Linux CUDA verified32 values and both functions suspended.
- Third Gaming boot: launch11:36:44, startup task11:37:00 applied the temporary LG-only topology, task result0. An early frame was still black during startup; a subsequent actual LGMP frame66 showed the normal Windows PIN sign-in screen. User confirmed "Now i see". NVIDIA580.92 and IDD hardware mode are healthy. This startup required no manual refresh or display repair command.
- Offline controller tests10/10 and indicator tests17/17 passed. The indicator test invocation requires `PYTHONPATH=modules/precision-gpu-indicator`; the first unqualified invocation failed import and is not counted as a pass.
- Offline Nix build returned exactly the running/booted generation154 system path. Only pre-existing VSCode option/fork warnings were emitted.
- Third Gaming viewer-exit cycle:11:39:00 close,11:39:05 QEMU exit0,11:39:32 Linux CUDA verified32 values and both functions suspended. Three complete return cycles have now passed on154.
- Light boot11:39:45: normal Windows desktop captured through its basic display. New startup task result0, log explicitly `Light / no NVIDIA: no display changes`.
- An actual Linux CUDA kernel ran successfully while Light was running. While its bounded test process retained the context, the permanent prepare helper refused with `NVIDIA is in use: Python (PID 8739)`. The CUDA test process exited normally; no process was killed. Both NVIDIA functions were suspended again at11:40:20 while Light remained running.

## Still pending

A subsequent Gaming startup after Light and final cleanup/report reconciliation. The TI-Nspire has since reappeared (its USB address changed through3:10,3:11 and3:12); re-enumerate before attachment. Do not claim new application recognition from physical USB presence alone. The earlier user-confirmed Light/SPICE TI CAS application test remains valid historical evidence.
