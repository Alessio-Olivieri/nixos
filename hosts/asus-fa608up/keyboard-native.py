"""Return the FA608UP I2C LampArray to native EC/asusctl control."""

import fcntl
from pathlib import Path
import time


def restore_native(sys_root=Path("/sys/class/hidraw"), dev_root=Path("/dev")):
    restored = 0
    for node in sorted(sys_root.glob("hidraw*")):
        device = node / "device"
        try:
            properties = dict(line.split("=", 1) for line in
                              (device / "uevent").read_text().splitlines() if "=" in line)
            if properties.get("HID_ID") != "0018:00000B05:000019B6":
                continue
            # HID Lighting and Illumination page, LampArray application.
            if bytes.fromhex("05 59 09 01") not in (device / "report_descriptor").read_bytes():
                continue
            with (dev_root / node.name).open("rb+", buffering=0) as handle:
                report = bytearray([0x46, 1])  # LampArrayControl: AutonomousMode=true
                request = (3 << 30) | (len(report) << 16) | (ord("H") << 8) | 6
                fcntl.ioctl(handle, request, report, True)  # HIDIOCSFEATURE
            print(f"{node.name}: enabled native ASUS keyboard lighting", flush=True)
            restored += 1
        except FileNotFoundError:
            continue  # The device can disappear during enumeration/resume.
    return restored


if __name__ == "__main__":
    if Path("/sys/class/dmi/id/board_name").read_text().strip() != "FA608UP":
        raise SystemExit("This workaround is restricted to the verified FA608UP")
    for attempt in range(20):
        if restore_native():
            break
        time.sleep(0.25)
    else:
        raise SystemExit("ASUS I2C LampArray controller was not found")
