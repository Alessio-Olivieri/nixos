#!/usr/bin/env python3
"""One locally authorized compositor test; fixed closures, no reboot interface."""
import errno
import json
import os
from pathlib import Path
import signal
import socket
import stat
import struct
import subprocess
import sys
import time

CONFIG = json.loads(Path('@config@').read_text())
DIRECTORY = Path('/run/precision-hdmi-session-test')
SOCKET = DIRECTORY / 'control.sock'


def identity(pid):
    try:
        fields = Path(f'/proc/{pid}/stat').read_text().rsplit(')', 1)[1].split()
        if fields[0] == 'Z':
            return None
        return [Path('/proc/sys/kernel/random/boot_id').read_text().strip(), fields[19]]
    except FileNotFoundError:
        return None


def clean_old_socket(directory=Path('/run/precision-hdmi-activation')):
    """Remove only the positively identified, refused-connection old endpoint."""
    if not directory.exists():
        return
    info = directory.lstat()
    endpoint = directory / 'control.sock'
    if not stat.S_ISDIR(info.st_mode) or info.st_uid != 0 or info.st_mode & 0o022:
        raise RuntimeError('Old activation directory is not the expected protected directory')
    if set(directory.iterdir()) != {endpoint}:
        raise RuntimeError('Old activation directory contains unexpected entries; keeping it')
    info = endpoint.lstat()
    if not stat.S_ISSOCK(info.st_mode) or info.st_uid != 1001:
        raise RuntimeError('Old activation endpoint identity differs; keeping it')
    with socket.socket(socket.AF_UNIX) as check:
        check.settimeout(1)
        try:
            check.connect(str(endpoint))
        except OSError as error:
            if error.errno != errno.ECONNREFUSED:
                raise
        else:
            raise RuntimeError('Old activation helper is still live; refusing a second authority')
    endpoint.unlink()
    directory.rmdir()
    print('Removed the stale old activation socket and its empty directory.', flush=True)


class SessionTest:
    def __init__(self):
        self.state = {'activations': 0, 'rollbacks': 0, 'restarts': 0,
                      'phase': 'ready', 'candidate': CONFIG['candidate'],
                      'baseline': CONFIG['baseline']}
        self.logout_deadline = None
        self.finishing = False

    def save(self):
        payload = json.dumps(self.state)
        (DIRECTORY / 'state.json').write_text(payload + '\n')
        print(payload, flush=True)

    def switch(self, closure, action):
        # Closures are pinned in the immutable Nix package, never from a request.
        result = subprocess.run([closure + '/bin/switch-to-configuration', action],
            env={'PATH': '/run/current-system/sw/bin:/run/wrappers/bin', 'LANG': 'C.UTF-8'},
            text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        print(result.stdout, flush=True)
        self.state['last_exitcode'] = result.returncode
        self.state['current'] = str(Path('/run/current-system').resolve())
        self.save()
        if result.returncode:
            raise RuntimeError(f'Configuration {action} failed ({result.returncode}); no automatic retry')
        return {'exitcode': result.returncode, 'output': result.stdout[-24000:]}

    def old_session_alive(self):
        return identity(CONFIG['old_shell_pid']) == CONFIG['old_shell_identity']

    def request(self, action):
        if action == 'status':
            return self.state | {'old_session_alive': self.old_session_alive()}
        if action == 'preview':
            return self.switch(CONFIG['candidate'], 'dry-activate')
        if action == 'preview-baseline':
            return self.switch(CONFIG['baseline'], 'dry-activate')
        if action == 'activate':
            if self.state['activations'] or self.state['rollbacks']:
                raise RuntimeError('The single test activation has already been used')
            if str(Path('/run/current-system').resolve()) != CONFIG['baseline']:
                raise RuntimeError('Live baseline changed; refusing activation')
            if not self.old_session_alive():
                raise RuntimeError('Original GNOME session is no longer present')
            self.state.update(activations=1, phase='activating')
            self.save()
            result = self.switch(CONFIG['candidate'], 'test')
            self.state['phase'] = 'activated'
            self.save()
            return result
        if action == 'arm-logout':
            if self.state['phase'] != 'activated' or self.state['restarts']:
                raise RuntimeError('No unused, activated session test is available')
            if not self.old_session_alive():
                raise RuntimeError('Original session already ended unexpectedly; no restart')
            self.logout_deadline = time.monotonic() + 90
            self.state['phase'] = 'waiting-for-normal-logout'
            self.save()
            return self.state
        if action == 'rollback':
            if self.state['rollbacks']:
                raise RuntimeError('The single rollback has already been used')
            self.logout_deadline = None
            self.state.update(rollbacks=1, phase='rolling-back')
            self.save()
            result = self.switch(CONFIG['baseline'], 'test')
            # Never kill a replacement desktop as part of rollback. The old
            # compositor takes effect at the next normal login/session restart.
            self.state['phase'] = 'rolled-back'
            self.save()
            return result
        if action == 'finish':
            if self.logout_deadline:
                raise RuntimeError('Logout test is armed; finish after its result or rollback')
            self.finishing = True
            self.state['phase'] = 'finished'
            self.save()
            return self.state
        raise RuntimeError('Unknown operation; only fixed test/rollback actions are allowed')

    def tick(self):
        if self.logout_deadline is None:
            return
        if time.monotonic() >= self.logout_deadline:
            self.logout_deadline = None
            self.state['phase'] = 'logout-timeout-no-restart'
            self.save()
            return
        if self.old_session_alive():
            return
        self.logout_deadline = None
        self.state.update(restarts=1, phase='restarting-gdm-after-logout')
        self.save()
        result = subprocess.run([CONFIG['systemctl'], 'restart', 'display-manager.service'],
                                timeout=60, check=False)
        self.state.update(phase='awaiting-login' if result.returncode == 0 else 'gdm-restart-failed',
                          gdm_exitcode=result.returncode)
        self.save()


def serve():
    if os.geteuid() != 0:
        raise RuntimeError('Server must be started through the locally authenticated launcher')
    # systemd owns and creates this dedicated RuntimeDirectory.
    if SOCKET.exists() or (DIRECTORY / 'state.json').exists():
        raise RuntimeError('Session-test state already exists; refusing to reset a budget')
    clean_old_socket()
    job = SessionTest()
    job.save()
    stopping = False
    def stop(*_):
        nonlocal stopping
        stopping = True
    for sig in (signal.SIGTERM, signal.SIGINT, signal.SIGHUP):
        signal.signal(sig, stop)
    deadline = time.monotonic() + 3600
    try:
        with socket.socket(socket.AF_UNIX) as server:
            server.bind(str(SOCKET))
            os.chown(SOCKET, 1001, -1)
            os.chmod(SOCKET, 0o600)
            server.listen(2)
            server.settimeout(0.5)
            while not stopping and not job.finishing and time.monotonic() < deadline:
                job.tick()
                try:
                    client, _ = server.accept()
                except socket.timeout:
                    continue
                with client:
                    client.settimeout(3)
                    try:
                        _, uid, _ = struct.unpack('3i', client.getsockopt(socket.SOL_SOCKET, socket.SO_PEERCRED, 12))
                        if uid != 1001:
                            raise RuntimeError('Only lexyo is authorized for this session test')
                        request = json.loads(client.recv(512))
                        if set(request) != {'action'}:
                            raise RuntimeError('Extra request parameters are not accepted')
                        response = job.request(request['action'])
                    except Exception as error:
                        response = {'error': str(error)}
                    try:
                        client.sendall((json.dumps(response) + '\n').encode())
                    except OSError:
                        pass
    finally:
        SOCKET.unlink(missing_ok=True)
        print('Session-test authority stopped; systemd removes its runtime directory.', flush=True)


def client(action):
    with socket.socket(socket.AF_UNIX) as connection:
        connection.settimeout(600)
        connection.connect(str(SOCKET))
        connection.sendall(json.dumps({'action': action}).encode())
        result = bytearray()
        while not result.endswith(b'\n'):
            part = connection.recv(65536)
            if not part:
                raise RuntimeError('Controller disconnected; inspect its journal before retrying')
            result.extend(part)
    response = json.loads(result)
    print(json.dumps(response))
    if 'error' in response:
        raise SystemExit(1)


if __name__ == '__main__':
    try:
        if sys.argv[1:] == ['serve']:
            serve()
        elif len(sys.argv) == 2:
            client(sys.argv[1])
        else:
            raise RuntimeError('Expected status|preview|preview-baseline|activate|arm-logout|rollback|finish')
    except Exception as error:
        print(str(error), file=sys.stderr)
        sys.exit(1)
