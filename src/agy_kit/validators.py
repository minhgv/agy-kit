"""
validators.py — Path safety, traversal, and boundary security validators
"""

import os

def validate_path_safety(file_path: str, allowlisted_root: str) -> bool:
    """
    Validates that file_path is within allowlisted_root and free of path traversal attempts.
    """
    if not file_path or not allowlisted_root:
        return False
        
    if ".." in file_path or file_path.startswith("-") or "\n" in file_path:
        return False
        
    try:
        abs_root = os.path.realpath(allowlisted_root)
        abs_file = os.path.realpath(os.path.join(abs_root, file_path))
        return os.path.commonpath([abs_root, abs_file]) == abs_root
    except Exception:
        return False
