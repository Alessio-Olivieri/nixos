"""Passive, fail-closed check of the compositor actually mapped by this user."""
import os
from pathlib import Path


def verify(config, proc=Path('/proc')):
    expected = config.get('required_mutter')
    if not expected or not expected.startswith('/nix/store/'):
        raise RuntimeError('Gaming requires an explicitly pinned repaired compositor')
    shells = []
    for entry in proc.iterdir():
        if not entry.name.isdigit():
            continue
        try:
            if entry.stat().st_uid != 1001:
                continue
            # Unrelated setuid/nondumpable user processes can hide /proc/exe.
            # comm is only a prefilter; the executable AND mapping must match.
            if (entry / 'comm').read_text().strip() not in {'gnome-shell', '.gnome-shell-wr'}:
                continue
            if Path(os.readlink(entry / 'exe')).name not in {'gnome-shell', '.gnome-shell-wrapped'}:
                continue
            mapped = {line.split()[-1] for line in (entry / 'maps').read_text().splitlines() if line.split()}
            shells.append((int(entry.name), expected in mapped))
        except (FileNotFoundError, ProcessLookupError):
            continue
        except PermissionError as error:
            raise RuntimeError('Cannot verify the active compositor; no GPU changes') from error
    if len(shells) != 1 or not shells[0][1]:
        raise RuntimeError('Gaming requires the exact repaired Mutter in the active GNOME session; rebuilding alone is insufficient. No GPU changes were made.')
    return shells[0][0]
