#!/usr/bin/env python3
"""One-shot exact-session interactive resume after the approved GNOME logout."""
import fcntl
import json
import os
from pathlib import Path
import subprocess
import time

CONFIG = json.loads(Path('@config@').read_text())
STATE = Path('/home/lexyo/.local/state/precision-hdmi-session-test-20260912')


def alive(pid, identity):
    try:
        fields = Path(f'/proc/{pid}/stat').read_text().rsplit(')', 1)[1].split()
        current = [Path('/proc/sys/kernel/random/boot_id').read_text().strip(), fields[19]]
        return fields[0] != 'Z' and current == identity
    except FileNotFoundError:
        return False


def main():
    if not (STATE / 'armed').is_file():
        return
    with (STATE / 'resume.lock').open('w') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        # An invocation before logout must not open a second coordinator.
        if alive(CONFIG['old_shell_pid'], CONFIG['old_shell_identity']):
            return
        deadline = time.monotonic() + 90
        while alive(CONFIG['old_agent_pid'], CONFIG['old_agent_identity']):
            if time.monotonic() >= deadline:
                raise RuntimeError('Old coordinator still alive; refusing concurrent resume')
            time.sleep(1)
        if (STATE / 'consumed').exists():
            return
        (STATE / 'armed').rename(STATE / 'consumed')
        with (STATE / 'resume.log').open('a') as log:
            login = subprocess.run([CONFIG['codex'], 'login', 'status'],
                                   stdout=log, stderr=log, timeout=30)
            if login.returncode:
                raise RuntimeError('Existing Codex authentication unavailable; no retry')
            # Interactive, visible, same conversation. No worker is spawned
            # concurrently with the old agent and no indefinite retry loop.
            subprocess.Popen([CONFIG['kitty'], '--title', 'GPU maintenance — resumed after login',
                CONFIG['codex'], 'resume', '-C', '/home/lexyo', '-s', 'danger-full-access',
                '-a', 'never', '--no-alt-screen', CONFIG['thread'],
                'Continue the approved single GNOME session test. First read the latest '
                '/home/lexyo/worktrees/precision-gpu-vm-handoff/maintenance/CHECKPOINT.template.md '
                'and maintenance/SESSION-TEST.md. Verify the actual mapped Mutter library, '
                'Intel primary renderer, both monitor states, PaperWM, and indicator. '
                'The privileged one-test helper may still be available; inspect it. '
                'Do not reboot, reset budgets, bypass any GPU owner, or repeat a failed logout. '
                'Do not claim full HDMI handoff success from a fresh login. Complete safe '
                'validation and remove the temporary session-test authority and one-shot '
                'autostart after recording the result.'], stdout=log, stderr=log,
                start_new_session=True)


if __name__ == '__main__':
    main()
