import json
from pathlib import Path
import runpy
import tempfile
import unittest
from unittest.mock import Mock, patch


class ScanoutControlTests(unittest.TestCase):
    def setUp(self):
        folder = Path(__file__).parent
        with patch.object(Path, 'read_text', return_value='{}'):
            core = runpy.run_path(str(folder / 'session-test-control.py'))
            guard = runpy.run_path(str(folder / 'apply-component-update.py'))
        with patch('runpy.run_path', side_effect=[core, guard]):
            self.ns = {'__name__': 'scanout_test'}
            exec(compile((folder / 'scanout-test-control.py').read_text(), 'scanout-test-control.py', 'exec'), self.ns)
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.record = self.root / 'record'
        self.record.mkdir()
        config = {'candidate': '/nix/store/fake-candidate',
                  'baseline': str(Path('/run/current-system').resolve()),
                  'old_shell_pid': 1, 'old_shell_identity': ['fake', '0'],
                  'systemctl': 'never-run-real-systemctl'}
        core['serve'].__globals__.update(DIRECTORY=self.root, CONFIG=config)
        self.ns.update(CONFIG=config, RECORD=self.record)
        self.job = self.ns['ScanoutTest']()
        self.job.old_session_alive = Mock(return_value=True)
        self.job.switch = Mock(return_value={'exitcode': 0, 'output': ''})

    def test_two_previews_then_single_test(self):
        with patch.dict(self.ns, preflight=Mock()):
            self.job.request('activate')
            self.assertEqual([c.args[1] for c in self.job.switch.call_args_list],
                             ['dry-activate', 'dry-activate', 'test'])
            with self.assertRaisesRegex(RuntimeError, 'already been used'):
                self.job.request('activate')
        self.assertEqual(json.loads((self.record / 'state.json').read_text())['activations'], 1)

    def test_failed_preview_never_activates(self):
        self.job.switch.side_effect = RuntimeError('unsafe preview')
        with patch.dict(self.ns, preflight=Mock()), self.assertRaisesRegex(RuntimeError, 'unsafe preview'):
            self.job.request('activate')
        self.assertEqual(self.job.state['activations'], 0)
        self.assertEqual(self.job.switch.call_args.args[1], 'dry-activate')

    def test_failed_activation_still_consumes_grant(self):
        self.job.switch.side_effect = [{}, {}, RuntimeError('activation failed')]
        with patch.dict(self.ns, preflight=Mock()), self.assertRaisesRegex(RuntimeError, 'activation failed'):
            self.job.request('activate')
        self.assertEqual(json.loads((self.record / 'state.json').read_text())['activations'], 1)
        with self.assertRaisesRegex(RuntimeError, 'already been used'):
            self.job.request('activate')

    def test_replacement_desktop_never_restarted(self):
        self.job.logout_deadline = 999999999
        self.job.old_session_alive.return_value = False
        with patch.dict(self.ns, replacement_session_exists=Mock(return_value=True)), patch('subprocess.run') as command:
            self.job.tick()
        command.assert_not_called()
        self.assertEqual(self.job.state['phase'], 'replacement-session-present-no-restart')
        self.assertIsNone(self.job.logout_deadline)

    def test_no_replay_after_service_runtime_removed(self):
        with patch.dict(self.ns, preflight=Mock()), patch('os.geteuid', return_value=0), \
             patch('sys.argv', ['control', 'serve']), \
             patch.dict(self.ns['core'], identity=Mock(return_value=['fake', '0']), serve=Mock()):
            with self.assertRaises(FileExistsError):
                self.ns['main']()
            self.ns['core']['serve'].assert_not_called()

    def test_recovery_is_fixed_previewed_and_single(self):
        self.job.request('rollback')
        self.assertEqual([c.args for c in self.job.switch.call_args_list],
                         [(self.ns['CONFIG']['baseline'], 'dry-activate'),
                          (self.ns['CONFIG']['baseline'], 'test')])
        with self.assertRaisesRegex(RuntimeError, 'already been used'):
            self.job.request('rollback')

    def test_shell_companion_is_not_a_replacement_compositor(self):
        proc = self.root / 'proc'
        proc.mkdir()
        process = proc / '12345'
        process.mkdir()
        (process / 'exe').symlink_to('/nix/store/example/bin/gnome-shell-calendar-server')
        # The filesystem fixture belongs to the current user, like the session.
        with patch.object(Path, 'stat', return_value=Mock(st_uid=1001)), \
             patch.dict(self.ns['core'], identity=Mock(return_value=['fake', '1'])):
            self.assertFalse(self.ns['replacement_session_exists'](proc))

    def test_actual_shell_executable_is_a_replacement(self):
        proc = self.root / 'proc'
        proc.mkdir()
        process = proc / '12345'
        process.mkdir()
        (process / 'exe').symlink_to('/nix/store/example/bin/.gnome-shell-wrapped')
        with patch.object(Path, 'stat', return_value=Mock(st_uid=1001)), \
             patch.dict(self.ns['core'], identity=Mock(return_value=['fake', '1'])):
            self.assertTrue(self.ns['replacement_session_exists'](proc))

    def test_cpu_test_never_restarts_gdm_after_logout(self):
        self.ns['CONFIG']['restart_gdm'] = False
        self.job.logout_deadline = 999999999
        self.job.old_session_alive.return_value = False
        with patch('subprocess.run') as command:
            self.job.tick()
        command.assert_not_called()
        self.assertEqual(self.job.state['phase'], 'awaiting-login-no-gdm-restart')
        self.assertEqual(self.job.state['restarts'], 0)
        self.assertIsNone(self.job.logout_deadline)

    def test_cpu_test_timeout_never_restarts_gdm(self):
        self.ns['CONFIG']['restart_gdm'] = False
        self.job.logout_deadline = 1
        with patch('subprocess.run') as command:
            self.job.tick()
        command.assert_not_called()
        self.assertEqual(self.job.state['phase'], 'logout-timeout-no-restart')

    def test_cpu_test_waits_without_touching_original_session(self):
        self.ns['CONFIG']['restart_gdm'] = False
        self.job.logout_deadline = 999999999
        with patch('subprocess.run') as command:
            self.job.tick()
        command.assert_not_called()
        self.assertEqual(self.job.logout_deadline, 999999999)

    def test_refresh_targets_only_expected_nvidia_card(self):
        self.ns['CONFIG']['udevadm'] = '/immutable/udevadm'
        with patch.object(self.ns['core']['SessionTest'], 'switch', return_value={}), \
             patch('subprocess.run') as command, \
             patch('subprocess.check_output', return_value='ID_PATH=pci-0000:01:00.0\nMUTTER_DEVICE_SCANOUT_ONLY=1\n'):
            self.ns['ScanoutTest'].switch(self.job, self.ns['CONFIG']['candidate'], 'test')
        command.assert_called_once_with(['/immutable/udevadm', 'trigger', '--action=change',
                                         '--settle', '/sys/class/drm/card0'], check=True, timeout=20)

    def test_missing_scanout_flag_refuses_success(self):
        self.ns['CONFIG']['udevadm'] = '/immutable/udevadm'
        with patch.object(self.ns['core']['SessionTest'], 'switch', return_value={}), \
             patch('subprocess.run'), \
             patch('subprocess.check_output', return_value='ID_PATH=pci-0000:01:00.0\n'), \
             self.assertRaisesRegex(RuntimeError, 'no logout permitted'):
            self.ns['ScanoutTest'].switch(self.job, self.ns['CONFIG']['candidate'], 'test')

    def test_rollback_does_not_refresh_failed_candidate_rule(self):
        self.ns['CONFIG']['udevadm'] = '/immutable/udevadm'
        with patch.object(self.ns['core']['SessionTest'], 'switch', return_value={}), \
             patch('subprocess.run') as command:
            self.ns['ScanoutTest'].switch(self.job, self.ns['CONFIG']['baseline'], 'test')
        command.assert_not_called()


if __name__ == '__main__':
    unittest.main()
