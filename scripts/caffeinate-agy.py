#!/usr/bin/env python3
"""
caffeinate-agy.py - Prevent macOS from sleeping while an Antigravity (agy) agent is working,
and release caffeinate (or trigger sleep) as soon as the agent completes its run.

Usage:
    python3 scripts/caffeinate-agy.py [--pid PID] [--sleep-now] [--quiet-time SECONDS]
"""

import argparse
import datetime
import json
import os
import re
import signal
import subprocess
import sys
import time

caffeinate_proc = None

def cleanup(sig=None, frame=None):
    global caffeinate_proc
    if caffeinate_proc and caffeinate_proc.poll() is None:
        print(f"\n[{datetime.datetime.now().strftime('%H:%M:%S')}] Terminating caffeinate (PID: {caffeinate_proc.pid})...")
        try:
            caffeinate_proc.terminate()
            caffeinate_proc.wait(timeout=3)
        except Exception:
            caffeinate_proc.kill()
    if sig:
        sys.exit(0)

signal.signal(signal.SIGINT, cleanup)
signal.signal(signal.SIGTERM, cleanup)

def is_pid_alive(pid: int) -> bool:
    try:
        os.kill(pid, 0)
        return True
    except OSError:
        return False

def get_child_pids(pid: int) -> list:
    try:
        out = subprocess.check_output(["pgrep", "-P", str(pid)], text=True)
        return [int(p) for p in out.strip().split() if p.isdigit()]
    except subprocess.CalledProcessError:
        return []

def find_transcript_for_pid(pid: int) -> str | None:
    try:
        out = subprocess.check_output(["lsof", "-p", str(pid)], text=True, stderr=subprocess.DEVNULL)
        matches = set(re.findall(r"/brain/([a-f0-9\-]{36})", out))
        for cid in matches:
            tpath = os.path.expanduser(f"~/.gemini/antigravity-cli/brain/{cid}/.system_generated/logs/transcript.jsonl")
            if os.path.exists(tpath):
                return tpath
    except Exception:
        pass
    return None

def check_transcript_state(transcript_path: str):
    """
    Returns (is_active, description)
    """
    try:
        if not os.path.exists(transcript_path):
            return False, "Transcript file does not exist"
        
        mtime = os.path.getmtime(transcript_path)
        age = time.time() - mtime

        # Read last non-empty line
        with open(transcript_path, "r", encoding="utf-8", errors="ignore") as f:
            lines = [line.strip() for line in f if line.strip()]
        
        if not lines:
            return True, "Transcript is empty"

        last_entry = json.loads(lines[-1])
        step_type = last_entry.get("type")
        step_idx = last_entry.get("step_index", "?")
        tool_calls = last_entry.get("tool_calls", [])

        # If agent emitted a PLANNER_RESPONSE without any tool calls, it finished its turn
        if step_type == "PLANNER_RESPONSE" and not tool_calls:
            return False, f"Turn complete at step {step_idx} (no active tool calls, last updated {int(age)}s ago)"

        return True, f"Active at step {step_idx} ({step_type}, tool_calls={len(tool_calls)}, updated {int(age)}s ago)"
    except Exception as e:
        return True, f"Error inspecting transcript: {e}"

def main():
    global caffeinate_proc
    parser = argparse.ArgumentParser(description="Keep Mac awake while agy is working.")
    parser.add_argument("--pid", type=int, default=12959, help="PID of the agy process (default: 12959)")
    parser.add_argument("--transcript", type=str, default=None, help="Explicit path to transcript.jsonl")
    parser.add_argument("--quiet-time", type=int, default=30, help="Seconds with no agent activity before declaring complete (default: 30)")
    parser.add_argument("--poll-interval", type=int, default=10, help="Seconds between poll checks (default: 10)")
    parser.add_argument("--sleep-now", action="store_true", help="Put Mac to sleep immediately after agy finishes instead of letting it idle sleep")
    args = parser.parse_args()

    pid = args.pid
    print(f"=== Antigravity Caffeinate Monitor ===")
    print(f"Target PID: {pid}")

    if not is_pid_alive(pid):
        print(f"Error: Process {pid} is not running.")
        sys.exit(1)

    # Locate transcript
    transcript_path = args.transcript
    if not transcript_path:
        transcript_path = find_transcript_for_pid(pid)
    
    if transcript_path:
        print(f"Tracking Transcript: {transcript_path}")
    else:
        print(f"Warning: Could not auto-detect transcript path for PID {pid}. Will monitor child processes & CPU.")

    # Start caffeinate
    print(f"Starting caffeinate (preventing display/system/disk idle sleep)...")
    caffeinate_proc = subprocess.Popen(["caffeinate", "-dim"])
    print(f"Caffeinate running with PID: {caffeinate_proc.pid}")

    consecutive_idle_count = 0
    required_idle_cycles = max(1, args.quiet_time // args.poll_interval)

    try:
        while True:
            time.sleep(args.poll_interval)
            now_str = datetime.datetime.now().strftime("%H:%M:%S")

            # Check 1: Process death
            if not is_pid_alive(pid):
                print(f"[{now_str}] Process {pid} has terminated. Task complete!")
                break

            # Check 2: Child processes
            children = get_child_pids(pid)
            if children:
                consecutive_idle_count = 0
                print(f"[{now_str}] PID {pid} is running {len(children)} child process(es) (e.g. PID {children[0]}). Keeping awake...")
                continue

            # Check 3: Transcript state
            if transcript_path and os.path.exists(transcript_path):
                is_active, desc = check_transcript_state(transcript_path)
                mtime = os.path.getmtime(transcript_path)
                age = time.time() - mtime

                if is_active:
                    consecutive_idle_count = 0
                    print(f"[{now_str}] Agent is working: {desc}")
                else:
                    if age >= args.quiet_time:
                        consecutive_idle_count += 1
                        print(f"[{now_str}] Agent appears idle: {desc} (Idle cycle {consecutive_idle_count}/{required_idle_cycles})")
                        if consecutive_idle_count >= required_idle_cycles:
                            print(f"[{now_str}] Agent has finished its work!")
                            break
                    else:
                        consecutive_idle_count = 0
                        print(f"[{now_str}] Agent recently finished turn ({int(age)}s ago), verifying stability...")
            else:
                print(f"[{now_str}] PID {pid} is alive with no child processes.")
                consecutive_idle_count += 1
                if consecutive_idle_count >= required_idle_cycles:
                    print(f"[{now_str}] No activity detected for {args.quiet_time}s. Done!")
                    break

    finally:
        cleanup()

    print(f"Caffeinate released. Mac power management restored to normal.")
    if args.sleep_now:
        print("Putting Mac to sleep now...")
        subprocess.run(["osascript", "-e", "tell application \"System Events\" to sleep"])

if __name__ == "__main__":
    main()
