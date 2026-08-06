"""
config.py — TOML configuration resolver for agy-kit
"""

import os
from typing import Any, cast

tomllib: Any = None
try:
    import tomllib  # type: ignore
except ImportError:
    try:
        import tomli as tomllib  # type: ignore
    except ImportError:
        tomllib = None

DEFAULT_CONFIG = {
    "schema_version": "1.0",
    "agy": {
        "executable": "agy",
        "require_agent_discovery": True,
        "require_skill_discovery": True
    },
    "pipeline": {
        "stages": ["plan", "build", "gate", "qa", "review"],
        "max_retries": 1,
        "stage_timeout_seconds": 1800
    },
    "execution": {
        "permission_mode": "sandbox",
        "apply_policy": "never"
    },
    "mutation": {
        "enforce_manifest": True,
        "reject_symlinks": True
    },
    "security": {
        "secret_scan": "required",
        "redact_logs": True
    }
}

def load_config(config_path: str) -> dict:
    """Loads and resolves .agy-kit.toml configuration with fallback defaults."""
    cfg = dict(DEFAULT_CONFIG)
    if os.path.exists(config_path) and tomllib:
        try:
            with open(config_path, "rb") as f:
                file_cfg = tomllib.load(f)
                for key, val in file_cfg.items():
                    if isinstance(val, dict) and key in cfg and isinstance(cfg[key], dict):
                        cast(dict, cfg[key]).update(val)
                    else:
                        cfg[key] = val
        except Exception:  # noqa: BLE001, S110
            pass
    return cfg
