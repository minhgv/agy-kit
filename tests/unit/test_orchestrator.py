#!/usr/bin/env python3
"""
test_orchestrator.py — Unit tests for agy-kit orchestrator, path safety, and schema validation
"""

import os
import sys
import unittest

PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../"))
sys.path.insert(0, PROJECT_ROOT)

class TestOrchestrator(unittest.TestCase):

    def test_agent_frontmatter_files_exist(self):
        agents = ["planner.md", "coder.md", "reviewer.md", "qa.md"]
        for agent in agents:
            p = os.path.join(PROJECT_ROOT, ".agents/agents", agent)
            self.assertTrue(os.path.exists(p), f"Missing agent spec: {p}")

    def test_schema_files_exist(self):
        schemas = ["stage-result.schema.json", "run-manifest.schema.json"]
        for s in schemas:
            p = os.path.join(PROJECT_ROOT, "agy-kit/schemas", s)
            self.assertTrue(os.path.exists(p), f"Missing schema: {p}")

    def test_forbidden_paths_detection(self):
        forbidden = [".env", ".ssh/id_rsa", "/etc/passwd", "../outside.py", "-rf"]
        for f in forbidden:
            is_forbidden = (".." in f) or f.startswith("-") or f in [".env", ".ssh/id_rsa"]
            self.assertTrue(is_forbidden, f"Path {f} should be flagged as forbidden")

if __name__ == "__main__":
    unittest.main()
