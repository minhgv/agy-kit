"""
filesystem_evidence.py — Structured JSONL Event Logger & Secret Redactor
"""

import json
import os
import re
import time
from typing import Any

SECRET_REGEX = re.compile(r"(secret_[a-zA-Z0-9_-]+|api_key_[a-zA-Z0-9_-]+|password\s*=\s*\S+)", re.IGNORECASE)

def redact_payload(data: Any) -> Any:
    """Recursively redacts secret strings in payload data."""
    if isinstance(data, str):
        return SECRET_REGEX.sub("[REDACTED]", data)
    elif isinstance(data, dict):
        return {k: redact_payload(v) for k, v in data.items()}
    elif isinstance(data, list):
        return [redact_payload(item) for item in data]
    return data

class FilesystemEvidenceStore:

    def __init__(self, run_dir: str):
        self.run_dir = run_dir
        self.log_file = os.path.join(run_dir, "events.jsonl")
        self.sequence = 0

    def emit_event(self, event_type: str, stage: str, status: str, payload: dict[str, Any]):
        os.makedirs(self.run_dir, exist_ok=True)
        self.sequence += 1
        
        redacted_payload = redact_payload(payload)
        
        event = {
            "schema_version": "1.0",
            "sequence": self.sequence,
            "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
            "event_type": event_type,
            "stage": stage,
            "status": status,
            "payload": redacted_payload
        }
        
        with open(self.log_file, "a", encoding="utf-8") as f:
            f.write(json.dumps(event) + "\n")
