import json
from pathlib import Path
import runpy
import tempfile
import unittest
from unittest.mock import Mock, patch


class GuestSyncTests(unittest.TestCase):
    def setUp(self):
        with patch.object(Path, 'read_text', return_value='{}'):
            self.module = runpy.run_path(str(Path(__file__).parents[1] / 'guest_sync.py'), run_name='test_sync')
        self.initial = {'state': 'running', 'pid': 1, 'qemu_pid': 2,
                        'process_identity': ['boot', 'start'], 'mode': 'gaming'}

    def test_same_guest_requires_every_identity_field(self):
        same = self.module['same_guest']
        self.assertTrue(same(self.initial, dict(self.initial)))
        for field in self.initial:
            changed = dict(self.initial, **{field: 'changed'})
            self.assertFalse(same(self.initial, changed), field)

    def test_stopped_guest_never_launches_or_provisions(self):
        with tempfile.TemporaryDirectory() as temporary:
            function = self.module['main']
            with patch.dict(function.__globals__, {'CONFIG': {'controller': 'controller'}}):
                with patch('runpy.run_path', return_value={'STATE': Path(temporary)}):
                    with patch('subprocess.run') as execute:
                        function()
            execute.assert_not_called()

    def test_stale_controller_refuses_before_agent_request(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            (root / 'status.json').write_text(json.dumps(self.initial))
            rpc = Mock()
            controller = {'STATE': root, 'process_identity': lambda _: ['different', 'identity'], 'rpc': rpc}
            with patch.dict(self.module['main'].__globals__, {'CONFIG': {'controller': 'controller'}}):
                with patch('runpy.run_path', return_value=controller):
                    with self.assertRaisesRegex(RuntimeError, 'Stale Windows'):
                        self.module['main']()
            rpc.assert_not_called()
