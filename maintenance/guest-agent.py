#!/usr/bin/env python3
"""Run a reviewed maintenance PowerShell file through the existing QEMU agent."""
import base64
from pathlib import Path
import runpy
import sys
import time

controller = runpy.run_path("/home/lexyo/.local/state/precision-gpu-maintenance/windows-package/bin/precision-windows", run_name="guest_maintenance")
rpc = controller["rpc"]
socket = controller["RUNTIME"] / "agent.sock"
script = "[Console]::OutputEncoding = [System.Text.Encoding]::UTF8;\n" + Path(sys.argv[1]).read_text()
encoded = base64.b64encode(script.encode("utf-16-le")).decode()
process = rpc(socket, "guest-exec", {
    "path": "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe",
    "arg": ["-NoProfile", "-NonInteractive", "-EncodedCommand", encoded],
    "capture-output": True,
})
for _ in range(300):
    result = rpc(socket, "guest-exec-status", {"pid": process["pid"]})
    if result.get("exited"):
        for name in ("out-data", "err-data"):
            if name in result:
                print(base64.b64decode(result[name]).decode("utf-8", errors="replace"))
        sys.exit(result.get("exitcode", 1))
    time.sleep(1)
raise SystemExit("Guest command is still running after five minutes; inspect it before retrying")
