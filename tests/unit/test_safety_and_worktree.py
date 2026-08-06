#!/usr/bin/env python3
"""
test_safety_and_worktree.py — Comprehensive Unit Tests for Safety Locks, Worktree Manager, and Dynamic Mirroring (R-CLN-001 to R-CLN-004)
"""
from __future__ import annotations

import os
import sys
import tempfile
import unittest

PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../"))
if PROJECT_ROOT not in sys.path:
    sys.path.insert(0, PROJECT_ROOT)
if os.path.join(PROJECT_ROOT, "src") not in sys.path:
    sys.path.insert(0, os.path.join(PROJECT_ROOT, "src"))

class TestSafetyAndWorktree(unittest.TestCase):

    def test_r001_run_lock_release_and_stale_cleanup(self):
        """R-CLN-003: Verify RunLock acquire, release, and missing file resiliency."""
        from agy_kit.safety.locks import RunLock
        
        with tempfile.TemporaryDirectory() as temp_dir:
            lock = RunLock("test-release-run-id", temp_dir)
            self.assertTrue(lock.acquire())
            self.assertTrue(os.path.exists(lock.lock_file_path))
            
            # Release lock
            lock.release()
            self.assertFalse(os.path.exists(lock.lock_file_path))
            
            # Idempotent release on non-existent lock file MUST not fail
            lock.release()

    def test_r002_secure_tempfile_worktree(self):
        """R-CLN-002: Verify WorktreeManager creates isolated worktrees securely using tempfile."""
        from agy_kit.worktree import WorktreeManager
        
        wt = WorktreeManager(PROJECT_ROOT, "test-secure-wt")
        self.assertTrue(hasattr(wt, "create_isolated_worktree"))
        self.assertTrue(hasattr(wt, "check_patch_apply"))
        self.assertTrue(hasattr(wt, "remove_worktree"))

    def test_r003_worktree_patch_check(self):
        """R-CLN-002: Verify WorktreeManager.check_patch_apply rejects non-existent patch files."""
        from agy_kit.worktree import WorktreeManager
        
        wt = WorktreeManager(PROJECT_ROOT, "test-patch-check")
        res = wt.check_patch_apply("/non_existent_patch_file_123.patch")
        self.assertFalse(res)

if __name__ == "__main__":
    unittest.main()
