import contextlib
import io
import json
from pathlib import Path
import runpy
import resource
import socket
import tempfile
import unittest
from unittest.mock import patch
from unittest.mock import Mock


class OfflineControllerTests(unittest.TestCase):
    def test_gaming_viewer_uses_existing_spice_audio_not_failed_usb_audio(self):
        function = self.controller['start_viewer']
        with patch.dict(function.__globals__, {'CONFIG': {'looking_glass': 'looking-glass'}}):
            with patch('subprocess.Popen') as launch:
                function('gaming')
        self.assertIn('spice:usbAudio=no', launch.call_args.args[0])

    def setUp(self):
        with patch.object(Path, 'read_text', return_value='{}'):
            self.controller = runpy.run_path(str(Path(__file__).parents[1] / 'controller.py'), run_name='controller_test')
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.function = self.controller['command']
        self.function.__globals__.update(STATE=self.root, RUNTIME=self.root)

    def test_stale_socket_console_explains_stopped_guest(self):
        (self.root / 'status.json').write_text('{"state":"stopped"}')
        with socket.socket(socket.AF_UNIX) as stale:
            stale.bind(str(self.root / 'control.sock'))
        with self.assertRaisesRegex(RuntimeError, 'Windows is stopped'):
            self.function('console')

    def test_status_works_after_socket_removed(self):
        (self.root / 'status.json').write_text('{"state":"stopped"}')
        output = io.StringIO()
        with contextlib.redirect_stdout(output):
            self.function('status')
        self.assertEqual(json.loads(output.getvalue())['state'], 'stopped')

    def test_stale_running_status_is_not_claimed_live(self):
        (self.root / 'status.json').write_text('{"state":"running"}')
        output = io.StringIO()
        with contextlib.redirect_stdout(output):
            self.function('status')
        self.assertEqual(json.loads(output.getvalue())['state'], 'controller-unavailable')

    def test_small_memlock_refuses_before_any_handoff(self):
        with patch.dict(self.controller['run'].__globals__, {'CONFIG': {'gaming_enabled': True}}), patch.object(resource, 'getrlimit', return_value=(8388608, 8388608)):
            with patch.object(Path, 'mkdir', side_effect=AssertionError('Started setup before memlock check')):
                with self.assertRaisesRegex(RuntimeError, 'NVIDIA has not been detached'):
                    self.controller['run']('gaming')

    def test_disabled_gaming_refuses_before_setup_or_display_changes(self):
        with patch.object(Path, 'mkdir', side_effect=AssertionError('State mutated')):
            with patch('subprocess.run', side_effect=AssertionError('Process launched')):
                with self.assertRaisesRegex(RuntimeError, 'Gaming is disabled'):
                    self.controller['run']('gaming')

    def test_failed_guest_status_remains_visible(self):
        (self.root / 'status.json').write_text('{"state":"guest-failed","qemu_exit":1}')
        output = io.StringIO()
        with contextlib.redirect_stdout(output):
            self.function('status')
        self.assertEqual(json.loads(output.getvalue())['state'], 'guest-failed')

    def test_returning_gpu_reports_live_transition_without_control_socket(self):
        (self.root / 'status.json').write_text(json.dumps({'state':'returning-nvidia','pid':123,'process_identity':['boot','42']}))
        output = io.StringIO()
        with patch.dict(self.function.__globals__, {'process_identity': lambda pid: ['boot','42']}):
            with contextlib.redirect_stdout(output):
                self.function('status')
        self.assertEqual(json.loads(output.getvalue())['state'], 'returning-nvidia')

    def test_reused_pid_cannot_validate_old_controller(self):
        (self.root / 'status.json').write_text(json.dumps({'state':'returning-nvidia','pid':123,'process_identity':['old-boot','42']}))
        output = io.StringIO()
        with patch.dict(self.function.__globals__, {'process_identity': lambda pid: ['new-boot','42']}):
            with contextlib.redirect_stdout(output):
                self.function('status')
        self.assertEqual(json.loads(output.getvalue())['state'], 'controller-unavailable')

    def test_missing_calculator_never_sends_attach(self):
        action = self.controller['calculator_action']
        request = Mock()
        with patch.dict(action.__globals__, {'calculators': lambda: {}, 'rpc': request}):
            with self.assertRaisesRegex(RuntimeError, 'no longer connected'):
                action('3:5')
        request.assert_not_called()

    def test_calculator_attach_is_constrained_to_selected_identity(self):
        action = self.controller['calculator_action']
        request = Mock()
        with patch.dict(action.__globals__, {'calculators': lambda: {'3:5': (3, 5)}, 'rpc': request}):
            with patch('os.access', return_value=True):
                action('3:5')
        properties = request.call_args.args[2]
        self.assertEqual((properties['hostbus'], properties['hostaddr']), (3, 5))
        self.assertEqual((properties['vendorid'], properties['productid']), (0x0451, 0xe022))

    def test_cancelled_usb_chooser_does_not_connect(self):
        choose = self.controller['choose_calculator']
        command = Mock()
        with patch.dict(choose.__globals__, {'CONFIG': {'chooser': 'zenity'}, 'calculators': lambda: {'3:5': (3, 5)}, 'command': command}):
            with patch('subprocess.run', return_value=Mock(returncode=1, stdout='')):
                choose()
        command.assert_not_called()

    def test_both_modes_automatically_forward_only_calculator_model(self):
        function = self.controller['qemu_arguments']
        with patch.dict(function.__globals__, {'CONFIG': {'qemu': 'qemu', 'firmware': 'firmware'}}):
            for mode in ('light', 'gaming'):
                devices = [arg for arg in function(mode) if arg.startswith('usb-host,')]
                self.assertEqual(devices, ['usb-host,id=ti-nspire,bus=spicepass.0,vendorid=0x0451,productid=0xe022'])

    def test_enable_auto_does_not_duplicate_existing_device(self):
        action = self.controller['calculator_action']
        request = Mock(return_value=[{'name': 'ti-nspire'}])
        with patch.dict(action.__globals__, {'rpc': request}):
            action('auto')
        self.assertEqual(request.call_count, 1)

    def test_enable_auto_has_no_stale_address_constraint(self):
        action = self.controller['calculator_action']
        request = Mock(return_value=[])
        with patch.dict(action.__globals__, {'rpc': request}):
            action('auto')
        self.assertEqual(request.call_args.args[2], {
            'driver': 'usb-host', 'id': 'ti-nspire', 'bus': 'spicepass.0',
            'vendorid': 0x0451, 'productid': 0xe022})

    def test_only_exact_compositor_pid_is_exempt_from_display_preflight(self):
        apps = [{'name': 'GNOME', 'kind': 'application', 'pids': [42], 'pid_count': 1},
                {'name': 'Ollama', 'kind': 'application', 'pids': [43], 'pid_count': 1}]
        self.assertEqual(self.controller['non_compositor_owners'](apps, 42), [apps[1]])

    def test_grouped_or_truncated_owner_list_is_never_exempt(self):
        apps = [{'name': 'GNOME', 'kind': 'application', 'pids': [42], 'pid_count': 65}]
        self.assertEqual(self.controller['non_compositor_owners'](apps, 42), apps)

    def test_busy_application_prevents_even_temporary_monitor_changes(self):
        action = self.controller['detach_host_hdmi']
        monitor = Mock(return_value={'shellPid': 42})
        inspect = Mock(return_value=json.dumps({'owners': [
            {'name': 'Ollama', 'kind': 'application', 'pids': [43]}]}))
        with patch.dict(action.__globals__, {'host_display': monitor, 'gpu': inspect}):
            with patch('subprocess.check_output', return_value='1690\n'):
                with self.assertRaisesRegex(RuntimeError, 'Ollama.*43'):
                    action()
        monitor.assert_called_once_with('snapshot')
        inspect.assert_called_once_with('inspect')

    def test_only_actual_logind_and_pid1_duplicates_are_allowed_before_detach(self):
        apps = [{'name': 'systemd', 'kind': 'application', 'pids': [1]},
                {'name': 'systemd-logind', 'kind': 'application', 'pids': [1690]},
                {'name': 'systemd-logind', 'kind': 'application', 'pids': [9999]}]
        self.assertEqual(self.controller['non_compositor_owners'](apps, 42, 1690), [apps[2]])

    def test_xwayland_is_not_exempt_from_gpu_ownership(self):
        apps = [{'name': 'Xwayland', 'kind': 'application', 'pids': [23758]}]
        self.assertEqual(self.controller['non_compositor_owners'](apps, 23329, 1690), apps)

    def test_shutdown_does_not_contact_already_stopped_guest(self):
        action = self.controller['request_guest_shutdown']
        request = Mock()
        with patch.dict(action.__globals__, {'rpc': request}):
            self.assertFalse(action(Mock(poll=Mock(return_value=0))))
        request.assert_not_called()

    def test_clean_exit_during_shutdown_request_is_not_failure(self):
        action = self.controller['request_guest_shutdown']
        with patch.dict(action.__globals__, {'rpc': Mock(side_effect=FileNotFoundError('QMP closed'))}):
            self.assertFalse(action(Mock(poll=Mock(side_effect=[None, 0]))))

    def test_shutdown_request_error_keeps_live_guest_failure_visible(self):
        action = self.controller['request_guest_shutdown']
        with patch.dict(action.__globals__, {'rpc': Mock(side_effect=ConnectionRefusedError('QMP failed'))}):
            with self.assertRaisesRegex(ConnectionRefusedError, 'QMP failed'):
                action(Mock(poll=Mock(return_value=None)))

    def test_shutdown_request_sent_once_to_live_guest(self):
        action = self.controller['request_guest_shutdown']
        request = Mock()
        with patch.dict(action.__globals__, {'rpc': request}):
            self.assertTrue(action(Mock(poll=Mock(return_value=None))))
        request.assert_called_once_with(self.root / 'qmp.sock', 'system_powerdown', qmp=True)

    def test_display_failure_cannot_be_overwritten_by_cuda_success(self):
        action = self.controller['finish_status']
        state = {'gpu_recovery': 'passed'}
        with patch.dict(action.__globals__, {'recover_host_display': Mock(side_effect=RuntimeError('GNOME disappeared'))}):
            message, critical = action(state, Mock(returncode=0), True, {'shellPid': 42})
        self.assertEqual(state['state'], 'display-recovery-failed')
        self.assertEqual(state['qemu_exit'], 0)
        self.assertEqual(state['gpu_recovery'], 'passed')
        self.assertEqual(state['display_recovery'], 'failed')
        self.assertIn('GNOME disappeared', message)
        self.assertTrue(critical)
        self.assertNotIn('available to Linux', message)

    def test_display_failure_status_survives_controller_exit(self):
        (self.root / 'status.json').write_text('{"state":"display-recovery-failed","qemu_exit":0}')
        output = io.StringIO()
        with contextlib.redirect_stdout(output):
            self.function('status')
        self.assertEqual(json.loads(output.getvalue())['state'], 'display-recovery-failed')
        with self.assertRaisesRegex(RuntimeError, 'Do not retry Gaming'):
            self.function('console')

    def test_replaced_session_is_rejected_even_without_hdmi_detach(self):
        action = self.controller['recover_host_display']
        snapshot = {'shellPid': 42, 'displayOwner': ':1.7', 'displayBusId': 'old', 'layoutDetached': False}
        current = dict(snapshot, shellPid=99, displayBusId='new')
        monitor = Mock(return_value=current)
        with patch.dict(action.__globals__, {'host_display': monitor}):
            with self.assertRaisesRegex(RuntimeError, 'session was not preserved'):
                action(snapshot)
        monitor.assert_called_once_with('snapshot')

    def test_same_session_without_detach_does_not_apply_layout(self):
        action = self.controller['recover_host_display']
        snapshot = {'shellPid': 42, 'displayOwner': ':1.7', 'displayBusId': 'same', 'layoutDetached': False}
        monitor = Mock(return_value=snapshot)
        with patch.dict(action.__globals__, {'host_display': monitor}):
            action(snapshot)
        monitor.assert_called_once_with('snapshot')

    def test_clean_display_recovery_preserves_guest_error(self):
        action = self.controller['finish_status']
        state = {}
        with patch.dict(action.__globals__, {'recover_host_display': Mock()}):
            message, critical = action(state, Mock(returncode=1), True, {'shellPid': 42})
        self.assertEqual(state['state'], 'guest-failed')
        self.assertEqual(state['display_recovery'], 'passed')
        self.assertTrue(critical)
        self.assertIn('error 1', message)
