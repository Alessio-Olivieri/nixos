# Windows on this ASUS

The original Windows partitions are gone. No Windows VM disk, ISO, libvirt
domain or /home/lexyo/windows-11.conf was found. Previously the desktop launcher
called that missing Quickemu file. It now opens virt-manager for installation.
Quickemu remains available; no Precision-specific controller was enabled.

## Installation preparation

`windows-light.xml.in` is a review template generated with the installed
virt-install 5.1.0: Q35/KVM, 8 GiB RAM, 4 vCPUs, host-passthrough CPU, automatic
UEFI selection with Secure Boot/enrolled keys, TPM 2.0 emulator, VirtIO disk
and NIC, SPICE console/clipboard channel and QEMU guest agent channel.
It assigns neither physical GPU. It has not been defined or booted.

Substitute absolute paths for @DISK@, @WINDOWS_ISO@ and @VIRTIO_ISO@ only after
choosing official media and approving disk capacity/location. The user approved official Windows/VirtIO ISOs and a 250 GB sparse
qcow2; allocation/installation status is recorded below. Use 8 GiB guest RAM. On this 16 GiB host,
do not reuse the Precision's 16 GiB guest RAM allocation.

The default libvirt NAT network exists but is inactive. After the user's media
and storage approval, created the asus-windows directory pool at
/var/lib/libvirt/images and asus-windows.qcow2, with exactly 250,000,000,000 bytes
(250 GB / 232.83 GiB) virtual capacity and 196 KiB initially allocated. The pool
is active but not set to autostart. No domain was defined or started. Network
startup and the Windows ISO are still needed. Do not copy another host's disk
paths or silently download additional media.
The XML-generation probe used zero-byte temporary placeholders, allocated no
guest storage and defined no VM. virt-install unexpectedly registered a /tmp
pool even with --dry-run; that pool was stopped and undefined immediately,
without deleting any files. Both domain and pool lists were empty afterward.

Microsoft rejected Quickget's automated Italian Windows 11 download request
from this IP. The user needs to download official x64 installation media through
<https://www.microsoft.com/en-us/software-download/windows11> and provide its
filename under /home/lexyo/Downloads/windows-media. No unofficial replacement
was used. The official stable VirtIO driver ISO finished downloading to
/home/lexyo/Downloads/windows-media/virtio-win.iso (0.1.302, about 837 MiB), from
<https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/>;
local media and VM disks are never committed to this repository. Its local
SHA-256 was recorded beside it. The Windows download still appeared under an
Unconfirmed .crdownload filename at inspection, despite the user reporting
completion. Do not rename or install a partial/browser-pending image; obtain
the final filename and verify it against Microsoft's published checksum first.

After Linux sleep/brightness is stable and the Windows ISO is ready, replace
the XML tokens, validate the completed XML, start the default NAT network, define the
VM and install through virt-manager/SPICE. During setup load the matching
VirtIO storage driver from its ISO; install VirtIO network/display drivers,
QEMU guest agent and SPICE guest tools afterward. Select Italian input in the
guest. Use a Windows edition and activation/license appropriate to the user.

The XML template passed virt-xml-validate after substituting absolute paths.
The literal @PATH@ tokens intentionally do not pass libvirt's absolute-path
schema check. Runtime firmware/installer behaviour still needs a guest boot.

## Requested modes and feasibility

- **Light, 60 Hz:** virtual SPICE display, with AMD rendering the Linux viewer.
  This does not give Windows direct access to the AMD GPU or promise accelerated
  Windows 3D. Configure the guest display and, if desired, the host panel at
  60 Hz after installation. No guest currently exists to set this in.
- **Gaming, 1920x1200 at 144 Hz:** NVIDIA passthrough plus Looking Glass is the
  proposed path. This is not yet available or tested. The host must also run its
  physical panel at 144 Hz and the Windows captured display must expose that
  resolution/refresh; changing only the Linux viewer cannot create 144 Hz frames.

Read-only inspection found AMD-Vi/IOMMU enabled in the current kernel. Group 14
contains exactly 0000:01:00.0 (10de:2d58) and 0000:01:00.1 (10de:22eb). These
are the NVIDIA GPU and HDMI/DP audio. The GPU advertises `flr bus` reset methods;
the audio function has no individual reset node. A reset-method listing is not
proof of a successful handoff/recovery. No reset/unbind was attempted.

The connected internal eDP-1 is AMD-owned, so the AMD desktop can in principle
remain usable while NVIDIA is assigned to a guest. NVIDIA's disconnected eDP-2
and external connectors mean MUX/external wiring still matters. Connected
NVIDIA displays would be unavailable to Linux during passthrough. GNOME and
Xwayland hold idle NVIDIA handles: a live handoff cannot safely assume the GPU
has no host owners merely because it is runtime-suspended.

After Linux brightness/sleep is stable, prefer an explicit **VM boot mode**
reserving only this NVIDIA pair for VFIO, while retaining the ordinary offload
boot as default. First validate AMD-only boot, the complete IOMMU group,
NVIDIA guest driver startup, clean guest shutdown, and safe return to ordinary
Linux. Coordinate each reboot and reset test. Do not use ACS override or copy
Precision Intel IOMMU flags, IDs, user IDs, sysfs paths or custom Mutter patches.
No VFIO specialisation is enabled yet, so normal CUDA/offload remains available.

Only after passthrough works: install matching Looking Glass host/client and a
guest display solution. A render-only laptop GPU may need a supported virtual
display driver or an NVIDIA-connected dummy display to create a capturable
output. The old Precision configuration is useful design reference but hardcodes
other hardware and guest paths; it is not portable as a unit.

At 1920x1200 SDR, the documented Looking Glass formula gives 32 MiB IVSHMEM
(64 MiB for HDR), rather than copying the Precision's 128 MiB allocation.
Full 32-bit frames at 144 Hz represent about 1.33 GB/s before overhead. Shared
memory capacity alone does not establish attainable frame rate or latency.
Measure actual guest rendering/capture rate, viewer frame pacing, AMD copying,
CPU load and thermals with a short game workload. Do not promise 144 FPS for
every game or enable KVMFR/IVSHMEM before passthrough is demonstrated.

Reference: <https://looking-glass.io/docs/B7/install_libvirt/>.
