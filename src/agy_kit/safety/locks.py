"""
locks.py — OS file lock manager for run concurrency protection
"""

import os
import fcntl

class RunLockedError(Exception):
    """Raised when a run_id is locked by another process."""
    pass

class RunLock:

    def __init__(self, run_id: str, lock_dir: str):
        self.run_id = run_id
        self.lock_dir = lock_dir
        self.lock_file_path = os.path.join(lock_dir, f".run_{run_id}.lock")
        self.file_obj = None

    def acquire(self) -> bool:
        os.makedirs(self.lock_dir, exist_ok=True)
        try:
            self.file_obj = open(self.lock_file_path, "w")
            fcntl.flock(self.file_obj.fileno(), fcntl.LOCK_EX | fcntl.LOCK_NB)
            return True
        except (IOError, OSError):
            if self.file_obj:
                self.file_obj.close()
                self.file_obj = None
            raise RunLockedError(f"Run ID '{self.run_id}' is already locked by another process.")

    def release(self):
        if self.file_obj:
            try:
                fcntl.flock(self.file_obj.fileno(), fcntl.LOCK_UN)
                self.file_obj.close()
            except Exception:
                pass
            self.file_obj = None
        if os.path.exists(self.lock_file_path):
            try:
                os.remove(self.lock_file_path)
            except Exception:
                pass
