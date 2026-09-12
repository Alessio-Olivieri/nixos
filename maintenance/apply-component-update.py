#!/usr/bin/env python3
"""One fixed, attended component update. No command server or startup hook."""
import json
import os
from pathlib import Path
import re
import stat
import subprocess
import sys

CONFIG = json.loads(Path('@config@').read_text())
RECORD = Path('/run/precision-gpu-component-update-20260912')
ALLOWED_UNITS = {
    'accounts-daemon.service', 'gpu-indicator.service',
    'home-manager-lexyo.service', 'polkit.service', 'systemd-udevd.service',
}
PROTECTED = (
    'kernel', 'initrd', 'kernel-modules', 'kernel-params',
    'etc/gdm/custom.conf', 'etc/systemd/system/display-manager.service',
    'etc/systemd/system/user@1001.service.d/overrides.conf',
    'etc/udev/rules.d/99-local.rules', 'sw/bin/gnome-shell',
)


def validate_preview(output):
    for line in output.splitlines():
        if line == 'would activate the configuration...':
            continue  # Standard dry-activate banner, not a service operation.
        if line.startswith('would NOT '):
            continue
        if not line.startswith('would '):
            continue
        match = re.fullmatch(r'would (stop|start|restart|reload) the following units: (.+)', line)
        if not match:
            raise RuntimeError('Unexpected activation operation: ' + line)
        action, values = match.groups()
        units = set(values.split(', '))
        permitted = ALLOWED_UNITS | ({'dbus.service', 'dbus-broker.service'} if action == 'reload' else set())
        if units - permitted:
            raise RuntimeError('Activation would affect an unapproved unit: ' + line)


def validate_preview_recovery(prior, activation_exists, correction_exists):
    # Permit only the observed parser failure, before any activation. Preserve
    # the first record and allow this correction once; no activation retry.
    if (activation_exists or correction_exists or prior.get('phase') != 'failed'
            or prior.get('error') != 'Unexpected activation operation: would activate the configuration...'
            or prior.get('current') != CONFIG['baseline']):
        raise RuntimeError('An attempt already exists; no activation retry is allowed')


def preflight():
    old, new = Path(CONFIG['baseline']), Path(CONFIG['candidate'])
    if Path('/run/current-system').resolve() != old:
        raise RuntimeError('Current system changed; refusing this fixed update')
    if Path('/proc/sys/kernel/random/boot_id').read_text().strip() != CONFIG['boot']:
        raise RuntimeError('Boot changed; this update is no longer valid')
    fields = Path(f"/proc/{CONFIG['shell_pid']}/stat").read_text().rsplit(')', 1)[1].split()
    if fields[0] == 'Z' or fields[19] != CONFIG['shell_start']:
        raise RuntimeError('GNOME session changed; refusing update')
    for name in PROTECTED:
        a, b = old / name, new / name
        if not a.exists() or not b.exists():
            raise RuntimeError('Missing protected component: ' + name)
        if a.resolve() != b.resolve() and not (a.is_file() and b.is_file() and a.read_bytes() == b.read_bytes()):
            raise RuntimeError('Protected component differs: ' + name)


def main():
    if os.geteuid() != 0 or len(sys.argv) != 1:
        raise RuntimeError('Run this fixed update once through local sudo')
    preflight()
    # Exclusive root-owned marker: a failed or interrupted attempt cannot loop.
    try:
        RECORD.mkdir(mode=0o755)
    except FileExistsError:
        info = RECORD.lstat()
        if not stat.S_ISDIR(info.st_mode) or info.st_uid != 0 or info.st_mode & 0o022:
            raise RuntimeError('Unexpected update record ownership')
        prior = json.loads((RECORD / 'result.json').read_text())
        validate_preview_recovery(prior, (RECORD / 'activation.log').exists(),
                                  (RECORD / 'parser-correction.json').exists())
        with (RECORD / 'parser-correction.json').open('x') as record:
            json.dump(prior, record)
        (RECORD / 'preview.log').rename(RECORD / 'preview-initial.log')
    activation_attempts = 0
    def save(phase, **data):
        (RECORD / 'result.json').write_text(json.dumps({'phase': phase, 'activation_attempts': activation_attempts, **data}) + '\n')
    save('previewing', candidate=CONFIG['candidate'])
    env = {'PATH': '/run/current-system/sw/bin:/run/wrappers/bin', 'LANG': 'C.UTF-8', 'NO_COLOR': '1'}
    try:
        preview = subprocess.run([CONFIG['candidate'] + '/bin/switch-to-configuration', 'dry-activate'],
                                 env=env, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                                 timeout=180)
        (RECORD / 'preview.log').write_text(preview.stdout)
        print(preview.stdout, flush=True)
        if preview.returncode:
            raise RuntimeError('Preview failed; no activation attempted')
        validate_preview(preview.stdout)
        preflight()
        activation_attempts = 1
        save('activating', candidate=CONFIG['candidate'])
        # `test` updates the running configuration without altering saved boot
        # generations. Never restart the session, reboot, or retry a failure.
        with (RECORD / 'activation.log').open('w') as log:
            result = subprocess.run([CONFIG['candidate'] + '/bin/switch-to-configuration', 'test'],
                                    env=env, stdout=log, stderr=subprocess.STDOUT)
        print((RECORD / 'activation.log').read_text(), flush=True)
        if result.returncode or str(Path('/run/current-system').resolve()) != CONFIG['candidate']:
            raise RuntimeError(f'Activation returned {result.returncode}; inspect the record before recovery')
        save('complete', candidate=CONFIG['candidate'], exitcode=result.returncode)
        print('Component update complete. Close this terminal; the agent will verify the live desktop.', flush=True)
    except Exception as error:
        save('failed', error=str(error), current=str(Path('/run/current-system').resolve()))
        raise


if __name__ == '__main__':
    try:
        main()
    except Exception as error:
        print(str(error), file=sys.stderr)
        sys.exit(1)
