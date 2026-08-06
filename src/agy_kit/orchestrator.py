"""
orchestrator.py — Typed state machine for agy-kit pipeline orchestration
"""

from enum import Enum
from typing import Dict, Any, List

class StageState(Enum):
    CREATED = "CREATED"
    PREFLIGHT = "PREFLIGHT"
    ISOLATED = "ISOLATED"
    PLANNED = "PLANNED"
    APPROVED = "APPROVED"
    BUILT = "BUILT"
    GATED = "GATED"
    QA_PASSED = "QA_PASSED"
    REVIEWED = "REVIEWED"
    COMPLETED = "COMPLETED"
    FAILED = "FAILED"

class PipelineOrchestrator:

    def __init__(self, run_id: str, feature: str):
        self.run_id = run_id
        self.feature = feature
        self.state = StageState.CREATED
        self.stage_results: List[Dict[str, Any]] = []

    def transition_to(self, new_state: StageState):
        self.state = new_state

    def to_dict() -> Dict[str, Any]:
        return {
            "run_id": self.run_id,
            "feature": self.feature,
            "state": self.state.value,
            "stage_results": self.stage_results
        }
