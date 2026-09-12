#!/usr/bin/env python3
"""One normal logout, bound to this NEW CPU-copy grant's original session."""
import json
import os
from pathlib import Path
import subprocess

if Path('/proc/sys/kernel/random/boot_id').read_text().strip() != 'ec89b2a7-35c8-44cc-8ee9-0ccb1419e153':
    raise SystemExit('Boot changed; refusing logout')
try:
    fields = Path('/proc/147739/stat').read_text().rsplit(')', 1)[1].split()
except FileNotFoundError:
    raise SystemExit('Original session already ended; refusing another logout')
if fields[0] == 'Z' or fields[19] != '1515021':
    raise SystemExit('Original session changed; refusing another logout')
state = json.loads(subprocess.check_output([
    '/nix/store/f70wi9abzf2q4j8z8v6qjkf6rx14gynk-precision-scanout-cpu-session-test/bin/precision-scanout-cpu-session-control',
    'status'], timeout=5))
if state.get('phase') != 'waiting-for-normal-logout' or not state.get('old_session_alive'):
    raise SystemExit('No armed original-session test; refusing logout')
os.execv('/run/current-system/sw/bin/gnome-session-quit',
         ['gnome-session-quit', '--logout', '--no-prompt'])
