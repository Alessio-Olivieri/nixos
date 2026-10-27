from pathlib import Path
import os
import runpy
import sys
from types import SimpleNamespace
import unittest
from unittest.mock import Mock, patch


class SleepGuardTests(unittest.TestCase):
    def setUp(self):
        self.guard = runpy.run_path(str(Path(__file__).parents[1] / 'sleep_guard.py'))['inhibit_sleep']
        self.fd = os.open('/dev/null', os.O_RDONLY)
        self.manager = Mock()
        self.manager.Inhibit.return_value.take.return_value = self.fd
        self.manager.Get.return_value = False
        self.bus = Mock()
        self.bus.get_object.return_value = self.manager
        self.dbus = SimpleNamespace(SystemBus=Mock(return_value=self.bus))
        self.addCleanup(self.close_if_open)

    def close_if_open(self):
        try:
            os.close(self.fd)
        except OSError:
            pass

    def test_lock_lives_through_cleanup_and_closes_on_failure(self):
        with patch.dict(sys.modules, {'dbus': self.dbus}):
            with self.assertRaisesRegex(RuntimeError, 'recovery failed'):
                with self.guard():
                    os.fstat(self.fd)
                    self.assertFalse(os.get_inheritable(self.fd))
                    self.assertEqual(self.manager.Inhibit.call_args.args[0], 'sleep:handle-lid-switch')
                    self.assertEqual(self.manager.Inhibit.call_args.args[3], 'block')
                    raise RuntimeError('recovery failed')
        with self.assertRaises(OSError):
            os.fstat(self.fd)
        self.bus.close.assert_called_once()

    def test_pending_sleep_prevents_handoff(self):
        self.manager.Get.return_value = True
        with patch.dict(sys.modules, {'dbus': self.dbus}):
            with self.assertRaisesRegex(RuntimeError, 'already being prepared'):
                with self.guard():
                    self.fail('Started handoff during suspend')
        with self.assertRaises(OSError):
            os.fstat(self.fd)

    def test_denied_inhibitor_prevents_handoff(self):
        self.manager.Inhibit.side_effect = RuntimeError('denied')
        with patch.dict(sys.modules, {'dbus': self.dbus}):
            with self.assertRaisesRegex(RuntimeError, 'denied'):
                with self.guard():
                    self.fail('Started without sleep protection')
        self.bus.close.assert_called_once()
