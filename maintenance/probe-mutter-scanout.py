#!/usr/bin/env python3
"""Isolated, bounded Mutter render-node test, not a physical HDMI handoff test.

No sudo, physical display server, settings edits, Xwayland restart or VFIO.
The child exits normally and Mutter's command mode shuts its test session down.
"""
import argparse
import json
import os
from pathlib import Path
import signal
import socket
import struct
import subprocess
import sys
import tempfile
import time


def registry_interfaces():
    # Only get_registry + sync: never bind a GPU/lease global or request a FD.
    interfaces = []
    with socket.socket(socket.AF_UNIX) as client:
        client.settimeout(4)
        client.connect(str(Path(os.environ['XDG_RUNTIME_DIR']) /
                           os.environ['WAYLAND_DISPLAY']))
        client.sendall(struct.pack('=III', 1, (12 << 16) | 1, 2) +
                       struct.pack('=III', 1, (12 << 16), 3))
        pending = b''
        while True:
            chunk = client.recv(65536)
            if not chunk:
                raise RuntimeError('Wayland closed before sync completion')
            pending += chunk
            while len(pending) >= 8:
                obj, header = struct.unpack_from('=II', pending)
                size, opcode = header >> 16, header & 0xffff
                if size < 8 or size % 4:
                    raise RuntimeError('Invalid Wayland event length')
                if len(pending) < size:
                    break
                payload, pending = pending[8:size], pending[size:]
                if obj == 3 and opcode == 0:
                    return interfaces
                if obj == 2 and opcode == 0:
                    name, length = struct.unpack_from('=II', payload)
                    if not 1 <= length <= len(payload) - 8:
                        raise RuntimeError('Invalid Wayland interface string')
                    interfaces.append(payload[8:8 + length - 1].decode('ascii'))


def inside(expect_scanout):
    time.sleep(1)
    pid = os.getppid()
    exe = os.readlink(f'/proc/{pid}/exe')
    if Path(exe).name not in ('mutter', '.mutter-wrapped'):
        raise RuntimeError('The audit parent is not the isolated Mutter')
    fds = []
    for fd in Path(f'/proc/{pid}/fd').iterdir():
        try:
            target = os.readlink(fd)
        except FileNotFoundError:
            continue
        if target.startswith(('/dev/dri/', '/dev/nvidia')):
            fds.append(target)
    interfaces = registry_interfaces()
    leases = interfaces.count('wp_drm_lease_device_v1')
    nvidia_context_handles = any(target.startswith('/dev/nvidia') for target in fds)
    result = {'compositor_pid': pid, 'executable': exe,
              'graphics_fds': sorted(fds), 'lease_globals': leases,
              'nvidia_context_handles': nvidia_context_handles,
              'expect_scanout': expect_scanout}
    print(json.dumps(result), flush=True)
    if nvidia_context_handles == expect_scanout:
        raise RuntimeError('Unexpected NVIDIA context-handle result')
    if leases != (1 if expect_scanout else 2):
        raise RuntimeError('Unexpected lease-global count for this two-GPU host')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--mutter')
    parser.add_argument('--scanout-device')
    parser.add_argument('--inside', action='store_true')
    parser.add_argument('--expect-scanout', action='store_true')
    args = parser.parse_args()
    if args.inside:
        inside(args.expect_scanout)
        return
    if not args.mutter or not Path(args.mutter).is_file():
        parser.error('--mutter must identify the built executable')
    if args.scanout_device and not args.scanout_device.startswith('/dev/dri/renderD'):
        parser.error('headless tests may only select a render node')
    with tempfile.TemporaryDirectory(prefix='precision-mutter-audit-') as directory:
        root = Path(directory)
        env = os.environ.copy()
        for key in ('DISPLAY', 'WAYLAND_DISPLAY', 'DBUS_SESSION_BUS_ADDRESS',
                    'SESSION_MANAGER', 'MUTTER_DEBUG_SCANOUT_ONLY_DEVICE'):
            env.pop(key, None)
        for key, part in (('XDG_CONFIG_HOME', 'config'), ('XDG_STATE_HOME', 'state'),
                          ('XDG_CACHE_HOME', 'cache'), ('XDG_RUNTIME_DIR', 'runtime')):
            (root / part).mkdir(mode=0o700)
            env[key] = str(root / part)
        env['NO_AT_BRIDGE'] = '1'
        if args.scanout_device:
            env['MUTTER_DEBUG_SCANOUT_ONLY_DEVICE'] = args.scanout_device
        command = ['dbus-run-session', '--', args.mutter, '--headless', '--no-x11',
                   '--virtual-monitor=800x600', '--wayland-display=precision-audit',
                   '--', sys.executable, str(Path(__file__).resolve()), '--inside']
        if args.scanout_device:
            command.append('--expect-scanout')
        proc = subprocess.Popen(command, env=env, start_new_session=True,
                                stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
        try:
            output, _ = proc.communicate(timeout=25)
        except subprocess.TimeoutExpired:
            os.killpg(proc.pid, signal.SIGTERM)
            try:
                output, _ = proc.communicate(timeout=5)
            except subprocess.TimeoutExpired:
                os.killpg(proc.pid, signal.SIGKILL)
                output, _ = proc.communicate()
            print(output, end='')
            raise RuntimeError('Isolated compositor timed out; test failed')
        print(output, end='')
        if proc.returncode:
            raise RuntimeError(f'Isolated compositor exited {proc.returncode}')
        print('PASS: isolated context/registry checks; physical handoff NOT tested')


if __name__ == '__main__':
    main()
