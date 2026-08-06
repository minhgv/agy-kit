#!/usr/bin/env python3
"""
fix_linter.py — Root-Cause Autonomous Linter Auto-Fixer (FR-MNT-002 & G2.3 Anti-Over-Suppression)
"""
from __future__ import annotations

import os
import re
import stat
import sys

PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "../"))


def fix_file_permissions(filepath: str) -> bool:
    """Fixes EXE001 Root Cause: Sets chmod +x on shebang files."""
    try:
        with open(filepath, "r", encoding="utf-8", errors="ignore") as f:
            first_line = f.readline()
        if first_line.startswith("#!"):
            st = os.stat(filepath)
            if not (st.st_mode & stat.S_IXUSR):
                os.chmod(filepath, st.st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)
                return True
    except Exception:  # noqa: BLE001, S110
        pass
    return False


def fix_subprocess_check(content: str) -> str:
    """Fixes PLW1510 Root Cause: Adds explicit check=False to subprocess.run calls missing check arg."""
    pattern = r'(subprocess\.run\([^)]*?)(?<!check=False)(?<!check=True)\)'
    
    def replacer(match):
        sub_call = match.group(1)
        if "check=" not in sub_call:
            return sub_call + ", check=False)"
        return match.group(0)

    return re.sub(pattern, replacer, content)


def fix_type_annotations(content: str) -> str:
    """Fixes UP006, UP035, FA100, I001 Root Cause: Modernizes annotations and organizes future imports."""
    new_content = content

    # Clean double newlines after from __future__ import annotations to satisfy I001 (isort)
    new_content = re.sub(r'from __future__ import annotations\n\n\n+', 'from __future__ import annotations\n\n', new_content)

    # Clean improperly placed future imports
    lines = new_content.split("\n")
    cleaned_lines = []
    future_seen = False
    for line in lines:
        if line.strip() == "from __future__ import annotations":
            if future_seen:
                continue
            future_seen = True
        cleaned_lines.append(line)
    new_content = "\n".join(cleaned_lines)

    # Ensure from __future__ import annotations is placed right after docstring
    if "from __future__ import annotations" not in new_content:
        if new_content.startswith("#!/usr/bin/env python3\n\"\"\""):
            doc_end = new_content.find("\"\"\"\n", 25)
            if doc_end != -1:
                insert_pos = doc_end + 4
                new_content = new_content[:insert_pos] + "from __future__ import annotations\n\n" + new_content[insert_pos:]
            else:
                new_content = new_content.replace("#!/usr/bin/env python3\n", "#!/usr/bin/env python3\nfrom __future__ import annotations\n\n", 1)
        elif new_content.startswith("#!"):
            new_content = re.sub(r'^(#!/[^\n]+\n)', r'\1from __future__ import annotations\n\n', new_content)
        else:
            new_content = "from __future__ import annotations\n\n" + new_content

    # Replace typing generic annotations with native stdlib types
    new_content = re.sub(r'\bDict\[', 'dict[', new_content)
    new_content = re.sub(r'\bList\[', 'list[', new_content)
    new_content = re.sub(r'\bSet\[', 'set[', new_content)
    new_content = re.sub(r'\bOptional\[([^\]]+)\]', r'\1 | None', new_content)

    return new_content


def process_file(filepath: str) -> bool:
    """Processes a single Python file to fix root causes without noqa spamming."""
    modified = False
    
    # 1. Fix executable permissions
    if fix_file_permissions(filepath):
        modified = True

    try:
        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()

        original = content
        content = fix_subprocess_check(content)
        content = fix_type_annotations(content)

        if content != original:
            with open(filepath, "w", encoding="utf-8") as f:
                f.write(content)
            modified = True
    except Exception as e:  # noqa: BLE001
        print(f"Warning: Could not process {filepath}: {e}", file=sys.stderr)

    return modified


def main():
    print("==================================================")
    print("   agy-kit Root-Cause Autonomous Linter Fixer    ")
    print("==================================================")

    targets = [
        os.path.join(PROJECT_ROOT, "src"),
        os.path.join(PROJECT_ROOT, "tests"),
        os.path.join(PROJECT_ROOT, "bin"),
    ]

    total_checked = 0
    total_fixed = 0

    for target in targets:
        if os.path.isfile(target) and target.endswith(".py"):
            total_checked += 1
            if process_file(target):
                total_fixed += 1
        elif os.path.isdir(target):
            for root, _, files in os.walk(target):
                for f in files:
                    if f.endswith(".py"):
                        full_p = os.path.join(root, f)
                        total_checked += 1
                        if process_file(full_p):
                            total_fixed += 1

    print(f"✅ Scanned {total_checked} files. Root cause fixed {total_fixed} files in 1 pass.")
    sys.exit(0)


if __name__ == "__main__":
    main()
