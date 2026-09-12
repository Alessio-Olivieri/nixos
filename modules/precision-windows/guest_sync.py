#!/usr/bin/env python3
"""Reconcile the fixed Nix-owned Windows helper, never start or reboot a VM."""
import json
import os
from pathlib import Path
import runpy
import subprocess
import sys
import time

CONFIG = json.loads(Path('@config@').read_text())


def same_guest(initial, current):
    return current.get('state') == 'running' and all(
        initial.get(key) == current.get(key)
        for key in ('pid', 'qemu_pid', 'process_identity', 'mode'))


def main():
    controller = runpy.run_path(CONFIG['controller'], run_name='guest_sync')
    status_path = controller['STATE'] / 'status.json'
    initial = json.loads(status_path.read_text()) if status_path.exists() else {}
    if initial.get('state') != 'running':
        print('Windows is not running; helper will reconcile on its next launch.')
        return
    if controller['process_identity'](initial.get('pid')) != initial.get('process_identity'):
        raise RuntimeError('Stale Windows controller identity; no guest changes')
    deadline = time.monotonic() + 90
    while True:
        current = json.loads(status_path.read_text())
        if not same_guest(initial, current):
            print('Windows stopped or changed during readiness; no provisioning.')
            return
        try:
            controller['rpc'](controller['RUNTIME'] / 'agent.sock', 'guest-ping')
            break
        except (OSError, RuntimeError) as error:
            if time.monotonic() >= deadline:
                raise RuntimeError('Windows Guest Agent unavailable after 90 seconds; no automatic retry') from error
            time.sleep(2)
    env = dict(os.environ, PRECISION_EXPECTED_QEMU_PID=str(initial['qemu_pid']),
               PRECISION_GUEST_COMMAND_TIMEOUT='90')
    result = subprocess.run([sys.executable, '-B', '@lib@/qga-runner.py',
                             CONFIG['guest_display_installer']], env=env)
    if result.returncode:
        raise RuntimeError('Windows helper reconciliation failed; existing VM stays running. See this service journal.')
    print('Windows display helper reconciled to the Nix-owned version.')


if __name__ == '__main__':
    try:
        main()
    except Exception as error:
        print(str(error), file=sys.stderr)
        sys.exit(1)
