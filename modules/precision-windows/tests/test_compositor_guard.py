from pathlib import Path
import runpy
import tempfile
import unittest
from unittest.mock import Mock, patch


class CompositorGuardTests(unittest.TestCase):
    def setUp(self):
        self.verify = runpy.run_path(str(Path(__file__).parents[1] / 'compositor_guard.py'))['verify']
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.proc = Path(self.temp.name)
        self.expected = '/nix/store/repaired-mutter/lib/libmutter-18.so.0.0.0'

    def shell(self, pid='42', mapped=None, name='.gnome-shell-wrapped'):
        folder = self.proc / pid
        folder.mkdir()
        (folder / 'exe').symlink_to('/nix/store/gnome/bin/' + name)
        (folder / 'comm').write_text(name[:15] + '\n')
        (folder / 'maps').write_text('0000-1000 r-xp 0 00:00 0 ' + (mapped or self.expected) + '\n')

    def check(self, config=None):
        with patch.object(Path, 'stat', return_value=Mock(st_uid=1001)):
            return self.verify(config if config is not None else {'required_mutter': self.expected}, self.proc)

    def test_exact_mapping_passes(self):
        self.shell()
        self.assertEqual(self.check(), 42)

    def test_old_mapping_refuses(self):
        self.shell(mapped='/nix/store/old-mutter/lib/libmutter-18.so.0.0.0')
        with self.assertRaisesRegex(RuntimeError, 'exact repaired Mutter'):
            self.check()

    def test_deleted_mapping_refuses(self):
        self.shell(mapped=self.expected + ' (deleted)')
        with self.assertRaises(RuntimeError):
            self.check()

    def test_missing_compositor_refuses(self):
        with self.assertRaises(RuntimeError):
            self.check()

    def test_duplicate_compositor_refuses(self):
        self.shell()
        self.shell('43')
        with self.assertRaises(RuntimeError):
            self.check()

    def test_calendar_helper_does_not_count(self):
        self.shell(name='gnome-shell-calendar-server')
        with self.assertRaises(RuntimeError):
            self.check()

    def test_missing_pin_refuses(self):
        self.shell()
        with self.assertRaisesRegex(RuntimeError, 'explicitly pinned'):
            self.check({})
