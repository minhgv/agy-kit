#!/usr/bin/env python3
"""
test_fix_linter.py — Unit tests for autonomous bin/fix_linter.py script
"""
from __future__ import annotations

import os
import sys
import tempfile
import unittest

PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../"))
if PROJECT_ROOT not in sys.path:
    sys.path.insert(0, PROJECT_ROOT)

BIN_DIR = os.path.join(PROJECT_ROOT, "bin")
if BIN_DIR not in sys.path:
    sys.path.insert(0, BIN_DIR)


class TestFixLinter(unittest.TestCase):

    def setUp(self):
        self.temp_dir = tempfile.mkdtemp(prefix="test_linter_")

    def tearDown(self):
        import shutil
        if os.path.exists(self.temp_dir):
            shutil.rmtree(self.temp_dir)

    def test_exe001_shebang_chmod(self):
        """Verify fix-linter sets chmod +x on files with python shebang."""
        script_file = os.path.join(self.temp_dir, "script.py")
        with open(script_file, "w") as f:
            f.write("#!/usr/bin/env python3\nprint('hello')\n")

        os.chmod(script_file, 0o644)
        self.assertFalse(os.access(script_file, os.X_OK))

        from fix_linter import fix_file_permissions
        fix_file_permissions(script_file)

        self.assertTrue(os.access(script_file, os.X_OK))

    def test_plw1510_subprocess_check(self):
        """Verify fix-linter adds check=False to subprocess.run calls missing check arg."""
        from fix_linter import fix_subprocess_check
        code = 'subprocess.run(["ls"], capture_output=True, check=False)'
        fixed = fix_subprocess_check(code)
        self.assertIn("check=False", fixed)

    def test_ble001_s110_except_pass(self):
        """Verify fix-linter adds noqa comments to try-except pass blocks."""
        from fix_linter import fix_except_pass
        code = "try:\n    do_something()\nexcept Exception:\n    pass\n"
        fixed = fix_except_pass(code)
        self.assertIn("# noqa: BLE001, S110", fixed)

    def test_up006_type_annotations(self):
        """Verify fix-linter replaces Dict/List annotations with dict/list and adds future import."""
        from fix_linter import fix_type_annotations
        code = "from typing import Dict, List\ndef foo(a: dict[str, Any]) -> list[str]:\n    pass\n"
        fixed = fix_type_annotations(code)
        self.assertIn("from __future__ import annotations", fixed)
        self.assertIn("dict[str, Any]", fixed)
        self.assertIn("list[str]", fixed)


if __name__ == "__main__":
    unittest.main()
