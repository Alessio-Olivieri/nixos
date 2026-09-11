import json
import os
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

import collector


class CollectorTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.sys = self.root / "sys"
        self.proc = self.root / "proc"
        self.proc.mkdir()
        self.device = self.sys / "bus/pci/devices/0000:01:00.0"
        (self.device / "power").mkdir(parents=True)
        (self.device / "vendor").write_text("0x10de\n")
        (self.device / "power/runtime_status").write_text("active\n")
        (self.device / "driver").symlink_to("/sys/bus/pci/drivers/nvidia")
        (self.device / "drm/renderD129").mkdir(parents=True)
        (self.device / "iommu_group").symlink_to("/sys/kernel/iommu_groups/7")

    def collect(self):
        return collector.collect(sys_root=self.sys, proc_root=self.proc)

    def process(self, pid, executable, targets, arguments=None):
        entry = self.proc / str(pid)
        (entry / "fd").mkdir(parents=True)
        (entry / "exe").symlink_to(executable)
        (entry / "comm").write_text(Path(executable).name)
        argv = arguments if arguments is not None else [executable]
        (entry / "cmdline").write_bytes(("\0".join(argv) + "\0").encode())
        for index, target in enumerate(targets):
            (entry / "fd" / str(index)).symlink_to(target)

    def test_suspended_skips_process_collection(self):
        (self.device / "power/runtime_status").write_text("suspended\n")
        with patch.object(collector, "scan_processes", side_effect=AssertionError("must not scan")):
            result = self.collect()
        self.assertEqual(result["state"], "intel")
        self.assertFalse(result["visibility"]["scanned"])

    def test_nix_wrapped_names_and_multiple_pids_are_grouped(self):
        self.process(12, "/nix/store/aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa-steam-1/bin/.steam-wrapped", ["/dev/nvidia0"])
        self.process(13, "/nix/store/bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb-steam-1/bin/steamwebhelper", ["/dev/dri/renderD129"])
        self.process(14, "/nix/store/cccccccccccccccccccccccccccccccc-firefox-1/bin/.firefox-wrapped", ["/dev/dri/renderD128"])
        apps = self.collect()["applications"]
        self.assertEqual(apps, [{"name": "Steam", "kind": "application", "pids": [12, 13], "pid_count": 2}])

    def test_global_nvidia_control_handle_is_not_gpu_specific(self):
        self.process(20, "/bin/monitor", ["/dev/nvidiactl", "/dev/nvidia-uvm"])
        result = self.collect()
        self.assertEqual(result["applications"], [])
        self.assertEqual(result["state"], "nvidia")  # Awake is not the same as unused/off.

    def test_auxiliary_function_keeps_awake_state_visible(self):
        (self.device / "power/runtime_status").write_text("suspended")
        auxiliary = self.device.parent / "0000:01:00.1/power"
        auxiliary.mkdir(parents=True)
        (auxiliary / "runtime_status").write_text("active")
        result = self.collect()
        self.assertEqual(result["state"], "nvidia")
        self.assertIn("another PCI function", result["detail"])

    def test_vfio_reserved_is_not_a_claim_that_windows_is_running(self):
        (self.device / "driver").unlink()
        (self.device / "driver").symlink_to("/sys/bus/pci/drivers/vfio-pci")
        result = self.collect()
        self.assertEqual(result["state"], "passthrough")
        self.assertEqual(result["applications"], [])
        self.assertIn("no VM owner identified", result["detail"])

    def test_legacy_and_cdev_vfio_owners(self):
        (self.device / "driver").unlink()
        (self.device / "driver").symlink_to("/sys/bus/pci/drivers/vfio-pci")
        (self.device / "vfio-dev/vfio2").mkdir(parents=True)
        self.process(33, "/nix/store/hash-qemu/bin/qemu-system-x86_64", ["/dev/vfio/7"],
                     ["qemu", "-name", "guest=Windows,debug-threads=on", "-secret", "PRIVATE"])
        self.process(34, "/bin/qemu-system-x86_64", ["/dev/vfio/devices/vfio2"])
        result = self.collect()
        self.assertEqual({app["name"] for app in result["applications"]}, {"VM: Windows", "Virtual machine"})
        self.assertTrue(all(app["kind"] == "vm" for app in result["applications"]))
        self.assertNotIn("PRIVATE", json.dumps(result))

    def test_suspended_vfio_still_reports_reservation(self):
        (self.device / "driver").unlink()
        (self.device / "driver").symlink_to("/sys/bus/pci/drivers/vfio-pci")
        (self.device / "power/runtime_status").write_text("suspended")
        self.assertEqual(self.collect()["state"], "passthrough")

    def test_vfio_diagnostic_is_not_a_running_vm(self):
        (self.device / "driver").unlink()
        (self.device / "driver").symlink_to("/sys/bus/pci/drivers/vfio-pci")
        self.process(35, "/bin/device-check", ["/dev/vfio/7"])
        app = self.collect()["applications"][0]
        self.assertEqual(app["kind"], "vfio")
        self.assertNotIn("VM", app["name"])

    def test_unbound_suspended_device_is_unavailable(self):
        (self.device / "driver").unlink()
        (self.device / "power/runtime_status").write_text("suspended")
        self.assertEqual(self.collect()["state"], "unknown")

    def test_showtime_python_wrapper_name(self):
        self.assertEqual(collector.clean_name("/bin/python3", ["python3", "/nix/store/hash-showtime/bin/.showtime-wrapped"], "python3"), "Showtime")

    def test_embedded_ollama_runner_has_readable_application_name(self):
        self.assertEqual(collector.clean_name("/nix/store/hash-ollama-0.30.6/lib/ollama/llama-server", [], "llama-server"), "Ollama")
        self.assertEqual(collector.clean_name("/nix/store/hash-llama-cpp-1/bin/llama-server", [], "llama-server"), "llama.cpp")

    def test_missing_or_wrong_device_reports_unknown(self):
        (self.device / "vendor").write_text("0x8086")
        self.assertEqual(self.collect()["state"], "unknown")
        (self.device / "vendor").unlink()
        self.assertEqual(self.collect()["state"], "unknown")

    def test_unreadable_processes_are_reported(self):
        self.process(30, "/bin/secret", ["/dev/nvidia0"])
        original = Path.iterdir
        denied_path = self.proc / "30/fd"
        def guarded(path):
            if path == denied_path:
                raise PermissionError("fixture")
            return original(path)
        with patch.object(Path, "iterdir", guarded):
            result = self.collect()
        self.assertFalse(result["visibility"]["complete"])
        self.assertEqual(result["visibility"]["denied"], 1)

    def test_change_during_sample_is_not_reported_as_stable(self):
        original = collector.device_snapshot
        count = 0
        def snapshot(device):
            nonlocal count
            count += 1
            if count == 2:
                (device / "power/runtime_status").write_text("suspended")
            return original(device)
        with patch.object(collector, "device_snapshot", snapshot):
            result = self.collect()
        self.assertEqual(result["state"], "unknown")
        self.assertIn("changed", result["detail"])

    def test_script_and_wine_names_do_not_leak_store_or_arguments(self):
        name = collector.clean_name("/nix/store/hash-python/bin/python3.13",
                                    ["python", "/nix/store/hash-lutris/bin/.lutris-wrapped", "--private"], "python")
        self.assertEqual(name, "Lutris")
        name = collector.clean_name("/nix/store/hash-wine/bin/wine64-preloader",
                                    ["wine", "C:\\Games\\Stellaris\\stellaris.exe"], "wine")
        self.assertEqual(name, "stellaris.exe")
        name = collector.clean_name("/bin/python3", ["python3", "-c", "PRIVATE"], "python")
        self.assertEqual(name, "Python")

    def test_atomic_status_file_is_readable_and_replaced(self):
        status = self.root / "status.json"
        collector.write_status(status, {"state": "intel"})
        collector.write_status(status, {"state": "nvidia"})
        self.assertEqual(json.loads(status.read_text()), {"state": "nvidia"})
        self.assertEqual(status.stat().st_mode & 0o777, 0o644)
        self.assertEqual(list(self.root.glob(".status-*")), [])

    def test_unknown_runtime_does_not_imply_intel(self):
        (self.device / "power/runtime_status").unlink()
        self.assertEqual(self.collect()["state"], "unknown")


if __name__ == "__main__":
    unittest.main()
