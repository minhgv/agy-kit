#!/usr/bin/env python3
"""
fake_agy.py — Deterministic Fake AGY CLI for offline harness testing (FR-TEST-002)

Simulates AGY CLI behavior:
- `agy --version` -> prints "agy v1.1.5"
- `agy --help` -> prints available flags
- `agy -p "<prompt>"` -> simulates stage execution based on environment flags:
    - FAKE_AGY_FAIL=1: exits with non-zero code 1
    - FAKE_AGY_UNSUPPORTED=1: outputs unsupported version error
    - FAKE_AGY_LEAK_SECRET=1: writes a secret key to output
"""

import os
import sys


def main():
    args = sys.argv[1:]
    
    if os.environ.get("FAKE_AGY_UNSUPPORTED") == "1":
        print("Error: Unsupported AGY version v0.1.0", file=sys.stderr)
        sys.exit(1)
        
    if "--version" in args:
        print("agy v1.1.5")
        sys.exit(0)
        
    if "--help" in args:
        print("Antigravity CLI (agy) v1.1.5")
        print("Usage: agy -p <prompt>")
        sys.exit(0)

    if os.environ.get("FAKE_AGY_FAIL") == "1":
        print("Error: Agent execution failed", file=sys.stderr)
        sys.exit(1)

    if os.environ.get("FAKE_AGY_LEAK_SECRET") == "1":
        print("Warning: Generated token sk-proj-12345678901234567890_FAKE_KEY")
        
    print("Stage completed successfully.")
    sys.exit(0)

if __name__ == "__main__":
    main()
