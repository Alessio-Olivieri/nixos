# Intel / NVIDIA Indicator — draft for Alessio's Precision 7560

GNOME 50 top-bar extension, Python status collector, and an optional NixOS module.
Prepared for the local agent to install and validate later; nothing has been
activated on the laptop. This is a new implementation, not an extension from
extensions.gnome.org.

## Behaviour

| Panel | Meaning | Dropdown |
| --- | --- | --- |
| Intel | All observed NVIDIA PCI functions are runtime-suspended | NVIDIA suspended |
| NVIDIA · 2 | NVIDIA has device owners, grouped into two applications | Clean names and PIDs, e.g. Steam and Ollama |
| NVIDIA | NVIDIA or an associated PCI function is awake, even without identified applications | Explanation of the power state |
| NVIDIA · VM | A process holds the GPU's VFIO group/device | Guest name when QEMU provides one |
| NVIDIA · VFIO | Bound to VFIO; no live owner identified | Reserved for passthrough |
| GPU ? | Missing, stale, inaccessible or transitional data | Status unavailable; never silently claims Intel |

This reports device ownership and power-management state. A client holding a GPU
device open is not proof of continuous computation, and runtime suspension is
not a measurement of zero watts. Intel is the configured desktop GPU in this
particular setup; the extension does not independently measure the compositor's
renderer.

The collector reads `/sys` metadata and `/proc/PID/fd` symlinks. It never opens a
GPU character device, calls `nvidia-smi`, loads NVML, or uses GPU ioctls. Suspended
samples skip process scanning. Polling defaults to five seconds; the panel reads
a small JSON file every three seconds. Actual laptop power behaviour must still
be measured after installation.

Nix store directories, version strings and `-wrapped` executable suffixes are
removed from names. Known programs have friendly names; Python scripts and Wine
executables get readable basenames. Full commands, arguments and window titles
are not published. Linux-side monitoring can identify the Windows VM, not
individual programs inside Windows. Anonymous VFIO descriptors or namespace and
permission restrictions can prevent owner identification; the UI preserves that
uncertainty.

## Install later through the local agent

1. Extract this directory into the existing NixOS repository, e.g.
   `modules/precision-gpu-indicator/`.
2. Import its module only in the `precision` flake output, or in
   `precision-nvidia.nix` (adjust the relative path):

   ```nix
   imports = [ ./modules/precision-gpu-indicator/module.nix ];
   services.gpu-indicator.enable = true;
   ```

3. Append `"gpu-indicator@alessio.local"` to the existing enabled-extension list
   in `home/modules/gnome-manager.nix`, preserving PaperWM and the other entries.
   Alternatively, enable the installed extension with `gnome-extensions enable
   gpu-indicator@alessio.local` once GNOME has discovered it. A logout/login may
   be necessary; do this when the user is ready or in the verified overnight job.
4. Verify `device = "0000:01:00.0"` and `nvidiaDeviceNode = "/dev/nvidia0"` against
   the laptop. The node default targets the single NVIDIA card in this setup;
   it is configurable rather than guessed for multi-GPU systems.
5. Evaluate/build the configuration, inspect the resulting unit and activate
   only according to the user's maintenance timing. No flake input update is
   required just to import this module.

The small system collector runs as root because Ollama runs as `lexyoai` and
ordinary-user `/proc` inspection cannot reliably name another user's GPU clients.
The NixOS unit bounds its capabilities, makes the filesystem read-only except
for `/run/gpu-indicator`, isolates devices and limits socket families. It performs
no privileged GPU actions. The GNOME extension runs as the ordinary desktop user
and never invokes sudo. Process names/PIDs are readable by local users via the
status file; no command-line arguments or credentials are included.

Do not run this collector with `sudo` in a continuous interactive shell as a
substitute for the supplied service. There is no need to store a sudo password.

## Validation performed here

- Python unit tests use synthetic sysfs/procfs trees, including suspended GPUs,
  active auxiliary functions, cross-user permission failures, device-state
  transitions, legacy/cdev VFIO handles and Nix/Wine process names.
- JavaScript syntax is checked with Node; this does not execute GNOME APIs.
- No GPU, GNOME Shell, GJS or Nix evaluator is available in the preparation
  environment. The Nix package/module have not been evaluated here and the
  extension has not been loaded into GNOME. Treat this as a tested backend with
  a draft integration pending the checks below, not a finished laptop install.

The local agent should verify:

- Package/module evaluation against the actual pinned Nixpkgs revision.
- Enable/disable/re-enable in GNOME 50, ideally first in a nested session.
- The hardened service sees Ollama under `lexyoai`, and failures show a visibility
  caveat instead of an empty-list claim.
- NVIDIA remains suspended when the indicator is running and no GPU app is open.
- A known Linux NVIDIA game and an Ollama CUDA workload appear with clean names.
- Stopping those clients results in the expected sleep state. Displays and other
  device functions may keep NVIDIA awake, which must remain visible.
- Stopping the collector results in `GPU ?`, not a stale Intel/NVIDIA claim.
- VFIO state and owner detection when the VM handover is later implemented.

Run the backend tests from this directory:

```bash
python3 -m unittest discover -s tests -v
```

## References

- [GNOME extension development](https://gjs.guide/extensions/development/creating.html)
- [GNOME 50 porting guide](https://gjs.guide/extensions/upgrading/gnome-shell-50.html)
- [Kernel runtime power management](https://docs.kernel.org/power/runtime_pm.html)
- [NVIDIA RTD3 documentation](https://download.nvidia.com/XFree86/Linux-x86_64/580.65.06/README/dynamicpowermanagement.html)
