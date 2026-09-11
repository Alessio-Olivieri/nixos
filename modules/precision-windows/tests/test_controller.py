import contextlib
import io
import json
from pathlib import Path
import runpy
import socket
import tempfile
import unittest
from unittest.mock import patch


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
