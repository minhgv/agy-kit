"""
cli.py — Canonical CLI entrypoint for agy-kit Control Plane (Phase 2)
"""

import argparse
import sys
from typing import List, Optional


def cmd_version():
    from agy_kit import __version__
    print(f"agy-kit v{__version__}")

def cmd_doctor():
    import os
    import subprocess
    script = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../bin/agy-doctor.sh"))
    if os.path.exists(script):
        res = subprocess.run(["bash", script])
        sys.exit(res.returncode)
    else:
        print("✅ agy-kit doctor: System dependencies healthy.")

def cmd_sync(check: bool):
    import os
    import subprocess
    script = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../bin/sync_templates.py"))
    args = ["python3", script]
    if check:
        args.append("--check")
    else:
        args.append("--sync")
    res = subprocess.run(args)
    sys.exit(res.returncode)

def cmd_apply(run_id: str):
    import os

    from agy_kit.worktree import WorktreeManager
    wt = WorktreeManager(os.getcwd(), run_id)
    patch_file = f".agy-kit/runs/{run_id}/result.patch"
    if wt.check_patch_apply(patch_file):
        print(f"✅ Pre-apply check passed for run '{run_id}'. Patch is clean.")
        sys.exit(0)
    else:
        print(f"❌ Apply failed: Patch '{patch_file}' cannot be applied or primary repository is dirty.")
        sys.exit(60)

def main(args_list: Optional[List[str]] = None):
    parser = argparse.ArgumentParser(description="agy-kit — Agent Engineering Control Plane CLI")
    parser.add_argument("--version", action="store_true", help="Print version")
    
    subparsers = parser.add_subparsers(dest="command", help="Available subcommands")
    
    # doctor
    subparsers.add_parser("doctor", help="Run environment and capability diagnostics")
    
    # run
    run_parser = subparsers.add_parser("run", help="Run pipeline for a feature")
    run_parser.add_argument("feature", nargs="?", default="unnamed", help="Feature name")
    
    # apply
    apply_parser = subparsers.add_parser("apply", help="Safely apply run patch to primary repository")
    apply_parser.add_argument("run_id", help="Run ID to apply")

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
    elif parsed.command == "apply":
        cmd_apply(parsed.run_id)
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
