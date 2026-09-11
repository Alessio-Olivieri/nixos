#!/usr/bin/env python3
"""One Windows installation, two manual modes, viewer-managed clean shutdown."""
import argparse
import fcntl
import json
import os
from pathlib import Path
import signal
import socket
import subprocess
import sys
import time

CONFIG = json.loads(Path("@config@").read_text())
ASSETS = Path("/home/lexyo/windows-11")
STATE = Path("/home/lexyo/.local/state/precision-windows")
RUNTIME = Path("/run/user/1001/precision-windows")


def notify(message, critical=False):
    print(message, flush=True)
    subprocess.run([CONFIG["notify"], "-u", "critical" if critical else "normal", "Windows", message], check=False)


def rpc(path, command, arguments=None, qmp=False):
    with socket.socket(socket.AF_UNIX) as connection:
        connection.settimeout(8)
        connection.connect(str(path))
        stream = connection.makefile("rwb", buffering=0)
        def receive():
            while True:
                line = stream.readline()
                if not line:
                    raise RuntimeError("Guest control connection closed")
                reply = json.loads(line)
                if "error" in reply:
                    raise RuntimeError(str(reply["error"]))
                if "return" in reply:
                    return reply["return"]
        if qmp:
            json.loads(stream.readline())
            stream.write(b'{"execute":"qmp_capabilities"}\r\n')
            receive()
        stream.write((json.dumps({"execute": command, "arguments": arguments or {}}) + "\r\n").encode())
        return receive()


def gpu(action):
    result = subprocess.run(["/run/wrappers/bin/sudo", "-n", CONFIG["gpu_helper"], action], capture_output=True, text=True)
    print(result.stdout, end="", flush=True)
    if result.returncode:
        raise RuntimeError((result.stderr + result.stdout).strip())


def qemu_arguments(mode):
    # Preserve the existing Quickemu guest's chipset, CPU topology, storage
    # controller, NIC model/MAC, OVMF code/variables and swtpm identity.
    args = [CONFIG["qemu"], "-name", "windows-11,process=windows-11,debug-threads=on",
            "-machine", "q35,hpet=off,smm=on,vmport=off,accel=kvm",
            "-global", "kvm-pit.lost_tick_policy=discard", "-global", "ICH9-LPC.disable_s3=1",
            "-cpu", "host,+hypervisor,+invtsc,l3-cache=on,migratable=no,hv_passthrough",
            "-smp", "cores=4,threads=2,sockets=1", "-m", "16G" if mode == "gaming" else "8G",
            "-rtc", "base=localtime,clock=host,driftfix=slew", "-vga", "none",
            "-device", "qxl-vga,xres=1280,yres=800,ram_size=65536,vram_size=65536,vgamem_mb=64",
            "-display", "none", "-spice", f"disable-ticketing=on,unix=on,addr={RUNTIME}/spice.sock",
            "-device", "virtio-serial-pci",
            "-chardev", f"socket,id=agent0,path={RUNTIME}/agent.sock,server=on,wait=off",
            "-device", "virtserialport,chardev=agent0,name=org.qemu.guest_agent.0",
            "-chardev", "spicevmc,id=vdagent0,name=vdagent",
            "-device", "virtserialport,chardev=vdagent0,name=com.redhat.spice.0",
            "-device", "virtio-rng-pci,rng=rng0", "-object", "rng-random,id=rng0,filename=/dev/urandom",
            "-device", "usb-ehci,id=input", "-device", "usb-kbd,bus=input.0", "-device", "usb-tablet,bus=input.0",
            "-audiodev", "spice,id=audio0", "-device", "intel-hda", "-device", "hda-micro,audiodev=audio0",
            "-device", "e1000,netdev=nic,mac=52:54:00:12:34:56", "-netdev", "user,hostname=windows-11,id=nic",
            "-global", "driver=cfi.pflash01,property=secure,value=on",
            "-drive", f"if=pflash,format=raw,unit=0,file={CONFIG['firmware']},readonly=on",
            "-drive", f"if=pflash,format=raw,unit=1,file={ASSETS}/OVMF_VARS.fd",
            "-device", "ide-hd,drive=SystemDisk",
            "-drive", f"id=SystemDisk,if=none,format=qcow2,file={ASSETS}/disk.qcow2,discard=unmap,detect-zeroes=unmap,cache=writeback,aio=threads",
            "-chardev", f"socket,id=chrtpm,path={RUNTIME}/swtpm.sock",
            "-tpmdev", "emulator,id=tpm0,chardev=chrtpm", "-device", "tpm-tis,tpmdev=tpm0",
            "-qmp", f"unix:{RUNTIME}/qmp.sock,server=on,wait=off", "-serial", "none"]
    if mode == "gaming":
        args += ["-object", "memory-backend-file,id=looking-glass,mem-path=/dev/kvmfr0,size=128M,share=yes",
                 "-device", "ivshmem-plain,memdev=looking-glass",
                 "-device", "vfio-pci,host=0000:01:00.0,multifunction=on",
                 "-device", "vfio-pci,host=0000:01:00.1"]
    return args


def start_viewer(mode, force_spice=False):
    env = os.environ.copy()
    # A launcher inherited from an offloaded process must still use Intel.
    for key in ("__NV_PRIME_RENDER_OFFLOAD", "__GLX_VENDOR_LIBRARY_NAME", "__VK_LAYER_NV_optimus", "VK_ICD_FILENAMES", "VK_DRIVER_FILES"):
        env.pop(key, None)
    env["DRI_PRIME"] = "pci-0000_00_02_0"
    if mode == "gaming" and not force_spice:
        args = [CONFIG["looking_glass"], "lgmp:shmDevice=/dev/kvmfr0", f"spice:host={RUNTIME}/spice.sock", "spice:port=0"]
    else:
        args = [CONFIG["viewer"], "--title", f"Windows — {mode.title()}", f"spice+unix://{RUNTIME}/spice.sock"]
    return subprocess.Popen(args, env=env)


def external_vm_running():
    for process in Path("/proc").iterdir():
        if not process.name.isdigit():
            continue
        try:
            executable = os.readlink(process / "exe")
            command = (process / "cmdline").read_bytes()
        except (OSError, PermissionError):
            continue
        if "qemu-system" in executable and b"windows-11/disk.qcow2" in command:
            return True
        if "swtpm" in executable and b"windows-11" in command:
            return True
    return False


def run(mode):
    STATE.mkdir(parents=True, exist_ok=True, mode=0o700)
    RUNTIME.mkdir(parents=True, exist_ok=True, mode=0o700)
    lock = (STATE / "installation.lock").open("w")
    try:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except BlockingIOError:
        raise RuntimeError("This Windows installation is already running")
    if external_vm_running():
        raise RuntimeError("The existing Windows installation is already open in another QEMU/Quickemu process")
    for name in ("disk.qcow2", "OVMF_VARS.fd", "tpm2-00.permall"):
        if not (ASSETS / name).is_file():
            raise RuntimeError(f"Missing existing Windows asset: {name}")
    if mode == "gaming" and not Path("/dev/kvmfr0").is_char_device():
        raise RuntimeError("Looking Glass shared-memory device is unavailable; boot the configured generation")
    # Only stale sockets owned by this controller, after the installation lock.
    for name in ("control.sock", "qmp.sock", "agent.sock", "spice.sock", "swtpm.sock"):
        path = RUNTIME / name
        if path.is_socket():
            path.unlink()
    status = {"mode": mode, "state": "starting", "pid": os.getpid()}
    def save():
        temporary = STATE / "status.tmp"
        temporary.write_text(json.dumps(status) + "\n")
        temporary.replace(STATE / "status.json")
    save()
    transferred = False
    qemu = tpm = viewer = None
    shutdown_requested = False
    deadline = None
    def request(*_):
        nonlocal shutdown_requested
        shutdown_requested = True
    signal.signal(signal.SIGTERM, request)
    signal.signal(signal.SIGINT, request)
    try:
        if mode == "gaming":
            gpu("prepare")
            transferred = True
        tpm = subprocess.Popen([CONFIG["swtpm"], "socket", "--ctrl", f"type=unixio,path={RUNTIME}/swtpm.sock", "--terminate", "--tpmstate", f"dir={ASSETS}", "--tpm2"])
        for _ in range(100):
            if (RUNTIME / "swtpm.sock").exists():
                break
            if tpm.poll() is not None:
                raise RuntimeError("The existing Windows TPM could not start")
            time.sleep(0.1)
        qemu = subprocess.Popen(qemu_arguments(mode))
        for _ in range(200):
            if (RUNTIME / "spice.sock").exists() and (RUNTIME / "qmp.sock").exists():
                break
            if qemu.poll() is not None:
                raise RuntimeError(f"Windows failed to start (QEMU exit {qemu.returncode}); inspect journalctl --user -u precision-windows")
            time.sleep(0.1)
        viewer = start_viewer(mode)
        status.update(state="running", qemu_pid=qemu.pid)
        save()
        with socket.socket(socket.AF_UNIX) as control:
            control.bind(str(RUNTIME / "control.sock"))
            control.listen(4)
            control.settimeout(0.5)
            while qemu.poll() is None:
                try:
                    connection, _ = control.accept()
                    with connection:
                        connection.settimeout(2)
                        command = connection.recv(1024).decode().strip()
                        if command == "shutdown":
                            request()
                        elif command in {"view", "console"} and (viewer is None or viewer.poll() is not None):
                            viewer = start_viewer(mode, command == "console")
                            status["state"] = "running"
                            deadline = None
                            save()
                        connection.sendall((json.dumps(status) + "\n").encode())
                except (socket.timeout, BrokenPipeError, ConnectionResetError):
                    pass
                if viewer is not None and viewer.poll() is not None:
                    viewer = None
                    request()
                if shutdown_requested:
                    shutdown_requested = False
                    try:
                        rpc(RUNTIME / "qmp.sock", "system_powerdown", qmp=True)
                        status["state"] = "shutting-down"
                        deadline = time.monotonic() + 180
                        notify("Clean Windows shutdown requested; waiting for the guest to stop.")
                    except Exception as error:
                        status.update(state="shutdown-failed", error=str(error))
                        notify("Could not request guest shutdown: " + str(error), True)
                    save()
                if deadline is not None and time.monotonic() >= deadline:
                    deadline = None
                    status["state"] = "shutdown-timeout"
                    save()
                    notify("Windows has not shut down after 3 minutes. It is still running and locked. Run 'precision-windows console' to reopen it and shut down inside Windows. NVIDIA stays with the guest until it exits.", True)
        status.update(state="stopped", qemu_exit=qemu.returncode)
    finally:
        # A controller exception never detaches hardware from a live VM.
        if qemu is not None and qemu.poll() is None:
            status["state"] = "controller-error-guest-running"
            save()
            notify("The Windows controller encountered an error. Waiting for Windows to stop before releasing its disk or NVIDIA.", True)
            try:
                rpc(RUNTIME / "qmp.sock", "system_powerdown", qmp=True)
            except Exception:
                pass
            qemu.wait()
        if viewer is not None and viewer.poll() is None:
            viewer.terminate()
            try:
                viewer.wait(timeout=10)
            except subprocess.TimeoutExpired:
                notify("Windows stopped, but its viewer did not exit. NVIDIA recovery will continue.", True)
        if tpm is not None:
            try:
                tpm.wait(timeout=10)
            except subprocess.TimeoutExpired:
                # QEMU is confirmed stopped; terminate only its leftover TPM process.
                tpm.terminate()
                try:
                    tpm.wait(timeout=10)
                except subprocess.TimeoutExpired:
                    status["state"] = "tpm-cleanup-failed"
                    save()
                    notify("Windows stopped, but its TPM process has not exited. Keeping the installation locked until it stops.", True)
                    # Never allow another VM to mutate a live TPM state directory.
                    tpm.wait()
        if transferred:
            status["state"] = "returning-nvidia"
            save()
            try:
                gpu("release")
            except Exception as error:
                status.update(state="gpu-recovery-failed", error=str(error))
                save()
                notify("Windows stopped, but NVIDIA recovery needs attention: " + str(error), True)
                raise
        status["state"] = "stopped"
        save()
        (RUNTIME / "control.sock").unlink(missing_ok=True)
        notify("Windows stopped. NVIDIA is available to Linux." if transferred else "Windows stopped.")


def command(action):
    with socket.socket(socket.AF_UNIX) as connection:
        connection.settimeout(5)
        try:
            connection.connect(str(RUNTIME / "control.sock"))
        except (FileNotFoundError, ConnectionRefusedError):
            path = STATE / "status.json"
            saved = json.loads(path.read_text()) if path.exists() else {"state": "not-started"}
            if action == "status":
                if saved.get("state") not in {"stopped", "not-started", "gpu-recovery-failed"}:
                    saved = {"state": "controller-unavailable", "last_state": saved}
                print(json.dumps(saved))
                return
            if saved.get("state") in {"stopped", "not-started"}:
                raise RuntimeError("Windows is stopped. Start Windows — Light or Windows — Gaming from the application menu; 'console' only reconnects to a running VM.") from None
            raise RuntimeError("The Windows controller is unavailable. Check 'precision-windows status' and 'journalctl --user -u precision-windows'; do not start another copy while QEMU is running.") from None
        connection.sendall(action.encode())
        print(connection.recv(16384).decode(), end="")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", choices=["gaming", "light", "status", "shutdown", "view", "console", "run"])
    parser.add_argument("mode", nargs="?", choices=["gaming", "light"])
    args = parser.parse_args()
    if args.action in {"gaming", "light"}:
        result = subprocess.run(["systemd-run", "--user", "--collect", "--unit=precision-windows", "--service-type=exec",
                                 "--property=KillMode=process", "--property=TimeoutStopSec=infinity",
                                 "--property=SendSIGKILL=no", CONFIG["controller"], "run", args.action])
        if result.returncode:
            raise RuntimeError("Windows is already running or its service could not start. Use 'precision-windows view' to reopen it.")
    elif args.action == "run":
        if not args.mode:
            parser.error("run requires gaming or light")
        run(args.mode)
    else:
        command(args.action)


if __name__ == "__main__":
    try:
        main()
    except Exception as error:
        notify(str(error), True)
        sys.exit(1)
