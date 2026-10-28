# Installed ASUS: controls and validation

Inspected 2026-10-28. NixOS 26.05, kernel 6.18.35, open NVIDIA driver
595.71.05, AMD Mesa 26.1.2, asusctl/asusd 6.3.7. Inputs remain pinned.
The generated hardware-configuration.nix and machine.nix were preserved byte for
byte, including the original local edits, and included as-is in the installed
host's commit. No applicable AGENTS.md was found.

## Keyboard lighting

asusd failed at startup with 226/NAMESPACE because its ReadWritePaths directory
/etc/asusd did not exist. Created the directory and restarted the service.
controls.nix now uses systemd ConfigurationDirectory to create it before the
service sandbox is established. Configuration remains writable and is saved by
asusd; rebuilding does not replace colour choices with a read-only config.

The actual hardware exposes ASUS TUF sysfs RGB controls and one keyboard zone.
The daemon reports Static as its supported basic mode, no basic subzones, and
off/low/medium/high brightness. Its support database has no FA608UP-specific
entry, so it uses a conservative TUF fallback. This is a **single-zone RGB**
keyboard, not multi-zone or per-key. ASUS also specifies a 1-zone RGB keyboard:
<https://www.asus.com/laptops/for-gaming/tuf-gaming/asus-tuf-gaming-a16-2025/techspec/>.

Applied and user confirmed: static muted blue 6699cc at low brightness. Commands
for the installed version (no sudo needed):

```sh
asusctl info
asusctl aura effect static -c 6699cc
asusctl leds set low
asusctl leds set off
asusctl aura power-tuf --awake true --keyboard --boot false --sleep false
rog-control-center
# Convenience commands after activation:
asus-keyboard calm
asus-keyboard colour ffb060
asus-keyboard off
```

The power command saved boot=false, sleep=false, awake=true, shutdown=false to
/etc/asusd/aura_tuf.ron. Persistence across the activation's daemon restart was
verified (Low, Static, 6699cc and disabled boot/sleep effects). Actual reboot
and suspend behaviour, including any firmware-controlled early flash, must be
checked separately. Do not infer these from successful writes alone.

GNOME already binds XF86KbdBrightnessUp/Down and XF86KbdLightOnOff. Keep these
bindings. The kernel maps Aura scancode 0xb3 to KEY_PROG4 / XF86Launch4; added a
host-only binding opening ROG Control Center, retaining Control-comma and all
other shortcuts. The user confirmed the keyboard setting; the exact physical
Aura event/binding still needs an interactive check after activation.

ROG Control Center now starts. Optional supergfxd/asus-armoury pages report
missing interfaces. No MUX switching service was added: ordinary AMD desktop
plus NVIDIA offload remains the working graphics policy.

## Graphics and CUDA

| Probe | Observed result |
| --- | --- |
| Ordinary and amd-only glxinfo -B | AMD Radeon 780M, accelerated OpenGL 4.6, Mesa 26.1.2 |
| nvidia-offload glxinfo -B | RTX 5070 Laptop, OpenGL 4.6, NVIDIA 595.71.05 |
| amd-only vulkaninfo --summary | AMD Radeon 780M / RADV PHOENIX |
| nvidia-offload vulkaninfo --summary | RTX 5070 Laptop / NVIDIA |
| 1024x768 GL gears, about 12–15 seconds per GPU | Both rendered, roughly 143 FPS at the panel's 144 Hz |
| Vulkan cube, 720 frames per GPU via Xwayland | Both selected the requested GPU and completed |
| fsraytrace shader demo, 12 seconds per GPU | Both completed the bounded run without application errors |
| Existing CUDA probe | Kernel executed with 32 threads; all 32 returned values verified |

During AMD GL/shader workloads, samples were 23% / 36 C and 14% / 40 C.
NVIDIA samples were 41 C / 0% / 12.19 W during vsynced gears, and 41 C / 4% /
9.91 W during the shader demo. These light, bounded tests verify rendering,
not thermal stability or maximum performance. No unattended stress test ran.

vkcube's native Wayland backend initially failed to load its dynamic library.
Xwayland worked on both GPUs. Supplying the pinned Wayland lib directory via
LD_LIBRARY_PATH made the NVIDIA native Wayland test (360 frames) pass too.
Use `vkcube --wsi xcb` for the installed tool without that diagnostic override.
NVIDIA vulkaninfo emitted a library-path warning naming libGLX_nvidia and
libnvidia-glcore, but returned the correct GPU and rendered successfully.

Kernel wake-up logs included GSP PFM_REQ_HNDLR_STATE_SYNC_CALLBACK assertions
at kernel_gsp.c:1447. These remain an unresolved driver observation; no Xid or
application failure was observed in the initial rendering runs. The later
aborted hibernation did break NVIDIA GLX; see the sleep results below. Do not silently discard them
or assume they are harmless under suspend or passthrough.

After tools exited, both 01:00.0 and 01:00.1 returned to runtime suspended.
The driver reports fine-grained Runtime D3 enabled and video memory off.
The GNOME GPU indicator is active and reads passive PCI state. Its legacy
protocol value `intel` means the integrated desktop even on AMD; the displayed
desktop label is patched to AMD. Idle handles from GNOME Shell and Xwayland
can remain open even when the GPU is suspended. Do not leave nvidia-smi/nvtop
running while testing idle power.

```sh
amd-only COMMAND
nvidia-offload COMMAND
glxinfo -B
amd-only vulkaninfo --summary
nvidia-offload vulkaninfo --summary
python3 -B /etc/nixos/modules/precision-windows/cuda_probe.py
cat /sys/bus/pci/devices/0000:01:00.{0,1}/power/runtime_status
cat /run/gpu-indicator/status.json
```

Ollama is installed with CUDA support but stopped on demand. Its configured
model directory is empty, so **Ollama inference/acceleration was not tested**.
No model was downloaded. Choose a model and approve its size first, then use
ai-start, run a short prompt, check `ollama ps` and the service logs, and unload
the model/stop services with ai-stop before checking idle GPU power again.

## Display, power and firmware

Mutter reports BOE NE160WU1-MY2 at native **1920x1200, 144.000 Hz**, current and
preferred. No mode change was needed. eDP-1 is connected to AMD at 65:00.0;
NVIDIA exposes disconnected HDMI-A-1, DP-9 and eDP-2. Physical external port
mapping still requires testing each port with a cable.

Brightness remains unresolved on BIOS FA608UP.321 (DMI date 2026-03-23).
The installed boot still logs AE_NOT_FOUND for PCI0.GPP0.PEGP.EDP1, _SB.BRTN
and _Q17/_Q18. Its only backlight is nvidia_wmi_ec_backlight, type firmware,
range 0–200. A login1 SetBrightness request of 160 changed `brightness` to 160
but `actual_brightness` stayed 200. Restored 200. GNOME Power exposes no Screen
interface, and asusd also reports no usable display backlight.

The native-backlight boot test added `acpi_backlight=native`. It exposed
amdgpu_bl1 and nvidia_0, and Mutter associated amdgpu_bl1 with eDP-1. Direct
50% and 25% tests changed requested and actual sysfs readings, but the user
confirmed **no visible dimming** and reported that the brightness keys had
worked before this test. The EDP1/BRTN/_Q17/_Q18 ACPI errors continued. This
test FAILED; its boot specialisation was removed at the user's request.
Return to the ordinary firmware-selected backlight policy with a coordinated
reboot. Do not treat changing readback as a brightness fix, reload amdgpu, or
detach a display device in the live session. No further backlight experiment
is authorized by the rollback request.

The user approved the rollback reboot. The current command line no longer
contains acpi_backlight=native, and only nvidia_wmi_ec_backlight is registered
again. Both AMD desktop GLX and NVIDIA offload GLX work after the rollback;
asusd is active and image_size remains 0. The user confirmed both screen-brightness keys and keyboard-lighting controls
work again. Do not promote the failed native interface or infer functional
brightness from sysfs readings alone.

asusd controls Performance on AC / Quiet on battery by default. Quiet, Balanced
and Performance are available. Charge limit currently 100%; supported range is
20–100. No TLP, tuned, auto-cpufreq, thermald or power-profiles-daemon is active.

```sh
asusctl profile list
asusctl profile get
asusctl profile set --help
asusctl battery info
asusctl battery limit 80
asusctl battery oneshot
```

ASUS lists **BIOS 325, 2026-09-11**, including an EZ Flash image, newer than 321:
<https://www.asus.com/in/supportonly/fa608up/helpdesk_bios/>.
The notes say performance optimisation; they do not establish that brightness
is fixed. fwupd currently offers no system BIOS update, but does offer a UEFI
dbx update. Neither was flashed. Review the vendor process and arrange a
separate firmware maintenance window before any update.

## Encryption and sleep

Verified layout: EFI 1 GiB at /boot; LUKS2 partition containing cryptroot, then
VG nixos with ext4 root and 20 GiB swap. Resume major/minor is 254:1, the swap
LV, and the running command line names /dev/mapper/nixos-swap. Another 4.5 GiB
zram device has higher swap priority; it is not the resume target.

hibernate.nix now names the verified LUKS UUID rather than /dev/nvme0n1p2.
The systemd initrd includes crypttab, LVM tools/udev rules, resume generator and
vconsole setup. Cryptroot is unlocked before its swap LV becomes available;
there is no separate random swap key to lose at reboot. Italian layout is set
for early console and GNOME (live input sources were xkb/it).

NVIDIA has PreserveVideoMemoryAllocations=1, UseKernelSuspendNotifiers=1 and
TemporaryFilePath=/var/tmp on encrypted root. Driver 595/open uses kernel
notifiers by default in the pinned NixOS module, so absence of legacy
nvidia-suspend/hibernate/resume services is expected. Do not add duplicate
legacy hooks.

### Actual sleep tests

Suspend was tested with the user's saved-work/timing confirmation. At 13:01 the
system entered s2idle and the user woke it with a key. The same GNOME session,
boot ID and marker process (including its in-memory token and process start
ticks) survived. Lighting stayed Static/Low, Wi-Fi reconnected, and both AMD and
NVIDIA GLX still rendered. The user confirmed normal display/keyboard behaviour.
A D-Notifier status=0x11 warning was logged by NVIDIA. This is one short cycle;
longer battery sleep and wake reliability remain to be tested.

Hibernation was tested separately at 13:02 with explicit confirmation. It
**failed before power-off** with ENOMEM, not enough free snapshot memory:
2,075,962 normal pages plus 1,024 needed, versus 1,922,110 available. The 20 GiB
disk swap was empty before the attempt. It never restored an image. A surviving
session/marker after an aborted attempt must not be mistaken for resume success.

The abort also produced NVIDIA nv_set_system_power_state warnings and display
detection errors; a subsequent NVIDIA GLX context request failed with BadValue.
AMD kept the desktop usable. Reboot is required to establish a clean driver
baseline before another hibernation attempt; no live module unload was attempted.

Set /sys/power/image_size to 0 at runtime and added the same setting via
systemd-tmpfiles. The kernel documents this as requesting the minimum possible
snapshot, which may reclaim/swap more memory. This is a **candidate fix pending
retest at that point**, not proof of hibernation support. zram was not disabled or resized;
its compressed pages and driver allocations are relevant to snapshot pressure.
Reference: <https://www.kernel.org/doc/html/latest/admin-guide/pm/sleep-states.html>.

A separate, explicitly approved retry at 13:22 succeeded with image_size=0
after the clean reboot. systemd-hibernate returned successfully at 13:24. The
original boot ID, GNOME session, test-process PID/start ticks and random token
held in its memory survived, and the marker continued updating. The user
reported that hibernation worked. NVIDIA GLX rendered afterward, keyboard
lighting stayed Low, and both NVIDIA functions later runtime-suspended.
Snapshot copying needed 1,230,939 pages versus 2,767,131 available, compared
with the first attempt's shortage. This verifies one real restore in the test
boot, under a lighter workload; it does not prove heavy-memory reliability or
that image_size alone explains the difference. Retest ordinary-boot hibernation
later with separate timing approval. ACPI brightness errors remain unresolved.

Only s2idle is advertised; do not force unsupported S3/deep sleep.
Before either test, save work and confirm timing. Test separately:

1. Record boot ID, current session, a long-lived process PID/start time and an
   unsaved disposable editor buffer. Suspend, wake, check display, lighting,
   networking and offload; inspect the PM/NVIDIA journal.
2. After suspend passes, record those markers again. Hibernate, wait for power
   off, power on and unlock with the Italian keyboard. Verify the same boot ID,
   process and disposable buffer are restored, and journal contains hibernation
   image restoration. A cold boot or new login is a failure, even if boot works.
3. Check lighting, display brightness and GPU idle state after each transition.

Never reboot into a different generation while intentionally retaining a
hibernation image. Do not change the running kernel or swap layout underneath
the test. No encryption keys or credentials are stored in this repository.

## Configuration validation and activation

The complete ASUS system and native-backlight specialisation built successfully
with the original lock file, reusing the installed CUDA/Ollama output. The
flake's ASUS profile check built successfully; six preparation-helper tests and
17 GPU-indicator tests passed. The first standalone collector-test invocation
used the wrong working directory; rerunning from its module directory passed.
Existing VSCodium migration warnings remain outside this host-specific change.

The dry activation listed ASUS/accounts-daemon, Home Manager and polkit changes,
with a D-Bus reload and no display-manager restart. Applied the validated normal
configuration without logout or reboot. asusd is active, its directory setting
is present, the new shortcut coexists with Control-comma, and the built initrd
was inspected: crypttab names the verified LUKS UUID and vconsole says KEYMAP=it.
The running kernel remains 6.18.35. The user approved a one-shot native-backlight
boot and a separate hibernation retry; their actual results are recorded above.
The final configuration removes the failed native-backlight specialisation and
keeps the minimum-image-size policy that was active during the successful retry.
