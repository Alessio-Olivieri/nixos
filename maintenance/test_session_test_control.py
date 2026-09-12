import json
from pathlib import Path
import runpy
import tempfile
import unittest
from unittest.mock import Mock, patch


class SessionTestControlTests(unittest.TestCase):
    def setUp(self):
        with patch.object(Path, 'read_text', return_value='{}'):
            self.ns = runpy.run_path(str(Path(__file__).with_name('session-test-control.py')))
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.config = {'candidate': '/nix/store/fake-candidate',
                       'baseline': str(Path('/run/current-system').resolve()),
                       'systemctl': 'never-run-real-systemctl',
                       'old_shell_pid': 1, 'old_shell_identity': ['fake-boot', '0']}
        self.cls = self.ns['SessionTest']
        self.cls.__init__.__globals__.update(CONFIG=self.config, DIRECTORY=Path(self.temp.name))
        self.job = self.cls()
        self.job.save = Mock()
        self.job.switch = Mock(return_value={'exitcode': 0})
        self.job.old_session_alive = Mock(return_value=True)

    def test_exactly_one_test_activation(self):
        self.job.request('activate')
        self.job.switch.assert_called_once_with(self.config['candidate'], 'test')
        with self.assertRaisesRegex(RuntimeError, 'already been used'):
            self.job.request('activate')

    def test_failed_activation_consumes_budget(self):
        self.job.switch.side_effect = RuntimeError('activation failed')
        with self.assertRaisesRegex(RuntimeError, 'activation failed'):
            self.job.request('activate')
        with self.assertRaisesRegex(RuntimeError, 'already been used'):
            self.job.request('activate')

    def test_session_replacement_prevents_activation(self):
        self.job.old_session_alive.return_value = False
        with self.assertRaisesRegex(RuntimeError, 'no longer present'):
            self.job.request('activate')
        self.job.switch.assert_not_called()

    def test_no_restart_while_original_desktop_lives(self):
        self.job.request('activate')
        self.job.request('arm-logout')
        with patch('subprocess.run') as command:
            self.job.tick()
        command.assert_not_called()

    def test_restart_once_only_after_normal_logout(self):
        self.job.request('activate')
        self.job.request('arm-logout')
        self.job.old_session_alive.return_value = False
        with patch('subprocess.run', return_value=Mock(returncode=0)) as command:
            self.job.tick()
            self.job.tick()
        command.assert_called_once_with([self.config['systemctl'], 'restart', 'display-manager.service'],
                                        timeout=60, check=False)
        self.assertEqual(self.job.state['phase'], 'awaiting-login')

    def test_logout_timeout_does_not_force_restart(self):
        self.job.logout_deadline = 1
        with patch('time.monotonic', return_value=2), patch('subprocess.run') as command:
            self.job.tick()
        command.assert_not_called()
        self.assertEqual(self.job.state['phase'], 'logout-timeout-no-restart')

    def test_rollback_fixed_and_does_not_restart_desktop(self):
        self.job.logout_deadline = 999
        with patch('subprocess.run') as command:
            self.job.request('rollback')
        command.assert_not_called()
        self.job.switch.assert_called_once_with(self.config['baseline'], 'test')
        self.assertIsNone(self.job.logout_deadline)
        with self.assertRaisesRegex(RuntimeError, 'already been used'):
            self.job.request('rollback')

    def test_no_reboot_or_arbitrary_command(self):
        for action in ('reboot', 'poweroff', 'sh', 'activate /other/system'):
            with self.assertRaisesRegex(RuntimeError, 'Unknown operation'):
                self.job.request(action)
        self.job.switch.assert_not_called()

    def test_no_logout_arm_before_activation(self):
        with self.assertRaisesRegex(RuntimeError, 'No unused'):
            self.job.request('arm-logout')

    def test_armed_test_cannot_silently_drop_authority(self):
        self.job.request('activate')
        self.job.request('arm-logout')
        with self.assertRaisesRegex(RuntimeError, 'armed'):
            self.job.request('finish')
        self.assertFalse(self.job.finishing)


if __name__ == '__main__':
    unittest.main()
