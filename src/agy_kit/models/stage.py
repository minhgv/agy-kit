"""
stage.py — Stage Request & Result data models
"""
from __future__ import annotations

import time
from dataclasses import dataclass, field
from enum import Enum
from typing import Any


class StageStatus(Enum):
    PASSED = "passed"
    FAILED = "failed"
    CANCELLED = "cancelled"
    TIMED_OUT = "timed_out"
    BLOCKED = "blocked"

@dataclass
class StageResult:
    run_id: str
    stage_id: str
    attempt: int
    status: StageStatus
    exit_code: int
    agent: str
    schema_version: str = "1.0"
    started_at: float = field(default_factory=time.time)
    finished_at: float = field(default_factory=time.time)
    changed_files: list[str] = field(default_factory=list)
    checks: list[dict[str, Any]] = field(default_factory=list)
    error: str | None = None

    def to_dict(self) -> dict[str, Any]:
        return {
            "schema_version": self.schema_version,
            "run_id": self.run_id,
            "stage_id": self.stage_id,
            "attempt": self.attempt,
            "status": self.status.value,
            "exit_code": self.exit_code,
            "agent": self.agent,
            "started_at": self.started_at,
            "finished_at": self.finished_at,
            "changed_files": self.changed_files,
            "checks": self.checks,
            "error": self.error
        }
