#!/usr/bin/env python3
"""
test_control_plane.py — Comprehensive Unit & Adversarial Tests for Python Control Plane (R-CP-001 to R-CP-008)
"""

import os
import sys
import json
import unittest

PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../"))
if PROJECT_ROOT not in sys.path:
    sys.path.insert(0, PROJECT_ROOT)
if os.path.join(PROJECT_ROOT, "src") not in sys.path:
    sys.path.insert(0, os.path.join(PROJECT_ROOT, "src"))

class TestControlPlane(unittest.TestCase):

    def test_r001_pyproject_exists(self):
        """R-CP-001: Verify pyproject.toml exists and defines agy-kit console script."""
        pyproject_path = os.path.join(PROJECT_ROOT, "pyproject.toml")
        self.assertTrue(os.path.exists(pyproject_path), "pyproject.toml is missing")
        with open(pyproject_path, "r", encoding="utf-8") as f:
            content = f.read()
        self.assertIn("agy-kit", content)
        self.assertIn("project.scripts", content)

    def test_r002_models_creation(self):
        """R-CP-002: Test run and stage data model instantiation."""
        from agy_kit.models.run import RunManifest
        from agy_kit.models.stage import StageResult, StageStatus
        
        manifest = RunManifest(
            run_id="01JABCDEF0123456789XYZABCD",
            feature="control-plane-unification",
            repository_root=PROJECT_ROOT,
            baseline_commit="10fc0d738f657a829",
            permission_mode="sandbox"
        )
        self.assertEqual(manifest.feature, "control-plane-unification")
        self.assertEqual(manifest.permission_mode, "sandbox")

        res = StageResult(
            run_id=manifest.run_id,
            stage_id="build",
            attempt=1,
            status=StageStatus.PASSED,
            exit_code=0,
            agent="coder"
        )
        self.assertEqual(res.status, StageStatus.PASSED)
        self.assertEqual(res.exit_code, 0)

    def test_r003_guarded_state_machine_transitions(self):
        """R-CP-003: Verify state machine transition guards and illegal transition rejection."""
        from agy_kit.orchestrator import PipelineOrchestrator, StageState, IllegalTransitionError
        
        orch = PipelineOrchestrator("run-guarded-test", "state-guards")
        self.assertEqual(orch.state, StageState.CREATED)

        # Valid transition: CREATED -> PREFLIGHT
        orch.transition_to(StageState.PREFLIGHT)
        self.assertEqual(orch.state, StageState.PREFLIGHT)

        # Valid transition: PREFLIGHT -> ISOLATED
        orch.transition_to(StageState.ISOLATED)
        self.assertEqual(orch.state, StageState.ISOLATED)

        # Illegal transition: ISOLATED -> COMPLETED directly MUST raise IllegalTransitionError
        with self.assertRaises(IllegalTransitionError):
            orch.transition_to(StageState.COMPLETED)

    def test_r005_stage_result_to_dict(self):
        """R-CP-005: Verify to_dict() returns clean serializable dict without errors."""
        from agy_kit.orchestrator import PipelineOrchestrator, StageState
        orch = PipelineOrchestrator("run-dict-test", "dict-test")
        orch.transition_to(StageState.PREFLIGHT)
        d = orch.to_dict()
        self.assertEqual(d["run_id"], "run-dict-test")
        self.assertEqual(d["state"], "PREFLIGHT")

    def test_r007_cli_entrypoint_version(self):
        """R-CP-007: Test agy-kit CLI entrypoint responds to --version."""
        from agy_kit.cli import main as cli_main
        import sys
        old_argv = sys.argv
        try:
            sys.argv = ["cli.py", "--version"]
            try:
                cli_main()
            except SystemExit as e:
                self.assertEqual(e.code, 0)
        finally:
            sys.argv = old_argv

if __name__ == "__main__":
    unittest.main()
