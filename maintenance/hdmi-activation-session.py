#!/usr/bin/env python3
"""Temporary, foreground-only authority for bounded HDMI NixOS test activations.

Run once through sudo in the LOCAL terminal. No passwords, sudoers changes,
startup services, auto-login, bootloader writes, reboots, or arbitrary commands.
The root process expires after two hours and removes its exact control socket.
"""
import json
import os
from pathlib import Path
import re
import signal
import socket
import stat
import struct
import subprocess
import time

DIRECTORY = Path('/run/precision-hdmi-activation')
SOCKET = DIRECTORY / 'control.sock'
BASELINE = Path('/nix/store/xkga9k4w11g6yzbzp0pgwgsfg7p1c5cw-nixos-system-precision7560-26.05.20260611.a037402')


def activation_path(value):
    if not isinstance(value, str) or not re.fullmatch(
            r'/nix/store/[a-z0-9]{32}-nixos-system-precision7560-[a-zA-Z0-9.+_-]+', value):
        raise ValueError('Only a built Precision NixOS store closure is accepted')
    path = Path(value)
    info = path.lstat()
    if not stat.S_ISDIR(info.st_mode) or info.st_uid != 0 or info.st_mode & 0o022:
        raise ValueError('Candidate must be an immutable root-owned Nix store directory')
    script = path / 'bin/switch-to-configuration'
    if not script.is_file() or not os.access(script, os.X_OK):
        raise ValueError('Missing NixOS activation executable')
    return script


def main():
    if os.geteuid() != 0 or os.environ.get('SUDO_UID') != '1001':
        raise SystemExit('Start this immutable helper with sudo in lexyo\'s local terminal')
    activation_path(str(BASELINE))
    if DIRECTORY.exists():
        raise SystemExit('Activation session already exists; inspect it rather than replacing it')
    DIRECTORY.mkdir(mode=0o711)
    deadline = time.monotonic() + 2 * 60 * 60
    attempts, rollbacks = 0, 0
    stopping = False
    def stop(signum, frame):
        # Do not interrupt a switch-to-configuration midway. Refuse further
        # requests, reap any in-flight activation, then execute exact cleanup.
        nonlocal stopping
        stopping = True
    previous_handlers = {sig: signal.signal(sig, stop)
                         for sig in (signal.SIGHUP, signal.SIGTERM, signal.SIGINT)}
    try:
        with socket.socket(socket.AF_UNIX) as server:
            server.bind(str(SOCKET))
            os.chown(SOCKET, 1001, -1)
            os.chmod(SOCKET, 0o600)
            server.listen(1)
            server.settimeout(1)
            print('Ready: at most three test activations and one rollback; expires in two hours.', flush=True)
            print('The saved boot generation will not change. No reboot is permitted by this helper.', flush=True)
            while not stopping and time.monotonic() < deadline:
                try:
                    client, _ = server.accept()
                except socket.timeout:
                    continue
                with client:
                    client.settimeout(5)
                    try:
                        _, uid, _ = struct.unpack('3i', client.getsockopt(socket.SOL_SOCKET, socket.SO_PEERCRED, 12))
                        if uid != 1001:
                            raise ValueError('Only the local maintenance user is accepted')
                        request = json.loads(client.recv(4096))
                        action = request.get('action')
                        if action == 'finish':
                            client.sendall(b'{"finished":true}\n')
                            return
                        if action == 'status':
                            response = {'attempts': attempts, 'rollbacks': rollbacks,
                                        'remaining_seconds': int(deadline - time.monotonic()),
                                        'current': str(Path('/run/current-system').resolve())}
                        else:
                            if action == 'activate' and attempts < 3:
                                script = activation_path(request.get('system'))
                                attempts += 1
                            elif action == 'rollback' and rollbacks < 1:
                                script = activation_path(str(BASELINE))
                                rollbacks += 1
                            else:
                                raise ValueError('Unknown operation or finite activation budget exhausted')
                            print(f'Test activation {script.parent.parent}', flush=True)
                            # "test" activates live configuration, NOT the saved boot default.
                            process = subprocess.Popen([str(script), 'test'], env={
                                'PATH': '/run/current-system/sw/bin:/run/wrappers/bin',
                                'LANG': 'C.UTF-8'})
                            code = process.wait()
                            response = {'exitcode': code, 'attempts': attempts, 'rollbacks': rollbacks,
                                        'current': str(Path('/run/current-system').resolve())}
                            print(json.dumps(response), flush=True)
                        client.sendall((json.dumps(response) + '\n').encode())
                    except (OSError, ValueError, TypeError) as error:
                        try:
                            client.sendall((json.dumps({'error': str(error)}) + '\n').encode())
                        except OSError:
                            pass
    finally:
        if SOCKET.exists():
            SOCKET.unlink()
        DIRECTORY.rmdir()
        for sig, handler in previous_handlers.items():
            signal.signal(sig, handler)
        print('Temporary activation authority removed.', flush=True)


if __name__ == '__main__':
    main()
