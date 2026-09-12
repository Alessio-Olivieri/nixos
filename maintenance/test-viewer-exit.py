#!/usr/bin/env python3
"""Live maintenance test: viewer process exit, never forced guest power-off.

With --timeout, pause the real guest CPU before closing its viewer and verify
the full three-minute timeout. Always resume the guest in the finally block.
"""
import argparse
import datetime
import json
import os
from pathlib import Path
import runpy
import signal
import subprocess
import time

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--timeout', action='store_true')
args = p.parse_args()
c = runpy.run_path('/run/current-system/sw/bin/precision-windows', run_name='test_probe')
status_path = c['STATE'] / 'status.json'
status = json.loads(status_path.read_text())
assert status['state'] == 'running', status
controller_pid = status['pid']
qemu_pid = status['qemu_pid']
viewers = []
for proc in Path('/proc').iterdir():
    if not proc.name.isdigit():
        continue
    try:
        exe = os.readlink(proc / 'exe')
        procstat = (proc / 'stat').read_text().rsplit(')', 1)[1].split()
        if int(procstat[1]) == controller_pid and Path(exe).name in {'remote-viewer', '.remote-viewer-wrapped', 'looking-glass-client'}:
            viewers.append(int(proc.name))
    except (FileNotFoundError, ProcessLookupError, PermissionError):
        pass
assert len(viewers) == 1, viewers
result = {'mode': status['mode'], 'test': 'delayed-shutdown' if args.timeout else 'viewer-exit', 'started': datetime.datetime.now().isoformat(), 'qemu_pid': qemu_pid, 'viewer_pid': viewers[0]}
paused = False
try:
    if args.timeout:
        c['rpc'](c['RUNTIME'] / 'qmp.sock', 'stop', qmp=True)
        paused = True
    os.kill(viewers[0], signal.SIGTERM)
    print('Closed only the VM viewer process; waiting for controller shutdown handling', flush=True)
    if args.timeout:
        end = time.monotonic() + 200
        while time.monotonic() < end:
            status = json.loads(status_path.read_text())
            if status['state'] == 'shutdown-timeout':
                break
            assert Path(f'/proc/{qemu_pid}').exists(), 'Guest was killed during timeout'
            time.sleep(2)
        assert status['state'] == 'shutdown-timeout', status
        qmp = c['rpc'](c['RUNTIME'] / 'qmp.sock', 'query-status', qmp=True)
        assert qmp['status'] == 'paused', qmp
        result['timeout_preserved_guest'] = True
        print('PASS: full shutdown timeout reported, actual guest remains paused and alive', flush=True)
finally:
    if paused:
        c['rpc'](c['RUNTIME'] / 'qmp.sock', 'cont', qmp=True)
        c['command']('shutdown')

end = time.monotonic() + 210
while time.monotonic() < end:
    status = json.loads(status_path.read_text())
    if status['state'] == 'stopped':
        break
    if status['state'] in {'shutdown-timeout', 'shutdown-failed', 'gpu-recovery-failed'}:
        # A stale timeout may remain briefly after sending the retry.
        if time.monotonic() > end - 200:
            raise RuntimeError(status)
    time.sleep(1)
assert status['state'] == 'stopped', status
assert not Path(f'/proc/{qemu_pid}').exists(), 'Controller claimed stopped while QEMU lives'
assert status.get('qemu_exit') == 0, status
result.update(result='passed', final=status, finished=datetime.datetime.now().isoformat())
log = Path('/home/lexyo/.local/state/precision-gpu-maintenance/live-tests.jsonl')
with log.open('a') as stream:
    stream.write(json.dumps(result) + '\n')
print(json.dumps(result), flush=True)
