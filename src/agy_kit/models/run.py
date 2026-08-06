"""
run.py — Pipeline Run Manifest data model
"""

import time
from dataclasses import dataclass, field
from typing import Any, Dict, List


@dataclass
class RunManifest:
    run_id: str
    feature: str
    repository_root: str
    baseline_commit: str
    permission_mode: str = "sandbox"
    apply_policy: str = "never"
    schema_version: str = "1.0"
    created_at: float = field(default_factory=time.time)
    stages: List[str] = field(default_factory=lambda: ["plan", "build", "gate", "qa", "review"])
    resolved_agents: Dict[str, str] = field(default_factory=lambda: {
        "plan": "planner",
        "build": "coder",
        "gate": "reviewer",
        "qa": "qa",
        "review": "reviewer"
    })

    def to_dict(self) -> Dict[str, Any]:
        return {
            "schema_version": self.schema_version,
            "run_id": self.run_id,
            "feature": self.feature,
            "repository_root": self.repository_root,
            "baseline_commit": self.baseline_commit,
            "created_at": self.created_at,
            "permission_mode": self.permission_mode,
            "apply_policy": self.apply_policy,
            "stages": self.stages,
            "resolved_agents": self.resolved_agents
        }
