#!/usr/bin/env python3
"""Run a reviewed PowerShell file (or stdin) through the existing QEMU agent."""
import base64
import fcntl
import os
import json
from pathlib import Path
import runpy
import sys
import time
import uuid

controller = runpy.run_path("/run/current-system/sw/bin/precision-windows", run_name="guest_maintenance")
rpc = controller["rpc"]
socket = controller["RUNTIME"] / "agent.sock"
lock = (controller['RUNTIME'] / 'guest-maintenance.lock').open('a')
fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
status_path = controller['STATE'] / 'status.json'
initial_status = json.loads(status_path.read_text())
if initial_status.get('state') != 'running':
    raise SystemExit('Windows must already be running; no automatic mode selection')
expected_pid = os.environ.get('PRECISION_EXPECTED_QEMU_PID')
if expected_pid and expected_pid != str(initial_status.get('qemu_pid')):
    raise SystemExit('Windows instance changed; refusing provisioning')
raw_rpc = rpc
def rpc(path, command, arguments=None):
    current = json.loads(status_path.read_text())
    if any(current.get(key) != initial_status.get(key) for key in ('qemu_pid','pid','process_identity','mode')):
        raise RuntimeError('Windows instance changed during guest maintenance')
    return raw_rpc(path, command, arguments)
def execute(arguments):
    process = rpc(socket, "guest-exec", {
        "path": "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe",
        "arg": ["-NoProfile", "-NonInteractive"] + arguments,
        "capture-output": True,
    })
    for _ in range(int(os.environ.get('PRECISION_GUEST_COMMAND_TIMEOUT', '300'))):
        result = rpc(socket, "guest-exec-status", {"pid": process["pid"]})
        if result.get("exited"):
            return result
        time.sleep(1)
    raise RuntimeError("Guest command exceeded its time budget; inspect before retrying")


def encoded(command):
    return execute(["-EncodedCommand", base64.b64encode(command.encode("utf-16-le")).decode()])


def show(result):
    for name in ("out-data", "err-data"):
        if name in result:
            print(base64.b64decode(result[name]).decode("utf-8", errors="replace"))


# Windows limits command-line length. Stage large reviewed scripts using QGA's
# file protocol in a SYSTEM/Administrators-only directory, not a public temp dir.
bootstrap = encoded(r"""
$ErrorActionPreference='Stop'
$d='C:\ProgramData\PrecisionGpuMaintenance'
if(-not(Test-Path $d)){New-Item -ItemType Directory -Path $d | Out-Null}
if((Get-Item $d).Attributes -band [IO.FileAttributes]::ReparsePoint){throw 'Refusing reparse-point staging directory'}
$acl=New-Object System.Security.AccessControl.DirectorySecurity
$acl.SetAccessRuleProtection($true,$false)
foreach($sid in @('S-1-5-18','S-1-5-32-544')){
 $identity=New-Object System.Security.Principal.SecurityIdentifier($sid)
 $rule=New-Object System.Security.AccessControl.FileSystemAccessRule($identity,'FullControl','ContainerInherit,ObjectInherit','None','Allow')
 $acl.AddAccessRule($rule)
}
Set-Acl -Path $d -AclObject $acl
""")
if bootstrap.get("exitcode", 1):
    show(bootstrap)
    raise SystemExit("Could not prepare private guest script staging directory")

guest_path = "C:\\ProgramData\\PrecisionGpuMaintenance\\" + uuid.uuid4().hex + ".ps1"
source = sys.stdin.read() if sys.argv[1] == '-' else Path(sys.argv[1]).read_text()
script = "[Console]::OutputEncoding = [System.Text.Encoding]::UTF8;\n" + source
payload = script.encode("utf-8-sig")
handle = rpc(socket, "guest-file-open", {"path": guest_path, "mode": "w"})
try:
    offset = 0
    while offset < len(payload):
        block = payload[offset:offset + 16384]
        written = rpc(socket, "guest-file-write", {"handle": handle, "buf-b64": base64.b64encode(block).decode()})["count"]
        if not 0 < written <= len(block):
            raise RuntimeError("Invalid guest script write count")
        offset += written
finally:
    rpc(socket, "guest-file-close", {"handle": handle})

# Process-only policy for this reviewed private script; no machine/user policy
# is changed, and no password or authentication state is involved.
result = execute(["-ExecutionPolicy", "Bypass", "-File", guest_path])
show(result)
cleanup = encoded("$ErrorActionPreference='Stop'; [IO.File]::Delete('" + guest_path + "'); "
                  "$d='C:\\ProgramData\\PrecisionGpuMaintenance'; "
                  "if([IO.Directory]::GetFileSystemEntries($d).Length -eq 0){[IO.Directory]::Delete($d)}")
if cleanup.get("exitcode", 1):
    show(cleanup)
    raise SystemExit("Guest command finished but temporary script cleanup failed: " + guest_path)
sys.exit(result.get("exitcode", 1))
