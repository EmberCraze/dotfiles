#!/usr/bin/env python3
"""Desktop notifications with click-to-focus for herdr agent panes.

Listens on a herdr socket for pane_agent_status_changed broadcast events.
When an agent becomes blocked (needs input) or done, shows a desktop
notification with a Focus action. Clicking it focuses the niri window
hosting the herdr client, then focuses the workspace/pane inside herdr.

Usage:
  notify-focus-daemon.py [socket ...]
Defaults to ~/.config/herdr/herdr.sock. For a remote server, forward its
socket over SSH and pass the local path:
  ssh -N -L ~/.config/herdr/remote.sock:/home/<user>/.config/herdr/herdr.sock <host> &
  notify-focus-daemon.py ~/.config/herdr/remote.sock
"""

import json
import os
import socket
import subprocess
import sys
import threading
import time

NOTIFY_STATUSES = {"blocked", "done"}
BODY = {
    "blocked": "needs your attention",
    "done": "finished",
}


def rpc(sock_path, method, params=None, timeout=2.0):
    req = {"id": f"notify-focus:{time.time_ns()}", "method": method}
    if params is not None:
        req["params"] = params
    c = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    c.settimeout(timeout)
    c.connect(sock_path)
    c.sendall((json.dumps(req) + "\n").encode())
    buf = b""
    while not buf.endswith(b"\n"):
        chunk = c.recv(65536)
        if not chunk:
            break
        buf += chunk
    c.close()
    return json.loads(buf) if buf.strip() else {}


def find_herdr_window_id():
    """Find the niri window whose process tree contains the herdr client."""
    try:
        out = subprocess.run(
            ["pgrep", "-x", "herdr"], capture_output=True, text=True
        ).stdout.split()
        herdr_pids = set(out)
        windows = subprocess.run(
            ["niri", "msg", "windows"], capture_output=True, text=True
        ).stdout
    except Exception:
        return None
    if not herdr_pids or not windows:
        return None

    # Map each niri window to its PID, then check if any herdr pid
    # has that window's PID as an ancestor.
    def ancestors(pid):
        seen = []
        while pid and pid != "1":
            seen.append(pid)
            try:
                pid = subprocess.run(
                    ["ps", "-o", "ppid=", "-p", pid],
                    capture_output=True, text=True,
                ).stdout.strip()
            except Exception:
                break
        return seen

    herdr_ancestors = set()
    for hp in herdr_pids:
        herdr_ancestors.update(ancestors(hp))

    win_id = None
    for line in windows.splitlines():
        line = line.strip()
        if line.startswith("Window ID"):
            win_id = line.split()[2].rstrip(":")
        elif line.startswith("PID:") and win_id:
            pid = line.split()[1].rstrip(",")
            if pid in herdr_ancestors or pid in herdr_pids:
                return win_id
    return None


def niri_focused_window_id():
    try:
        out = subprocess.run(
            ["niri", "msg", "focused-window"], capture_output=True, text=True
        ).stdout
        for line in out.splitlines():
            if "Window ID" in line:
                return line.split()[2].rstrip(":")
    except Exception:
        pass
    return None


def handle_event(sock_path, data):
    status = data.get("agent_status")
    if status not in NOTIFY_STATUSES:
        return
    pane_id = data.get("pane_id")
    workspace_id = data.get("workspace_id")
    agent = data.get("display_agent") or data.get("agent") or "agent"
    title = data.get("title") or ""

    herdr_win = find_herdr_window_id()

    # Skip if the herdr window is focused AND this pane is the focused pane.
    if herdr_win and herdr_win == niri_focused_window_id():
        try:
            snap = rpc(sock_path, "session.snapshot")
            focused = json.dumps(snap)
            if pane_id and f'"focused_pane_id": "{pane_id}"' in focused:
                return
        except Exception:
            pass

    label = f"{agent}" + (f" — {title}" if title else "")
    body = f"{label} {BODY[status]}"

    def notify_and_focus():
        try:
            action = subprocess.run(
                ["notify-send", "-t", "0", "--action=focus=Focus",
                 "herdr", body],
                capture_output=True, text=True,
            ).stdout.strip()
        except Exception:
            return
        if action not in ("focus", "0"):
            return
        if herdr_win:
            subprocess.run(
                ["niri", "msg", "action", "focus-window", "--id", herdr_win],
                capture_output=True,
            )
        try:
            if workspace_id:
                rpc(sock_path, "workspace.focus", {"workspace_id": workspace_id})
            if pane_id:
                rpc(sock_path, "pane.focus", {"pane_id": pane_id})
        except Exception:
            pass

    # notify-send blocks until the notification is dismissed; don't stall
    # the event loop.
    threading.Thread(target=notify_and_focus, daemon=True).start()


def watch(sock_path):
    while True:
        try:
            c = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
            c.connect(sock_path)
            c.settimeout(None)
            print(f"connected: {sock_path}", flush=True)
            buf = b""
            while True:
                chunk = c.recv(65536)
                if not chunk:
                    raise ConnectionError("closed")
                buf += chunk
                while b"\n" in buf:
                    line, buf = buf.split(b"\n", 1)
                    if not line.strip():
                        continue
                    try:
                        msg = json.loads(line)
                    except Exception:
                        continue
                    if msg.get("event") == "pane_agent_status_changed":
                        handle_event(sock_path, msg.get("data") or {})
        except Exception as e:
            print(f"{sock_path}: {e}; retrying in 5s", flush=True)
            time.sleep(5)


def main():
    paths = sys.argv[1:] or [
        os.path.expanduser("~/.config/herdr/herdr.sock")
    ]
    threads = [threading.Thread(target=watch, args=(p,), daemon=True) for p in paths]
    for t in threads:
        t.start()
    for t in threads:
        t.join()


if __name__ == "__main__":
    main()
