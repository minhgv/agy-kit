"""
worktree.py — Git worktree isolation manager & safe apply checker
"""

import os
import subprocess
import tempfile
from typing import Optional


class WorktreeManager:

    def __init__(self, project_root: str, run_id: str):
        self.project_root: str = project_root
        self.run_id: str = run_id
        self.worktree_dir: Optional[str] = None

    def create_isolated_worktree(self, feature: str) -> str:
        branch_name = f"agy-wt-{feature}-{self.run_id}"
        temp_dir = tempfile.mkdtemp(prefix=f"agy-wt-{self.run_id}-")
        cmd = ["git", "-C", self.project_root, "worktree", "add", "-b", branch_name, temp_dir, "HEAD"]
        subprocess.run(cmd, check=True, capture_output=True)
        self.worktree_dir = temp_dir
        return temp_dir

    def check_patch_apply(self, patch_file: str) -> bool:
        """Pre-checks if patch can be applied cleanly using git apply --check."""
        if not os.path.exists(patch_file):
            return False
        cmd = ["git", "-C", self.project_root, "apply", "--check", patch_file]
        res = subprocess.run(cmd, capture_output=True)
        return res.returncode == 0

    def remove_worktree(self):
        if self.worktree_dir and os.path.exists(self.worktree_dir):
            subprocess.run(["git", "-C", self.project_root, "worktree", "remove", "--force", self.worktree_dir], capture_output=True)
