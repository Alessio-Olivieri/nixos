"""Keep RCC preferences writable while enforcing background startup."""

import os
from pathlib import Path
import re


def configure(path):
    path.parent.mkdir(parents=True, exist_ok=True)
    text = path.read_text() if path.exists() else "(\n)\n"
    for key in ("run_in_background", "startup_in_background", "enable_tray_icon"):
        pattern = rf"\b{key}:\s*(?:true|false)"
        if re.search(pattern, text):
            text = re.sub(pattern, f"{key}: true", text)
        else:
            text = text.replace("(", f"(\n    {key}: true,", 1)
    # RCC 6.3.7 requires every Config field when deserializing.
    defaults = {
        "ac_command": '""', "bat_command": '""', "dark_mode": "true",
        "start_fullscreen": "false", "fullscreen_width": "1920",
        "fullscreen_height": "1080",
        "notifications": "(enabled: true, receive_notify_gfx: true, receive_notify_gfx_status: true)",
    }
    for key, value in defaults.items():
        if not re.search(rf"\b{key}:", text):
            text = text.replace("(", f"(\n    {key}: {value},", 1)
    path.write_text(text)


if __name__ == "__main__":
    configure(Path(os.environ.get("XDG_CONFIG_HOME", str(Path.home() / ".config")))
              / "rog" / "rog-control-center.cfg")
