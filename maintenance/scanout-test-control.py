#!/usr/bin/env python3
"""New, separately approved one-session test; never reset the earlier grant."""
import json
import os
from pathlib import Path
import runpy
import subprocess
import sys
import time

core = runpy.run_path('@core@')
guard = runpy.run_path('@preview_guard@')['validate_preview']
CONFIG = core['CONFIG']
RUNTIME = Path(CONFIG.get('runtime', '/run/precision-scanout-session-test'))
RECORD = Path(CONFIG.get('record', '/var/lib/precision-scanout-session-test-20260912'))


def preflight():
    if Path('/proc/sys/kernel/random/boot_id').read_text().strip() != CONFIG['old_shell_identity'][0]:
        raise RuntimeError('Different boot; this one-session grant is invalid')
    for link in ('/run/booted-system', '/nix/var/nix/profiles/system'):
        if str(Path(link).resolve()) != CONFIG['saved']:
            raise RuntimeError('Saved or booted generation changed')
    for name in ('kernel', 'initrd', 'kernel-modules', 'kernel-params',
                 'etc/systemd/system/user@1001.service.d/overrides.conf'):
        a, b = (Path(CONFIG[key]) / name for key in ('baseline', 'candidate'))
        if a.resolve() != b.resolve() and not (a.is_file() and b.is_file() and a.read_bytes() == b.read_bytes()):
            raise RuntimeError('Protected component differs: ' + name)


def replacement_session_exists(proc=Path('/proc')):
    for entry in proc.iterdir():
        if not entry.name.isdigit():
            continue
        try:
            # comm is truncated and also matches gnome-shell-calendar-server.
            # Only an actual compositor executable counts as a replacement.
            if (entry.stat().st_uid == 1001 and
                    Path(os.readlink(entry / 'exe')).name in
                    {'gnome-shell', '.gnome-shell-wrapped'}):
                if core['identity'](int(entry.name)) is not None:
                    return True
        except FileNotFoundError:
            pass
    return False


class ScanoutTest(core['SessionTest']):
    def save(self):
        super().save()
        temporary = RECORD / 'state.next'
        with temporary.open('w') as record:
            json.dump(self.state, record)
            record.write('\n')
            record.flush()
            os.fsync(record.fileno())
        temporary.replace(RECORD / 'state.json')

    def switch(self, closure, action):
        result = super().switch(closure, action)
        if action == 'dry-activate':
            guard(result['output'])
        elif action == 'test' and closure == CONFIG['candidate'] and CONFIG.get('udevadm'):
            # Refresh only this device's new rule; no detach, modeset or GPU probe.
            subprocess.run([CONFIG['udevadm'], 'trigger', '--action=change', '--settle',
                            '/sys/class/drm/card0'], check=True, timeout=20)
            properties = subprocess.check_output([CONFIG['udevadm'], 'info', '-q', 'property',
                                                  '-p', '/sys/class/drm/card0'], text=True, timeout=5)
            if ('ID_PATH=pci-0000:01:00.0' not in properties.splitlines() or
                    'MUTTER_DEVICE_SCANOUT_ONLY=1' not in properties.splitlines()):
                raise RuntimeError('Expected NVIDIA scanout rule is not active; no logout permitted')
        return result

    def request(self, action):
        if action == 'activate' and not self.state['activations'] and not self.state['rollbacks']:
            preflight()
            if not self.old_session_alive():
                raise RuntimeError('Original GNOME session is no longer present')
            self.switch(CONFIG['candidate'], 'dry-activate')
            self.switch(CONFIG['baseline'], 'dry-activate')
        if action == 'rollback' and not self.state['rollbacks']:
            self.switch(CONFIG['baseline'], 'dry-activate')
        return super().request(action)

    def tick(self):
        if self.logout_deadline is not None and not CONFIG.get('restart_gdm', True):
            if time.monotonic() >= self.logout_deadline:
                self.state['phase'] = 'logout-timeout-no-restart'
            elif self.old_session_alive():
                return
            else:
                self.state['phase'] = 'awaiting-login-no-gdm-restart'
            self.logout_deadline = None
            self.save()
            return
        if self.logout_deadline is not None and not self.old_session_alive() and replacement_session_exists():
            self.logout_deadline = None
            self.state['phase'] = 'replacement-session-present-no-restart'
            self.save()
            return
        super().tick()


core['serve'].__globals__.update(DIRECTORY=RUNTIME, SOCKET=RUNTIME / 'control.sock',
                              SessionTest=ScanoutTest, clean_old_socket=lambda: None)


def main():
    if sys.argv[1:] == ['serve']:
        if os.geteuid() != 0:
            raise RuntimeError('Local root authentication required')
        preflight()
        if core['identity'](CONFIG['old_shell_pid']) != CONFIG['old_shell_identity']:
            raise RuntimeError('Original session changed; refusing a stale test')
        # Exclusive and durable: restarting the unit cannot reset any budget.
        RECORD.mkdir(mode=0o755)
        core['serve']()
    elif len(sys.argv) == 2:
        core['client'](sys.argv[1])
    else:
        raise RuntimeError('Expected status|preview|preview-baseline|activate|arm-logout|rollback|finish')


if __name__ == '__main__':
    try:
        main()
    except Exception as error:
        print(str(error), file=sys.stderr)
        sys.exit(1)
