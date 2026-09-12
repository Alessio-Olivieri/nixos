from pathlib import Path
import runpy
import sys
import tempfile
from types import SimpleNamespace
import unittest
from unittest.mock import patch


class PassiveDisplayTests(unittest.TestCase):
    def setUp(self):
        collector = SimpleNamespace(read_text=lambda path: path.read_text().strip())
        with patch.dict(sys.modules, {'collector': collector}), patch.object(Path, 'read_text', return_value='{}'):
            self.gpu = runpy.run_path(str(Path(__file__).parents[1] / 'gpu.py'), run_name='offline_gpu')
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        root = Path(self.temp.name)
        self.connector = root / '0000:01:00.0/drm/card0/card0-HDMI-A-1'
        self.connector.mkdir(parents=True)
        (self.connector / 'status').write_text('connected\n')
        (self.connector / 'enabled').write_text('disabled\n')
        self.active = self.gpu['active_displays']
        self.active.__globals__.update(SYS=root)

    def test_connected_but_disabled_is_not_active(self):
        self.assertEqual(self.active(), [])

    def test_active_output_is_reported_without_mutation(self):
        (self.connector / 'enabled').write_text('enabled\n')
        with patch('subprocess.run') as command:
            self.assertEqual(self.active(), ['card0-HDMI-A-1'])
        command.assert_not_called()
        self.assertEqual((self.connector / 'status').read_text(), 'connected\n')

    def test_disconnected_output_is_not_active(self):
        (self.connector / 'status').write_text('disconnected\n')
        with patch('subprocess.run') as command:
            self.assertEqual(self.active(), [])
        command.assert_not_called()
        self.assertEqual((self.connector / 'status').read_text(), 'disconnected\n')

    def test_missing_drm_resources_are_not_probed(self):
        with patch.dict(self.active.__globals__, {'SYS': Path(self.temp.name) / 'missing'}):
            self.assertEqual(self.active(), [])

    def test_disabled_prepare_refuses_before_device_or_owner_operations(self):
        prepare = self.gpu['prepare']
        with patch.dict(prepare.__globals__, {'validate': lambda: self.fail('Touched hardware')}):
            with self.assertRaisesRegex(RuntimeError, 'handoff is disabled'):
                prepare()


if __name__ == '__main__':
    unittest.main()
