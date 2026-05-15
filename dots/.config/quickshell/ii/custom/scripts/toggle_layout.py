#!/usr/bin/env python3
"""Toggle keyboard layouts in general.lua and reload Hyprland."""
import sys
import re
import subprocess
import json

GENERAL_LUA = sys.argv[2] if len(sys.argv) > 2 else "~/.config/hypr/custom/general.lua"

def expand_path(p):
    import os
    return os.path.expanduser(p)

def read_layouts():
    """Read current kb_layout from general.lua."""
    path = expand_path(GENERAL_LUA)
    with open(path, "r") as f:
        content = f.read()
    m = re.search(r'kb_layout\s*=\s*"([^"]*)"', content)
    if not m:
        return ["us"]
    return [l.strip() for l in m.group(1).split(",") if l.strip()]

def write_layouts(layouts):
    """Write kb_layout back to general.lua and reload Hyprland."""
    path = expand_path(GENERAL_LUA)
    with open(path, "r") as f:
        content = f.read()
    new_layout = ", ".join(layouts)
    content = re.sub(r'(kb_layout\s*=\s*")[^"]*(")', rf'\g<1>{new_layout}\2', content)
    with open(path, "w") as f:
        f.write(content)
    subprocess.run(["hyprctl", "reload"], capture_output=True)

def status():
    layouts = read_layouts()
    print(json.dumps({
        "layouts": layouts,
        "ru": "ru" in layouts,
        "ua": "ua" in layouts,
    }))

def toggle(lang):
    layouts = read_layouts()
    if lang in layouts:
        layouts.remove(lang)
    else:
        layouts.append(lang)
    # "us" must always be first
    if "us" not in layouts:
        layouts.insert(0, "us")
    write_layouts(layouts)
    # Return new state
    print(json.dumps({
        "layouts": layouts,
        "ru": "ru" in layouts,
        "ua": "ua" in layouts,
    }))

if __name__ == "__main__":
    cmd = sys.argv[1] if len(sys.argv) > 1 else "status"
    if cmd == "status":
        status()
    elif cmd == "toggle" and len(sys.argv) > 2:
        lang = sys.argv[2]
        GENERAL_LUA = sys.argv[3] if len(sys.argv) > 3 else GENERAL_LUA
        toggle(lang)
    else:
        print(json.dumps({"error": f"Unknown command: {cmd}"}))
        sys.exit(1)
