#!/usr/bin/env python3
"""Temporary HDMI layout handoff; safe configuration planning is independently testable."""
import json
from pathlib import Path
import subprocess
import sys


def configuration(snapshot, excluded=()):
    """Preserve modes/scales/rotation/mirroring for every retained monitor."""
    active = {}
    for spec, modes, properties in snapshot['monitors']:
        current = [mode[0] for mode in modes if mode[6].get('is-current')]
        if len(current) == 1:
            settings = {key: properties[key] for key in ('color-mode', 'rgb-range') if key in properties}
            if 'is-underscanning' in properties:
                settings['underscanning'] = properties['is-underscanning']
            active[tuple(spec)] = (current[0], settings)
    logical = []
    for x, y, scale, transform, primary, monitors, _ in snapshot['logical']:
        retained = []
        for spec in monitors:
            if spec[0] in excluded:
                continue
            if tuple(spec) not in active:
                raise RuntimeError('Current monitor mode is ambiguous; no display changes made')
            mode, settings = active[tuple(spec)]
            retained.append([spec[0], mode, settings])
        if retained:
            logical.append([x, y, scale, transform, primary, retained])
    if not logical:
        raise RuntimeError('Refusing to disable every Linux display')
    # Keep the existing primary if retained; otherwise choose the internal panel.
    if not any(item[4] for item in logical):
        internal = [item for item in logical if any(m[0].startswith('eDP-') for m in item[5])]
        if len(internal) != 1:
            raise RuntimeError('Cannot safely choose the internal Linux display')
        internal[0][4] = True
    left, top = min(item[0] for item in logical), min(item[1] for item in logical)
    for item in logical:
        item[0] -= left
        item[1] -= top
    result = {'serial': snapshot['serial'], 'logical': logical,
              'displayOwner': snapshot['displayOwner'],
              'displayBusId': snapshot['displayBusId'], 'shellPid': snapshot['shellPid']}
    if snapshot['properties'].get('supports-changing-layout-mode'):
        result['layoutMode'] = snapshot['properties']['layout-mode']
    return result


def nvidia_hdmi(sys=Path('/sys/bus/pci/devices/0000:01:00.0')):
    # HDMI is wired only to this GPU on the validated Precision 7560. Do not
    # guess ownership of DP-1/DP-2: their names may occur on both adapters.
    return {p.name.split('-', 1)[1].replace('HDMI-A-', 'HDMI-')
            for p in sys.glob('drm/card*/card*-HDMI-A-*') if (p / 'status').exists()}


def safe_unplugged_layout(original, current):
    """Accept only missing NVIDIA HDMI with every remaining display active."""
    old = {tuple(m[0]) for m in original['monitors']}
    present = {tuple(m[0]) for m in current['monitors']}
    missing = old - present
    if not missing or present - old:
        return False
    if any(spec[0] not in original.get('nvidiaHdmi', []) for spec in missing):
        return False
    active = {tuple(spec) for logical in current['logical'] for spec in logical[5]}
    primaries = [logical for logical in current['logical'] if logical[4]]
    if active != present or len(primaries) != 1 or not any(
            spec[0].startswith('eDP-') for spec in primaries[0][5]):
        return False
    configuration(current)  # Validate current modes; never apply stale ones.
    return True


def bridge(action, value=None):
    args = ['@gjs@', '-m', '@bridge@', action]
    if value is not None:
        args.append(json.dumps(value))
    result = subprocess.run(args, text=True, capture_output=True, timeout=12)
    if result.returncode:
        raise RuntimeError(result.stderr.strip() or 'GNOME display configuration failed')
    return json.loads(result.stdout)


def main():
    action = sys.argv[1]
    if action == 'snapshot':
        snapshot = bridge('snapshot')
        snapshot['nvidiaHdmi'] = sorted(nvidia_hdmi())
        print(json.dumps(snapshot))
    elif action == 'detach':
        snapshot = json.load(sys.stdin)
        connected = {spec[0] for item in snapshot['logical'] for spec in item[5]}
        excluded = set(snapshot['nvidiaHdmi']) & connected
        if not excluded:
            print(json.dumps({'changed': False}))
            return
        if not any(name.startswith('eDP-') for name in connected):
            raise RuntimeError('The internal Linux panel must be active before Gaming')
        bridge('apply', configuration(snapshot, excluded))
        print(json.dumps({'changed': True}))
    elif action == 'restore':
        original = json.load(sys.stdin)
        current = bridge('snapshot')
        if any(not original.get(key) or original.get(key) != current.get(key)
               for key in ('displayOwner', 'displayBusId', 'shellPid')):
            raise RuntimeError('GNOME session changed; refusing to restore a previous session layout')
        if safe_unplugged_layout(original, current):
            print(json.dumps({'restored': True, 'changed': False, 'topologyChanged': True,
                              'reason': 'NVIDIA HDMI unplugged; retained valid current Linux layout'}))
            return
        # Never apply an old identity/mode to a different newly plugged monitor.
        available = {tuple(spec): {mode[0] for mode in modes}
                     for spec, modes, _ in current['monitors']}
        wanted = configuration(original)
        old_modes = {spec[0]: (tuple(spec), mode[0])
                     for spec, modes, _ in original['monitors']
                     for mode in modes if mode[6].get('is-current')}
        for logical in wanted['logical']:
            for connector, _, _ in logical[5]:
                spec, mode = old_modes[connector]
                if spec not in available or mode not in available[spec]:
                    raise RuntimeError('Monitor topology changed; keeping GNOME current layout instead of restoring stale settings')
        wanted['serial'] = current['serial']
        if wanted == configuration(current):
            print(json.dumps({'restored': True, 'changed': False}))
            return
        bridge('apply', wanted)
        print(json.dumps({'restored': True, 'changed': True}))
    else:
        raise RuntimeError('Expected snapshot, detach or restore')


if __name__ == '__main__':
    try:
        main()
    except Exception as error:
        print(str(error), file=sys.stderr)
        sys.exit(1)
