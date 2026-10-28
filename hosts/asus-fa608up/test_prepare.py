import importlib.util
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location("prepare", Path(__file__).with_name("prepare.py"))
prepare = importlib.util.module_from_spec(spec)
spec.loader.exec_module(prepare)


class PreparationTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.sysfs = self.root / "sys"
        self.pci = self.sysfs / "bus/pci/devices"
        self.pci.mkdir(parents=True)
        model = self.sysfs / "class/dmi/id/product_name"
        model.parent.mkdir(parents=True)
        model.write_text("ASUS TUF Gaming A16 FA608UP_FA608UP")
        self.output = self.root / "profile"
        self.output.mkdir()
        (self.output / "default.nix").write_text("{}")
        (self.output / "machine.nix").write_text("configured = false;")
        (self.output / "hardware-configuration.nix").write_text("original")
        self.device("0000:65:00.0", "0x1002", "0x030000")
        self.device("0000:01:00.0", "0x10de", "0x030200")

    def device(self, address, vendor, device_class):
        device = self.pci / address
        device.mkdir()
        (device / "vendor").write_text(vendor)
        (device / "class").write_text(device_class)

    def test_filters_out_nvidia_audio_and_amd_bridges(self):
        self.device("0000:01:00.1", "0x10de", "0x040300")
        self.device("0000:00:01.0", "0x1002", "0x060400")
        self.assertEqual(prepare.detect_gpus(self.pci), ("0000:65:00.0", "0000:01:00.0"))

    def test_rejects_ambiguous_gpu(self):
        self.device("0000:02:00.0", "0x10de", "0x030000")
        with self.assertRaises(ValueError):
            prepare.detect_gpus(self.pci)

    def test_rejects_missing_gpu(self):
        (self.pci / "0000:01:00.0/vendor").write_text("0xffff")
        with self.assertRaises(ValueError):
            prepare.detect_gpus(self.pci)

    @patch.object(prepare.subprocess, "run")
    def test_generation_failure_preserves_files(self, run):
        run.side_effect = subprocess.CalledProcessError(1, "nixos-generate-config")
        with self.assertRaises(subprocess.CalledProcessError):
            prepare.prepare(self.root, self.output, self.sysfs)
        self.assertEqual((self.output / "hardware-configuration.nix").read_text(), "original")
        self.assertEqual((self.output / "machine.nix").read_text(), "configured = false;")

    @patch.object(prepare.subprocess, "run")
    def test_success_backs_up_and_uses_requested_root(self, run):
        run.return_value = subprocess.CompletedProcess([], 0, stdout="{ ... }: {}\n")
        prepare.prepare(self.root, self.output, self.sysfs)
        self.assertEqual(run.call_args.args[0], ["nixos-generate-config", "--root", str(self.root), "--show-hardware-config"])
        self.assertIn('amdPciAddress = "0000:65:00.0"', (self.output / "machine.nix").read_text())
        self.assertEqual(len(list(self.output.glob("*.bak"))), 2)
        with self.assertRaises(ValueError):
            prepare.prepare(self.root, self.output, self.sysfs)

    @patch.object(prepare.subprocess, "run")
    def test_wrong_machine_never_runs_generator(self, run):
        (self.sysfs / "class/dmi/id/product_name").write_text("Precision 7560")
        with self.assertRaises(ValueError):
            prepare.prepare(self.root, self.output, self.sysfs)
        run.assert_not_called()


if __name__ == "__main__":
    unittest.main()
