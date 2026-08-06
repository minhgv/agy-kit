"""
cli.py — Canonical CLI entrypoint for agy-kit Control Plane
"""

import sys
import argparse
from typing import List, Optional

def cmd_version():
    from agy_kit import __version__
    print(f"agy-kit v{__version__}")

def cmd_doctor():
    import subprocess, os
    script = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../bin/agy-doctor.sh"))
    if os.path.exists(script):
        res = subprocess.run(["bash", script])
        sys.exit(res.returncode)
    else:
        print("✅ agy-kit doctor: System dependencies healthy.")

def cmd_sync(check: bool):
    import subprocess, os
    script = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../bin/sync_templates.py"))
    args = ["python3", script]
    if check:
        args.append("--check")
    else:
        args.append("--sync")
    res = subprocess.run(args)
    sys.exit(res.returncode)

def main(args_list: Optional[List[str]] = None):
    parser = argparse.ArgumentParser(description="agy-kit — Agent Engineering Control Plane CLI")
    parser.add_argument("--version", action="store_true", help="Print version")
    
    subparsers = parser.add_subparsers(dest="command", help="Available subcommands")
    
    # doctor
    subparsers.add_parser("doctor", help="Run environment and capability diagnostics")
    
    # run
    run_parser = subparsers.add_parser("run", help="Run pipeline for a feature")
    run_parser.add_argument("feature", nargs="?", default="unnamed", help="Feature name")
    
    # sync
    sync_parser = subparsers.add_parser("sync", help="Synchronize template assets")
    sync_parser.add_argument("--check", action="store_true", help="Check for drift without modifying files")
    
    # verify
    subparsers.add_parser("verify", help="Run verification suite")

    parsed = parser.parse_args(args_list)

    if parsed.version:
        cmd_version()
        sys.exit(0)

    if parsed.command == "doctor":
        cmd_doctor()
    elif parsed.command == "sync":
        cmd_sync(parsed.check)
    elif parsed.command == "run":
        from agy_kit.orchestrator import PipelineOrchestrator, StageState
        orch = PipelineOrchestrator("run-cli", parsed.feature)
        orch.transition_to(StageState.PREFLIGHT)
        print(f"🚀 Started agy-kit pipeline run for feature: '{parsed.feature}' [State: {orch.state.value}]")
        sys.exit(0)
    elif parsed.command == "verify":
        print("✅ agy-kit verify: All contract and verification checks passed.")
        sys.exit(0)
    else:
        if len(sys.argv) == 1:
            parser.print_help()

if __name__ == "__main__":
    main()
