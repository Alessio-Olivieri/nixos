from copy import deepcopy
import contextlib
import importlib.util
import io
import json
from pathlib import Path
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location('host_display', Path(__file__).parents[1] / 'host_display.py')
display = importlib.util.module_from_spec(spec)
spec.loader.exec_module(display)


class DisplayConfigurationTests(unittest.TestCase):
    def setUp(self):
        internal = ['eDP-1', 'BOE', 'panel', 'internal']
        hdmi = ['HDMI-1', 'LG', 'FULL HD', 'external']
        mode = ['1920x1080@60', 1920, 1080, 60.0, 1.0, [1.0, 2.0], {'is-current': True}]
        self.snapshot = {'serial': 10, 'displayOwner': ':1.123', 'displayBusId': 'session-a', 'shellPid': 23329,
                         'monitors': [[internal, [deepcopy(mode)], {}], [hdmi, [deepcopy(mode)], {}]],
                         'logical': [[0, 0, 1.0, 0, True, [hdmi], {}], [1920, 0, 1.0, 0, False, [internal], {}]],
                         'properties': {'layout-mode': 1, 'supports-changing-layout-mode': True}}

    def test_hdmi_detach_retains_internal_and_promotes_primary(self):
        result = display.configuration(self.snapshot, {'HDMI-1'})
        self.assertEqual(result['logical'], [[0, 0, 1.0, 0, True, [['eDP-1', '1920x1080@60', {}]]]])
        self.assertEqual(result['layoutMode'], 1)

    def test_hdmi_unplug_retains_valid_internal_layout(self):
        self.snapshot['nvidiaHdmi'] = ['HDMI-1']
        current = deepcopy(self.snapshot)
        current['monitors'] = current['monitors'][:1]
        current['logical'] = current['logical'][1:]
        current['logical'][0][4] = True
        self.assertTrue(display.safe_unplugged_layout(self.snapshot, current))
        current['logical'][0][4] = False
        self.assertFalse(display.safe_unplugged_layout(self.snapshot, current))

    def test_unplug_exception_does_not_accept_missing_internal_panel(self):
        self.snapshot['nvidiaHdmi'] = ['HDMI-1']
        current = deepcopy(self.snapshot)
        current['monitors'] = current['monitors'][1:]
        current['logical'] = current['logical'][:1]
        self.assertFalse(display.safe_unplugged_layout(self.snapshot, current))

    def test_snapshot_is_not_modified(self):
        before = deepcopy(self.snapshot)
        display.configuration(self.snapshot, {'HDMI-1'})
        self.assertEqual(before, self.snapshot)

    def test_restore_preserves_primary_positions_and_modes(self):
        result = display.configuration(self.snapshot)
        self.assertTrue(result['logical'][0][4])
        self.assertEqual(result['logical'][1][0], 1920)
        self.assertEqual(result['serial'], 10)
        self.assertEqual(result['displayOwner'], ':1.123')
        self.assertEqual(result['displayBusId'], 'session-a')
        self.assertEqual(result['shellPid'], 23329)

    def test_rotation_and_scale_retained(self):
        self.snapshot['logical'][1][2:4] = [2.0, 1]
        result = display.configuration(self.snapshot, {'HDMI-1'})
        self.assertEqual(result['logical'][0][2:4], [2.0, 1])

    def test_mirrored_internal_survives(self):
        self.snapshot['logical'][0][5].append(self.snapshot['monitors'][0][0])
        self.snapshot['logical'].pop()
        result = display.configuration(self.snapshot, {'HDMI-1'})
        self.assertEqual(result['logical'][0][5][0][0], 'eDP-1')

    def test_never_disables_all_displays(self):
        with self.assertRaisesRegex(RuntimeError, 'every Linux display'):
            display.configuration(self.snapshot, {'eDP-1', 'HDMI-1'})

    def test_ambiguous_mode_refused(self):
        self.snapshot['monitors'][0][1].append(deepcopy(self.snapshot['monitors'][0][1][0]))
        with self.assertRaisesRegex(RuntimeError, 'ambiguous'):
            display.configuration(self.snapshot, {'HDMI-1'})

    def test_preserves_color_range_and_supported_underscan(self):
        self.snapshot['monitors'][0][2] = {'color-mode': 2, 'rgb-range': 1, 'is-underscanning': False}
        result = display.configuration(self.snapshot, {'HDMI-1'})
        self.assertEqual(result['logical'][0][5][0][2], {'color-mode': 2, 'rgb-range': 1, 'underscanning': False})

    def test_unsupported_layout_mode_not_sent(self):
        self.snapshot['properties'].pop('supports-changing-layout-mode')
        self.assertNotIn('layoutMode', display.configuration(self.snapshot))

    def test_restore_of_current_layout_does_not_apply_again(self):
        output = io.StringIO()
        current = deepcopy(self.snapshot)
        current['serial'] += 1
        with patch.object(display, 'bridge', return_value=current) as bridge:
            with patch('sys.argv', ['host-display', 'restore']), \
                 patch('sys.stdin', io.StringIO(json.dumps(self.snapshot))), \
                 contextlib.redirect_stdout(output):
                display.main()
        bridge.assert_called_once_with('snapshot')
        self.assertEqual(json.loads(output.getvalue()), {'restored': True, 'changed': False})

    def test_restore_cannot_cross_gnome_session_restart(self):
        current = deepcopy(self.snapshot)
        current['displayOwner'] = ':1.999'
        with patch.object(display, 'bridge', return_value=current) as bridge:
            with patch('sys.argv', ['host-display', 'restore']), \
                 patch('sys.stdin', io.StringIO(json.dumps(self.snapshot))), \
                 self.assertRaisesRegex(RuntimeError, 'GNOME session changed'):
                display.main()
        bridge.assert_called_once_with('snapshot')

    def test_restore_cannot_cross_reused_owner_and_serial(self):
        # Actual logout/login reused :1.7 and serial1; bus and process identity
        # must not be inferred from those values alone.
        for key, replacement in [('displayBusId', 'session-b'), ('shellPid', 77549)]:
            with self.subTest(key=key):
                current = deepcopy(self.snapshot)
                current[key] = replacement
                with patch.object(display, 'bridge', return_value=current) as bridge:
                    with patch('sys.argv', ['host-display', 'restore']), \
                         patch('sys.stdin', io.StringIO(json.dumps(self.snapshot))), \
                         self.assertRaisesRegex(RuntimeError, 'GNOME session changed'):
                        display.main()
                bridge.assert_called_once_with('snapshot')

    def test_restore_refuses_missing_session_identity(self):
        for key in ['displayBusId', 'shellPid', 'displayOwner']:
            with self.subTest(key=key):
                original = deepcopy(self.snapshot)
                del original[key]
                with patch.object(display, 'bridge', return_value=self.snapshot) as bridge:
                    with patch('sys.argv', ['host-display', 'restore']), \
                         patch('sys.stdin', io.StringIO(json.dumps(original))), \
                         self.assertRaisesRegex(RuntimeError, 'GNOME session changed'):
                        display.main()
                bridge.assert_called_once_with('snapshot')


if __name__ == '__main__':
    unittest.main()
