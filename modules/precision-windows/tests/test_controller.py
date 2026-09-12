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
        with patch.object(resource, 'getrlimit', return_value=(8388608, 8388608)):
            with patch.object(Path, 'mkdir', side_effect=AssertionError('Started setup before memlock check')):
                with self.assertRaisesRegex(RuntimeError, 'NVIDIA has not been detached'):
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
