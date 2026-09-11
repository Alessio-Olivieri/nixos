#!/usr/bin/env python3
"""Display maintenance progress without launching another agent."""
import json
from pathlib import Path
import subprocess
import time

state = Path("/home/lexyo/.local/state/precision-gpu-maintenance")
try:
    while True:
        lines = ["Precision GPU maintenance", "", "This window shows progress; closing it does not stop the job.", ""]
        lines += subprocess.run(["systemctl", "--user", "show", "precision-gpu-maintenance-continuation.service", "-p", "ActiveState", "-p", "MainPID"], capture_output=True, text=True).stdout.splitlines()
        progress = state / "progress.txt"
        if progress.exists():
            lines += ["", progress.read_text()]
        messages = []
        with (state / "continuation.log").open() as log:
            for line in log:
                try:
                    event = json.loads(line)
                except ValueError:
                    continue
                item = event.get("item", {})
                if item.get("type") == "agent_message":
                    messages.append(item.get("text", ""))
        lines += ["", "Latest background-agent updates:", *messages[-4:]]
        lines += ["", "Detailed checkpoint: " + str(state / "CHECKPOINT.md")]
        safe = "\n".join(lines)
        safe = "".join(c for c in safe if c in "\n\t" or ord(c) >= 32)
        print("\033[2J\033[H" + safe, flush=True)
        time.sleep(5)
except KeyboardInterrupt:
    pass
