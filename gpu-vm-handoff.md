# Precision 7560: Linux AI and two Windows launch modes

This brief carries forward a planning conversation with Alessio Olivieri on 2026-09-11. Continue the work as an agent on his actual laptop. He has offered local computer access so the configuration can be inspected and implemented directly. Use the local session's granted permissions and preserve unrelated work.

## Latest timing and autonomy requirements

Alessio still needs the laptop now. Until he starts the maintenance run, prepare
and inspect without activating disruptive changes or rebooting it. He explicitly
wants to launch the job later, go to sleep, and have the local agent continue
through automatic reboots and graphical login. He authorizes those actions as
part of that later maintenance run; do not ask him to reapprove each previously
scoped routine reboot while he is asleep.

Full Access is an agent permission setting, not a persistent reboot coordinator,
Linux root permission, a disk-unlock mechanism or a guarantee of success. Do not
ask for his sudo password in a prompt or store it in files. Establish any needed
privileges locally while he is present, using an explicit temporary maintenance
service or a task-specific privileged helper. A cached sudo timestamp does not
survive a reboot and must not be the recovery plan.

Before starting unattended hardware activation, implement and test this local
execution arrangement:

1. Save the exact working repository state, current boot generation, existing
   Windows VM assets, display/login settings and task checkpoints. Keep a durable
   log and a specific job/session identity; do not accidentally resume an
   unrelated "last" Codex task.
2. Install an explicitly enabled, temporary systemd coordinator that can restart
   the local agent after boot, with its existing user authentication available
   without an interactive sign-in. Use the installed CLI's documented
   non-interactive/resume interface after checking its actual version. A terminal,
   tmux session or bare `codex` process will not survive reboot on its own.
3. Verify networking and the machine's encrypted boot. The reviewed repo uses
   systemd-boot, keeps up to 15 generations and configures TPM2 LUKS unlock.
   Verify the actual TPM/PCR policy; a changed boot can still require recovery
   input. Retained NixOS generations are not automatic rollback by themselves.
4. Set up temporary GDM auto-login for `lexyo` only if required for GNOME/Looking
   Glass testing, using the user's authorization above. Save and restore the
   prior login/locking policy after maintenance. A headless agent can start
   before graphical login, but desktop checks must run inside the actual user
   session with the correct session bus. Do not assume auto-login unlocks the
   user's keyring or encrypted disk. Keep the laptop physically private during
   temporary auto-login.
5. Test one complete reboot, disk unlock, agent continuation and graphical
   session recovery while Alessio is still present. Establish an actual tested
   fallback to the working boot generation; do not infer it from having an old
   boot-menu entry. If that fallback cannot be established, limit unattended work
   to preparation/building and leave disruptive activation for an attended run.
6. Use a finite reboot budget (default three attempts), bounded service restarts,
   and no repeated blind GPU resets. Keep the machine on AC for the maintenance
   job without changing the requested AC-independent launcher behaviour. Prevent
   sleep only for the duration of the job and restore prior settings afterward.
7. On completion or a recoverable failure, remove/disable temporary privileged
   access, continuation services, auto-login and sleep overrides; leave a precise
   morning report. Preserve a usable baseline if the proposed GPU handover fails.

The goal is a working system by morning. Do not promise that GPU firmware/reset
limitations, a boot-unlock prompt, network loss or model-service limits can be
resolved unattended. Perform the scoped work autonomously when recovery has been
verified; stop with a useful checkpoint when continuing would require guessing
past an actual failure.

## Desired result

- Keep NixOS, GNOME and the existing PaperWM setup. GNOME should stay on the Intel integrated GPU.
- Keep the NVIDIA GPU available to Linux for CUDA/AI and Linux games by default. Let it enter runtime suspension when unused.
- Provide two GNOME launchers for the same existing Windows installation:
  - **Windows — Gaming:** NVIDIA PCI passthrough to Windows; display the guest within the Linux desktop, preferably using Looking Glass if supported.
  - **Windows — Light:** a basic virtual display, without assigning NVIDIA. The user explicitly does not need gaming acceleration in this mode.
- Select the mode manually, independently of battery/AC state. Do not automatically change modes when power is connected or disconnected. Existing CPU power policies need not be made identical.
- Closing the Windows viewer should initiate clean guest shutdown, wait for actual VM termination, and release resources. After gaming shutdown, return NVIDIA to the Linux driver and verify that it can suspend when idle and run CUDA again.
- Linux AI may coexist with Windows Light. Linux CUDA and full NVIDIA passthrough cannot use the physical GPU simultaneously. If a Linux application holds the GPU, report the specific blocker; do not kill its work automatically.
- Prevent concurrent starts or mode switches while the Windows installation is running. Preserve its disk, firmware/NVRAM, TPM state and identity as applicable. A viewer disconnect is not proof that Windows stopped; a shutdown timeout must be surfaced rather than silently cutting power.

## Added request: GNOME GPU indicator

Add a top-bar/system-status indicator showing Intel when NVIDIA is suspended,
NVIDIA when it is awake, and a dropdown listing the applications holding NVIDIA.
Strip Nix store paths/version prefixes and wrapper suffixes; show names such as
Ollama, Steam, Stellaris and Firefox. Do not show full command lines. Indicate
unknown/unavailable states honestly and distinguish VFIO reservation from an
observed running VM. An awake GPU with no identified application must not be
presented as powered off.

A draft implementation is provided separately as `precision-gpu-indicator.zip`.
It contains a GNOME 50 extension, a Python collector, Nix packaging/module,
documentation and 12 passing synthetic backend tests. JavaScript syntax was
checked. No GNOME or Nix runtime was available in the preparation environment,
so the local agent must evaluate and test that integration before declaring it
installed. Read its README and reuse/adapt its source rather than starting over.

The collector only reads sysfs state and procfs file-descriptor symlinks; it
does not invoke nvidia-smi/NVML or open a GPU device. A small hardened system
service supplies sanitized names across user accounts, including Ollama's
`lexyoai` user. The desktop extension needs no sudo. Confirm that monitoring does
not prevent NVIDIA runtime suspension on this hardware. Device handles indicate
ownership, not continuous GPU utilization. Linux can identify the Windows VM,
but identifying individual processes inside Windows would need guest-side data
and is not part of this first indicator implementation.

## Hardware and configuration already known

- Dell Precision 7560, Intel Core i7-11850H, Intel Tiger Lake integrated graphics, upgraded NVIDIA RTX A4000 Laptop GPU with 8 GB VRAM.
- Earlier supplied diagnostics recorded 32 GB RAM, GNOME 50 on Wayland and NixOS 26.05; inspect the current system rather than assuming these remain exact.
- Repository: https://github.com/Alessio-Olivieri/nixos
- The remote repository was inspected at commit `8e7c025d1ec7aae9f52c2a1051df5b4e2a1b0b04` on `master`. Local files may be newer or dirty. No changes were made during that review.
- The relevant flake output is `precision`; its configured hostname is `precision7560`. Other flake outputs describe different computers.
- User account: `lexyo`.

## Repository findings to verify locally

`precision-nvidia.nix`:
- Intel bus ID `PCI:0:2:0`; NVIDIA bus ID `PCI:1:0:0`. Discover all actual GPU PCI functions and IOMMU group members.
- NVIDIA `legacy_580`, `open = false`, modesetting enabled, PRIME offload and `nvidia-offload` command enabled.
- `powerManagement.enable = true` and `finegrained = true`.
- Udev rule intended to make Mutter ignore NVIDIA and remove its seat tags; active rule matches `add` events. NVIDIA display-class PCI functions get `power/control=auto`.
- TLP runtime power management is `auto` on both AC and battery. CPU limits differ by power source.
- Existing Stellaris integrated/dedicated launchers provide a useful manual-launch pattern.

`modules/lutris.nix` wraps Lutris in `nvidia-offload`. Lutris, Steam, viewers, monitoring tools or AI services could retain NVIDIA handles. Inspect real process ownership before detaching; do not infer GPU freedom from a low utilization reading.

`home/home.nix` has a Windows shortcut executing `quickemu --vm /home/lexyo/windows-11.conf --display spice`. That VM configuration and its disk are outside the repository. Inspect them locally before migration. `modules/virtualbox.nix` actually enables Quickemu/KVM-related tooling, not a configured libvirt passthrough domain. No VFIO/libvirt passthrough implementation was found in the reviewed repository. `home/home.nix` also installs `pkgsUnstable.codex`.

`modules/ai-module.nix` enables Ollama and Open WebUI, with `ai-start`/`ai-stop`, and removes their boot-time wantedBy targets. It does not explicitly select a CUDA package. In the reviewed Nixpkgs revision, `a7ecea3deccfbdbf22945a89984fcc5a169da8aa`, Ollama defaults to the CPU variant unless configured otherwise; the supported NVIDIA selection is `services.ollama.package = pkgs.ollama-cuda;`. Verify the current pin and service before changing it. The old `services.ollama.acceleration` option is removed in that reviewed revision.

## Work sequence

1. Read local repository instructions and preserve current changes. Inspect live graphics ownership, IOMMU isolation, reset methods, runtime power state, display routing and the existing Windows VM using read-only checks first. Do not assume that this brief proves passthrough is supported.
2. Determine whether NVIDIA can be detached without disrupting GNOME or an attached display. A config rule alone does not prove this. A listed reset method alone does not prove reliable repeated guest starts.
3. Prepare scoped changes on an isolated branch/worktree as appropriate. Prefer one Windows domain/installation with controlled startup modes. Keep Linux NVIDIA ownership as the default, rather than permanently reserving the GPU for VFIO at boot.
4. Validate the Nix configuration and preserve a working rollback generation before activation. Explain any hardware limitation before building launchers around an unproven assumption. While the user is still working, do not activate disruptive changes. During the explicitly started overnight run, use the verified coordinator and recovery plan above for authorized reboots and tests.
5. Verify guest start, clean shutdown, NVIDIA reattachment, Linux CUDA recovery and idle power state over repeated cycles. Check both launchers, double-click prevention and shutdown failure handling. Report separately what was configured, what was measured and what remains unverified.

The user wants a convenient daily workflow and clear explanations of changes. Complete the work that can be done with the granted access; request only information or interaction that cannot be obtained locally. Do not claim that GPU release equals full power-off without checking its actual runtime state.

## Primary technical references

- https://libvirt.org/formatdomain.html#host-device-assignment
- https://looking-glass.io/docs/B7/requirements/
- https://download.nvidia.com/XFree86/Linux-x86_64/580.65.06/README/dynamicpowermanagement.html
- https://github.com/NixOS/nixpkgs/blob/a7ecea3deccfbdbf22945a89984fcc5a169da8aa/nixos/modules/services/misc/ollama.nix
- https://developers.openai.com/codex/noninteractive/
- https://developers.openai.com/codex/agent-approvals-security/
- https://gjs.guide/extensions/development/creating.html
- https://docs.kernel.org/power/runtime_pm.html

Recheck documentation against the versions actually installed on the laptop.
