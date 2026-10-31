"""Visible, resumable enrollment using Howdy's standard add command."""

import argparse
import configparser
import fcntl
import json
import os
from pathlib import Path
import pwd
import signal
import subprocess
import tempfile
import time


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--user", required=True)
    parser.add_argument("--target", type=int, default=50)
    args = parser.parse_args()
    if os.geteuid() != 0:
        parser.error("Launch asus-howdy-enroll; it requests administrator access once")
    if not 1 <= args.target <= 500:
        parser.error("Target must be between 1 and 500")
    caller = int(os.environ.get("PKEXEC_UID", "0"))
    if caller and pwd.getpwuid(caller).pw_name != args.user:
        parser.error("Only enroll the account that launched this window")
    pwd.getpwnam(args.user)
    if not os.environ.get("DISPLAY"):
        parser.error("Launch from your GNOME desktop")

    import cv2
    import numpy as np

    os.umask(0o077)
    root = Path("/var/lib/howdy/models")
    root.mkdir(parents=True, exist_ok=True)
    root.parent.chmod(0o700)
    root.chmod(0o700)
    model = root / f"{args.user}.dat"
    # Keep non-model files out of the directory scanned by howdy-gtk.
    lock = Path(f"/run/lock/asus-howdy-enroll-{pwd.getpwnam(args.user).pw_uid}.lock").open("w")
    fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)

    def models():
        return json.loads(model.read_text()) if model.exists() else []

    def count():
        return sum(m.get("label", "").startswith("asus-angle-") for m in models())

    def next_label():
        labels = {m.get("label") for m in models()}
        number = 1
        while f"asus-angle-{number:02}" in labels:
            number += 1
        return f"asus-angle-{number:02}"

    def recover_if_partial(previous):
        try:
            models()
        except (json.JSONDecodeError, OSError):
            if previous is not None:
                temporary = root.parent / f".{args.user}.recovery"
                temporary.write_bytes(previous)
                temporary.chmod(0o600)
                temporary.replace(model)
            else:
                model.unlink(missing_ok=True)
        if model.exists():
            model.chmod(0o600)

    settings = configparser.ConfigParser()
    settings.read("/etc/howdy/config.ini")
    device = settings.get("video", "device_path")
    title = "ASUS Face Enrollment - S start, Space pause, Q quit"
    cv2.namedWindow(title, cv2.WINDOW_AUTOSIZE)
    camera = None
    child = None
    output = None
    previous = None
    running = False
    saved = count()
    target = max(args.target, saved)
    last_frame = np.zeros((360, 360, 3), dtype=np.uint8)
    status = "Preview only. Press S to start enrollment."
    next_capture = time.monotonic() + 2

    def open_camera():
        capture = cv2.VideoCapture(device, cv2.CAP_V4L2)
        capture.set(cv2.CAP_PROP_FRAME_WIDTH, 360)
        capture.set(cv2.CAP_PROP_FRAME_HEIGHT, 360)
        capture.set(cv2.CAP_PROP_FPS, 15)
        if not capture.isOpened():
            capture.release()
            raise RuntimeError("IR camera is busy or unavailable; close other camera apps")
        return capture

    try:
        while True:
            now = time.monotonic()
            if child is not None:
                if child.poll() is not None:
                    output.seek(0)
                    message = output.read().decode(errors="replace")
                    success = child.returncode == 0
                    output.close()
                    output = None
                    child = None
                    recover_if_partial(previous)
                    saved = count()
                    if not success:
                        running = False
                        print(message[-2000:], flush=True)
                        status = "No sample saved. Face camera, then press S to retry."
                    elif saved >= target:
                        running = False
                        status = "Complete! Q closes the camera; A adds 10 more."
                    else:
                        status = "Sample saved. Gently change angle."
                    next_capture = now + 2
                elif now - started > 35:
                    os.killpg(child.pid, signal.SIGTERM)
                    running = False
                    status = "Capture timed out; waiting for it to stop."

            if child is None:
                if camera is None:
                    camera = open_camera()
                ok, frame = camera.read()
                if ok:
                    last_frame = frame
                if running and saved < target and now >= next_capture:
                    camera.release()
                    camera = None
                    previous = model.read_bytes() if model.exists() else None
                    output = tempfile.TemporaryFile()
                    child = subprocess.Popen(
                        ["/run/current-system/sw/bin/howdy", "-U", args.user, "-y", "add", next_label()],
                        stdout=output, stderr=subprocess.STDOUT, start_new_session=True)
                    started = now
                    status = "Capturing: hold angle. Preview pauses during this scan."

            view = cv2.resize(cv2.flip(last_frame, 1), (640, 640))
            view = cv2.copyMakeBorder(view, 80, 140, 0, 0, cv2.BORDER_CONSTANT, value=(25, 25, 25))
            state = "CAPTURING" if child else ("ENROLLING" if running else "PREVIEW / PAUSED")
            cv2.putText(view, f"Face samples: {saved}/{target}    {state}", (15, 35),
                        cv2.FONT_HERSHEY_SIMPLEX, 0.65, (100, 230, 130), 2)
            cv2.putText(view, "S start/resume | Space pause | A +10 | Q close camera", (15, 65),
                        cv2.FONT_HERSHEY_SIMPLEX, 0.48, (240, 240, 240), 1)
            for index, line in enumerate([status, "Try slight left/right turns, chin up/down, and small tilts.",
                                          "Preview images are not saved. Completed face models stay local."]):
                cv2.putText(view, line, (15, 750 + index * 28), cv2.FONT_HERSHEY_SIMPLEX,
                            0.46, (240, 240, 240), 1)
            cv2.imshow(title, view)
            key = cv2.waitKey(30) & 0xff
            # GTK reports WND_PROP_VISIBLE=-1 even for an open window.
            try:
                closed = cv2.getWindowProperty(title, cv2.WND_PROP_AUTOSIZE) < 0
            except cv2.error:
                closed = True
            if key in (ord("q"), 27) or closed:
                break
            if key == ord("s") and saved < target:
                running = True
                next_capture = time.monotonic() + 2
                status = "Starting shortly. Keep your face visible."
            if key == ord(" "):
                running = False
                status = "Paused. Current scan may finish; S resumes."
            if key == ord("a"):
                target = max(target, saved) + 10
                status = "Target increased. Press S to start/resume."
    finally:
        if child is not None and child.poll() is None:
            os.killpg(child.pid, signal.SIGTERM)
            child.wait(timeout=5)
            recover_if_partial(previous)
        if output:
            output.close()
        if camera is not None:
            camera.release()
        cv2.destroyAllWindows()
        print(f"Camera closed. {count()} completed ASUS face samples preserved.", flush=True)


if __name__ == "__main__":
    main()
