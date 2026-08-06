#!/usr/bin/env python3
"""
test_src_hybrid.py — Unit tests for Hybrid src/ directory structure (R-SRC-001 to R-SRC-004)
"""
from __future__ import annotations

import os
import sys
import unittest

PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../"))
if PROJECT_ROOT not in sys.path:
    sys.path.insert(0, PROJECT_ROOT)
if os.path.join(PROJECT_ROOT, "src") not in sys.path:
    sys.path.insert(0, os.path.join(PROJECT_ROOT, "src"))

class TestSrcHybrid(unittest.TestCase):

    def test_r001_templates_exist(self):
        """R-SRC-001: Verify src/templates/ contains all canonical scaffolding assets."""
        templates_dir = os.path.join(PROJECT_ROOT, "src/templates")
        self.assertTrue(os.path.isdir(templates_dir), "src/templates directory missing")
        
        required_templates = [
            "AGENTS.md.tpl",
            "mcp_config.json.tpl",
            "version.json.tpl",
            "agents/planner.md",
            "agents/coder.md",
            "agents/reviewer.md",
            "agents/qa.md"
        ]
        for t in required_templates:
            p = os.path.join(templates_dir, t)
            self.assertTrue(os.path.exists(p), f"Missing template asset: {t}")

    def test_r002_agy_kit_package_import(self):
        """R-SRC-002: Verify src/agy_kit/ Python package can be imported."""
        try:
            import agy_kit
            import agy_kit.cli
            import agy_kit.orchestrator
            import agy_kit.validators
            import agy_kit.worktree  # noqa: F401
            imported = True
        except ImportError as e:
            imported = False
            print(f"Import error: {e}")
        self.assertTrue(imported, "Failed to import agy_kit modules from src/")

    def test_r004_path_validator_traversal(self):
        """R-SRC-004: Verify path boundary validator rejects path traversal."""
        from agy_kit.validators import validate_path_safety
        self.assertTrue(validate_path_safety("src/templates/AGENTS.md.tpl", PROJECT_ROOT))
        self.assertFalse(validate_path_safety("../outside.txt", PROJECT_ROOT))
        self.assertFalse(validate_path_safety("/etc/passwd", PROJECT_ROOT))

    def test_sync_templates_no_drift(self):
        """Verify bin/sync_templates.py runs and confirms template synchronization."""
        import sys

        from bin.sync_templates import main as sync_main
        old_argv = sys.argv
        try:
            sys.argv = ["sync_templates.py", "--sync"]
            try:
                sync_main()
            except SystemExit as e:
                self.assertEqual(e.code, 0)
        finally:
            sys.argv = old_argv

if __name__ == "__main__":
    unittest.main()
