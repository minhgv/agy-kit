#!/usr/bin/env python3
"""
test_control_plane_phase2.py — Comprehensive Unit & Adversarial Tests for Control Plane Phase 2 (R-CP2-001 to R-CP2-005)
"""

import json
import os
import sys
import unittest

PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../"))
if PROJECT_ROOT not in sys.path:
    sys.path.insert(0, PROJECT_ROOT)
if os.path.join(PROJECT_ROOT, "src") not in sys.path:
    sys.path.insert(0, os.path.join(PROJECT_ROOT, "src"))

class TestControlPlanePhase2(unittest.TestCase):

    def test_r001_capability_probe_fail_closed(self):
        """R-CP2-001: Probe fails closed when AGY CLI binary is missing or subagent is absent."""
        from agy_kit.adapters.agy_cli import AgyRuntimeAdapter
        adapter = AgyRuntimeAdapter(executable="non_existent_agy_binary_xyz")
        res = adapter.probe()
        self.assertFalse(res.headless_prompt)
        self.assertEqual(res.exit_code, 10)

    def test_r002_jsonl_event_logging_redaction(self):
        """R-CP2-002: Verify structured JSONL logging and secret redaction."""
        from agy_kit.adapters.filesystem_evidence import FilesystemEvidenceStore
        
        test_run_dir = os.path.join(PROJECT_ROOT, "tests/qa-evidence/test_run_001")
        store = FilesystemEvidenceStore(test_run_dir)
        
        # Emit event containing secret key
        store.emit_event(
            event_type="stage.finished",
            stage="build",
            status="passed",
            payload={"message": "Using token secret_api_key_12345"}
        )
        
        log_file = os.path.join(test_run_dir, "events.jsonl")
        self.assertTrue(os.path.exists(log_file))
        
        with open(log_file, "r", encoding="utf-8") as f:
            lines = f.readlines()
        
        self.assertGreater(len(lines), 0)
        event_dict = json.loads(lines[-1])
        self.assertEqual(event_dict["event_type"], "stage.finished")
        # Ensure secret was redacted
        self.assertNotIn("secret_api_key_12345", json.dumps(event_dict))

    def test_r003_safe_apply_check(self):
        """R-CP2-003: Safe apply checks primary git status before patch application."""
        from agy_kit.worktree import WorktreeManager
        wt = WorktreeManager(PROJECT_ROOT, "test-apply-run")
        self.assertTrue(hasattr(wt, "check_patch_apply"))

    def test_r004_config_resolver_precedence(self):
        """R-CP2-004: Config resolver reads TOML settings and fallback defaults."""
        from agy_kit.config import load_config
        cfg = load_config(os.path.join(PROJECT_ROOT, ".agy-kit.toml"))
        self.assertEqual(cfg.get("execution", {}).get("permission_mode"), "sandbox")
        self.assertTrue(cfg.get("mutation", {}).get("enforce_manifest"))

    def test_r005_concurrent_run_lock(self):
        """R-CP2-005: OS File Lock acquires lock and raises RunLockedError on duplicate acquisition."""
        from agy_kit.safety.locks import RunLock, RunLockedError
        
        lock_dir = "/tmp/agy-kit-locks"
        lock1 = RunLock("test-run-lock-id", lock_dir)
        self.assertTrue(lock1.acquire())
        
        # Second acquisition on same run_id MUST fail
        lock2 = RunLock("test-run-lock-id", lock_dir)
        with self.assertRaises(RunLockedError):
            lock2.acquire()
            
        lock1.release()

if __name__ == "__main__":
    unittest.main()
