"""
orchestrator.py — Guarded state machine for agy-kit pipeline orchestration
"""

from enum import Enum
from typing import Any, Dict, List, Set


class IllegalTransitionError(Exception):
    """Raised when an illegal state transition is attempted."""

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
    CANCELLED = "CANCELLED"

# Valid state transition matrix per Proposal Section 6.2
VALID_TRANSITIONS: Dict[StageState, Set[StageState]] = {
    StageState.CREATED: {StageState.PREFLIGHT, StageState.FAILED, StageState.CANCELLED},
    StageState.PREFLIGHT: {StageState.ISOLATED, StageState.FAILED, StageState.CANCELLED},
    StageState.ISOLATED: {StageState.PLANNED, StageState.FAILED, StageState.CANCELLED},
    StageState.PLANNED: {StageState.APPROVED, StageState.CANCELLED, StageState.FAILED},
    StageState.APPROVED: {StageState.BUILT, StageState.FAILED, StageState.CANCELLED},
    StageState.BUILT: {StageState.GATED, StageState.FAILED, StageState.CANCELLED},
    StageState.GATED: {StageState.QA_PASSED, StageState.FAILED, StageState.CANCELLED},
    StageState.QA_PASSED: {StageState.REVIEWED, StageState.FAILED, StageState.CANCELLED},
    StageState.REVIEWED: {StageState.COMPLETED, StageState.FAILED, StageState.CANCELLED},
    StageState.FAILED: set(),
    StageState.COMPLETED: set(),
    StageState.CANCELLED: set()
}

class PipelineOrchestrator:

    def __init__(self, run_id: str, feature: str):
        self.run_id = run_id
        self.feature = feature
        self.state = StageState.CREATED
        self.state_revision = 0
        self.stage_results: List[Dict[str, Any]] = []

    def transition_to(self, new_state: StageState):
        """Transition to new state with strict transition guards."""
        allowed = VALID_TRANSITIONS.get(self.state, set())
        if new_state not in allowed:
            raise IllegalTransitionError(
                f"Illegal state transition from {self.state.value} to {new_state.value}. Allowed: {[s.value for s in allowed]}"
            )
        self.state = new_state
        self.state_revision += 1

    def to_dict(self) -> Dict[str, Any]:
        """Return serializable dictionary of orchestrator state."""
        return {
            "run_id": self.run_id,
            "feature": self.feature,
            "state": self.state.value,
            "state_revision": self.state_revision,
            "stage_results": self.stage_results
        }
