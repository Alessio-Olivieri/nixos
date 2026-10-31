import importlib.util
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location("keyboard_native", Path(__file__).with_name("keyboard-native.py"))
native = importlib.util.module_from_spec(spec)
spec.loader.exec_module(native)


class NativeKeyboardTests(unittest.TestCase):
    def test_only_verified_i2c_lamparray_is_written(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            dev = root / "dev"
            sys = root / "sys"
            dev.mkdir()
            identities = ["0018:0000093A:00003016", "0003:00000B05:000019B6",
                          "0018:00000B05:000019B6", "0018:00000B05:000019B6"]
            for index, identity in enumerate(identities):
                name = f"hidraw{index + 4}"
                device = sys / name / "device"
                device.mkdir(parents=True)
                (device / "uevent").write_text(f"HID_ID={identity}\n")
                descriptor = bytes.fromhex("05 59 09 01") if index != 2 else b"other HID"
                (device / "report_descriptor").write_bytes(descriptor)
                (dev / name).touch()
            calls = []

            def ioctl(handle, request, report, mutate):
                calls.append((Path(handle.name).name, request, bytes(report), mutate))

            with patch.object(native.fcntl, "ioctl", side_effect=ioctl):
                self.assertEqual(native.restore_native(sys, dev), 1)
            self.assertEqual(calls, [("hidraw7", 0xC0024806, b"\x46\x01", True)])

    def test_absent_controller_is_safe(self):
        with tempfile.TemporaryDirectory() as directory:
            with patch.object(native.fcntl, "ioctl") as ioctl:
                self.assertEqual(native.restore_native(Path(directory), Path(directory)), 0)
                ioctl.assert_not_called()


if __name__ == "__main__":
    unittest.main()
