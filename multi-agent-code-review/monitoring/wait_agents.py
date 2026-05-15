#!/usr/bin/env python3
"""
Wait for Phase 2 agents to complete analysis.

Usage:
    python wait_agents.py --timeout 600 --agents ad18b41a80c0d1de0 a842e402b5e13aa86 aee5e5ec6b0c44dcc
"""

import os
import sys
import time
import argparse
from pathlib import Path
from datetime import datetime


def get_agent_output_dir():
    """Get the directory where agent output files are stored."""
    # Try environment variable first
    temp_dir = os.environ.get('CLAUDE_TEMP_DIR')
    if temp_dir:
        return temp_dir

    # Default to Windows temp location
    username = os.environ.get('USERNAME', 'KEVIN_~1')
    return (f"C:\\Users\\{username}\\AppData\\Local\\Temp\\claude\\"
            "D--repo-skills-and-agent\\8a256f4a-6262-4b86-8028-558f40627c84\\tasks")


def check_agent_status(agent_id, output_dir):
    """Check the status of a single agent."""
    output_file = Path(output_dir) / f"{agent_id}.output"

    if not output_file.exists():
        return "waiting", 0

    size = output_file.stat().st_size
    if size == 0:
        return "running", 0

    return "complete", size


def format_bytes(size):
    """Format bytes in human-readable format."""
    for unit in ['B', 'KB', 'MB']:
        if size < 1024:
            return f"{size:6.0f}{unit}"
        size /= 1024
    return f"{size:6.0f}GB"


def main():
    parser = argparse.ArgumentParser(
        description="Wait for Phase 2 agents to complete"
    )
    parser.add_argument('--timeout', type=int, default=600,
                        help='Timeout in seconds (default: 600)')
    parser.add_argument('--interval', type=int, default=5,
                        help='Check interval in seconds (default: 5)')
    parser.add_argument('--agents', nargs='+',
                        default=['ad18b41a80c0d1de0', 'a842e402b5e13aa86', 'aee5e5ec6b0c44dcc'],
                        help='Agent IDs to monitor')

    args = parser.parse_args()

    output_dir = get_agent_output_dir()
    start_time = time.time()

    print(f"⏳ Waiting for Phase 2 agents to complete (timeout: {args.timeout}s)...")
    print(f"📁 Output directory: {output_dir}")
    print(f"🤖 Agents: {', '.join(args.agents)}")
    print()

    while True:
        now = time.time()
        elapsed = int(now - start_time)

        # Check timeout
        if elapsed > args.timeout:
            print(f"❌ TIMEOUT: Agents did not complete within {args.timeout} seconds")
            return 1

        # Check each agent
        all_done = True
        print(f"[{datetime.now().strftime('%H:%M:%S')}] Status (elapsed: {elapsed}s)")

        for agent in args.agents:
            status, size = check_agent_status(agent, output_dir)

            if status == "waiting":
                print(f"  ⏳ [{agent}] Waiting to start...")
                all_done = False
            elif status == "running":
                print(f"  🔄 [{agent}] Running (0 bytes)")
                all_done = False
            else:  # complete
                size_str = format_bytes(size)
                print(f"  ✅ [{agent}] Complete ({size_str})")

        if all_done:
            print()
            print("🎉 All agents have completed!")
            return 0

        print()
        time.sleep(args.interval)


if __name__ == '__main__':
    sys.exit(main())
