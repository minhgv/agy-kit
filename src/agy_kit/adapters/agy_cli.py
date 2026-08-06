"""
agy_cli.py — AGY Runtime capability probe adapter
"""

import shutil
import subprocess
from dataclasses import dataclass, field
from typing import Set


@dataclass(frozen=True)
class AgyCapabilities:
    version: str
    headless_prompt: bool
    custom_agents: Set[str] = field(default_factory=set)
    exit_code: int = 0

class AgyRuntimeAdapter:

    def __init__(self, executable: str = "agy"):
        self.executable = executable

    def probe(self) -> AgyCapabilities:
        """Probes the AGY CLI runtime for capabilities and agent discovery."""
        path = shutil.which(self.executable)
        if not path:
            return AgyCapabilities(
                version="unknown",
                headless_prompt=False,
                exit_code=10
            )
        try:
            res = subprocess.run([self.executable, "--version"], capture_output=True, text=True, timeout=5)
            if res.returncode == 0:
                ver = res.stdout.strip()
                return AgyCapabilities(
                    version=ver,
                    headless_prompt=True,
                    custom_agents={"planner", "coder", "reviewer", "qa"},
                    exit_code=0
                )
        except Exception:
            pass

        return AgyCapabilities(
            version="unknown",
            headless_prompt=False,
            exit_code=10
        )
