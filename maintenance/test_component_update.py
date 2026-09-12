from pathlib import Path
import runpy
import unittest
from unittest.mock import patch


class ComponentUpdateTests(unittest.TestCase):
    def setUp(self):
        with patch.object(Path, 'read_text', return_value='{}'):
            self.module = runpy.run_path(str(Path(__file__).with_name('apply-component-update.py')))

    def test_preview_accepts_component_update_and_dbus_reload(self):
        self.module['validate_preview']('would restart the following units: gpu-indicator.service, home-manager-lexyo.service\n'
                                        'would reload the following units: dbus.service\n')

    def test_preview_refuses_session_network_or_dbus_restart(self):
        for unit in ('display-manager.service', 'user@1001.service', 'dbus.service', 'NetworkManager.service'):
            with self.subTest(unit=unit), self.assertRaisesRegex(RuntimeError, 'unapproved'):
                self.module['validate_preview']('would restart the following units: ' + unit)

    def test_preview_refuses_swap_or_unknown_operation(self):
        for line in ('would stop swap device: /dev/mapper/swap', 'would reboot now'):
            with self.subTest(line=line), self.assertRaisesRegex(RuntimeError, 'Unexpected'):
                self.module['validate_preview'](line)

    def test_preview_allows_explicitly_preserved_session(self):
        self.module['validate_preview']('would NOT stop the following changed units: display-manager.service')

    def test_actual_local_preview_includes_standard_banner(self):
        self.module['validate_preview']('Not checking switch inhibitors (action = dry-activate)\n'
            'would stop the following units: accounts-daemon.service, gpu-indicator.service\n'
            'would activate the configuration...\n'
            'would reload the following units: dbus-broker.service\n'
            'would restart the following units: home-manager-lexyo.service, polkit.service\n'
            'would start the following units: accounts-daemon.service, gpu-indicator.service\n')

    def test_parser_correction_cannot_retry_an_activation_or_repeat_correction(self):
        fn = self.module['validate_preview_recovery']
        with patch.dict(fn.__globals__, {'CONFIG': {'baseline': '/original'}}):
            prior = {'phase': 'failed', 'current': '/original',
                     'error': 'Unexpected activation operation: would activate the configuration...'}
            fn(prior, False, False)
            for activated, corrected in ((True, False), (False, True), (True, True)):
                with self.subTest(activated=activated, corrected=corrected), self.assertRaisesRegex(RuntimeError, 'no activation retry'):
                    fn(prior, activated, corrected)
            with self.assertRaisesRegex(RuntimeError, 'no activation retry'):
                fn(dict(prior, error='activation failed'), False, False)
