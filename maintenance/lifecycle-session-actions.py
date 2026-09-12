#!/usr/bin/env python3
"""One logout and one exact-conversation resume for the new lifecycle grant."""
import fcntl
import json
import os
from pathlib import Path
import subprocess
import sys
import time

CONFIG = json.loads(Path('@config@').read_text())
STATE = Path(CONFIG['resume_state'])


def alive(pid, expected):
    try:
        fields = Path(f'/proc/{pid}/stat').read_text().rsplit(')', 1)[1].split()
        return fields[0] != 'Z' and expected == [
            Path('/proc/sys/kernel/random/boot_id').read_text().strip(), fields[19]]
    except FileNotFoundError:
        return False


def logout():
    if not alive(CONFIG['old_shell_pid'], CONFIG['old_shell_identity']):
        raise RuntimeError('Original session changed; no second logout')
    if str(Path('/run/current-system').resolve()) != CONFIG['candidate']:
        raise RuntimeError('Candidate is not active')
    status = json.loads(subprocess.check_output(['@control@', 'status'], timeout=5))
    if status.get('phase') != 'waiting-for-normal-logout' or not status.get('old_session_alive'):
        raise RuntimeError('No armed original-session test')
    if not (STATE / 'armed').is_file():
        raise RuntimeError('Continuation is not armed')
    with (STATE / 'logout-used').open('x') as marker:
        marker.write('One normal logout requested; never repeat.\n')
        marker.flush()
        os.fsync(marker.fileno())
    os.execv(CONFIG['quit'], [CONFIG['quit'], '--logout', '--no-prompt'])


def resume():
    if not (STATE / 'armed').is_file():
        return
    with (STATE / 'resume.lock').open('a') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        if alive(CONFIG['old_shell_pid'], CONFIG['old_shell_identity']):
            return
        deadline = time.monotonic() + 90
        while alive(CONFIG['old_agent_pid'], CONFIG['old_agent_identity']):
            if time.monotonic() >= deadline:
                raise RuntimeError('Old agent still alive; refusing duplicate continuation')
            time.sleep(1)
        if (STATE / 'consumed').exists():
            return
        (STATE / 'armed').rename(STATE / 'consumed')
        with (STATE / 'resume.log').open('a') as log:
            subprocess.run([CONFIG['codex'], 'login', 'status'], stdout=log,
                           stderr=log, timeout=30, check=True)
            subprocess.Popen([CONFIG['kitty'], '--title', 'GPU lifecycle validation',
                CONFIG['codex'], 'resume', '-C', '/home/lexyo', '-s', 'danger-full-access',
                '-a', 'never', '--no-alt-screen', CONFIG['thread'],
                'Continue the newly approved lifecycle GNOME session test. First read '
                '/home/lexyo/worktrees/precision-gpu-vm-handoff/maintenance/CHECKPOINT.template.md '
                'and maintenance/LIFECYCLE-SESSION-TEST.md. Inspect the one-test helper; '
                'never reset its budget or repeat a failed logout. Verify actual mapped Mutter '
                'w1krysf0wmi8mlm26cs0i5146hw9f6nm, Intel primary, both displays, PaperWM '
                'and the indicator. No reboot, forced logout, owner bypass or fresh-login '
                'claim of full HDMI handoff success. Gaming is still gated. Complete safe '
                'validation and remove the temporary authority and one-shot autostart '
                'after recording the actual result.'], stdout=log, stderr=log,
                start_new_session=True)


if __name__ == '__main__':
    if sys.argv[1:] == ['logout']:
        logout()
    elif sys.argv[1:] == ['resume']:
        resume()
    else:
        raise SystemExit('Expected logout|resume')
