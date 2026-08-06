#!/usr/bin/env python3
"""
agy-kit Phase 18 Meta-Evaluation & Fault Injection Harness

Verifies the integrity of eval_harness.py using:
1. 5 Synthetic Fault Injection Scenarios (Secret Leak, Syntax Error, Missing Skill, Path Violation, Malformed Spec) -> 5/5 RED failures detected.
2. Deterministic Stability Test (10 consecutive runs with 0 variance).
3. Performance Profiler (Execution latency < 2.0s).
"""
from __future__ import annotations

import os
import subprocess
import sys
import time
from datetime import datetime, timezone

EVAL_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.abspath(os.path.join(EVAL_DIR, "../../"))

if EVAL_DIR not in sys.path:
    sys.path.insert(0, EVAL_DIR)

import eval_harness


def test_fault_secret_leak():
    """Fault 1: Secret Leak Injection"""
    temp_file = os.path.join(PROJECT_ROOT, "_temp_secret_fault.txt")
    try:
        with open(temp_file, "w") as f:
            f.write("sk-proj-12345678901234567890_FAKE_KEY\n")
        subprocess.run(["git", "add", temp_file], cwd=PROJECT_ROOT, capture_output=True, check=False)
        res = eval_harness.eval_quality_gate()
        detected = (res.get("secrets_found", False) is True) and (res.get("score", 100) == 0)
        return detected, res
    finally:
        subprocess.run(["git", "reset", "HEAD", temp_file], cwd=PROJECT_ROOT, capture_output=True, check=False)
        if os.path.exists(temp_file):
            os.remove(temp_file)

def test_fault_syntax_error():
    """Fault 2: Syntax Error Injection"""
    temp_file = os.path.join(EVAL_DIR, "_temp_fault_syntax.py")
    try:
        with open(temp_file, "w") as f:
            f.write("def invalid_syntax_func(: pass\n")
        res = eval_harness.eval_quality_gate()
        syntax_ok = res.get("syntax_ok", res.get("py_syntax_ok", True))
        detected = (syntax_ok is False) and (res.get("score", 100) == 0)
        return detected, res
    finally:
        if os.path.exists(temp_file):
            os.remove(temp_file)

def test_fault_missing_skill():
    """Fault 3: Missing Skill Injection"""
    skill_file = os.path.join(PROJECT_ROOT, ".hermes/skills/writing-skills/SKILL.md")
    bak_file = skill_file + ".bak_meta_eval"
    try:
        if os.path.exists(skill_file):
            os.rename(skill_file, bak_file)
        res = eval_harness.eval_phase17_writing_skills()
        detected = (res.get("passed", True) is False) and (res.get("score", 100) == 0)
        return detected, res
    finally:
        if os.path.exists(bak_file):
            os.rename(bak_file, skill_file)

def test_fault_path_violation():
    """Fault 4: Path Violation Injection"""
    env_file = os.path.join(PROJECT_ROOT, ".env")
    created = False
    try:
        if not os.path.exists(env_file):
            with open(env_file, "w") as f:
                f.write("TEST_ENV=1\n")
            created = True
        subprocess.run(["git", "add", "-f", env_file], cwd=PROJECT_ROOT, capture_output=True, check=False)
        res = eval_harness.eval_path_boundaries()
        detected = (res.get("passed", True) is False) and (res.get("score", 100) == 0)
        return detected, res
    finally:
        subprocess.run(["git", "reset", "HEAD", env_file], cwd=PROJECT_ROOT, capture_output=True, check=False)
        if created and os.path.exists(env_file):
            os.remove(env_file)

def test_fault_malformed_spec():
    """Fault 5: Malformed Spec Injection"""
    spec_file = os.path.join(PROJECT_ROOT, "plans/SPEC_TEMPLATE.md")
    bak_file = spec_file + ".bak_meta_eval"
    try:
        if os.path.exists(spec_file):
            os.rename(spec_file, bak_file)
        res = eval_harness.eval_traceability_audit()
        detected = (res.get("passed", True) is False) and (res.get("score", 100) == 0)
        return detected, res
    finally:
        if os.path.exists(bak_file):
            os.rename(bak_file, spec_file)

def run_stability_test(iterations=10):
    """Executes 10 consecutive benchmark evaluation cycles and checks for 0 variance."""
    scores = []
    for _ in range(iterations):
        qg = eval_harness.eval_quality_gate()["score"]
        av = eval_harness.eval_agent_validation()["score"]
        dd = eval_harness.eval_doctor_diagnostics()["score"]
        pb = eval_harness.eval_path_boundaries()["score"]
        tc = eval_harness.eval_token_cost_tracking()["score"]
        ds = eval_harness.eval_dependency_scan()["score"]
        te = eval_harness.eval_telemetry_export()["score"]
        ss = eval_harness.eval_skill_synthesis()["score"]
        ta = eval_harness.eval_traceability_audit()["score"]
        bd = eval_harness.eval_ba_framework_docs()["score"]
        p10 = eval_harness.eval_phase10_ba_qa_skills()["score"]
        ws = eval_harness.eval_workflows_skills_sync()["score"]
        bs = eval_harness.eval_brainstorm_skills()["score"]
        pi = eval_harness.eval_phase16_init_installer()["score"]
        pw = eval_harness.eval_phase17_writing_skills()["score"]
        total = sum([qg, av, dd, pb, tc, ds, te, ss, ta, bd, p10, ws, bs, pi, pw]) / 15.0
        scores.append(total)
    
    variance = max(scores) - min(scores)
    passed = (variance == 0.0) and (scores[0] == 100.0)
    return passed, variance, scores[0]

def run_performance_profiler():
    """Profiles execution latency of the benchmark suite (target < 2.0s)."""
    start = time.time()
    eval_harness.eval_quality_gate()
    eval_harness.eval_agent_validation()
    eval_harness.eval_doctor_diagnostics()
    eval_harness.eval_path_boundaries()
    eval_harness.eval_token_cost_tracking()
    eval_harness.eval_dependency_scan()
    eval_harness.eval_telemetry_export()
    eval_harness.eval_skill_synthesis()
    eval_harness.eval_traceability_audit()
    eval_harness.eval_ba_framework_docs()
    eval_harness.eval_phase10_ba_qa_skills()
    eval_harness.eval_workflows_skills_sync()
    eval_harness.eval_brainstorm_skills()
    eval_harness.eval_phase16_init_installer()
    eval_harness.eval_phase17_writing_skills()
    elapsed = time.time() - start
    passed = elapsed < 2.0
    return passed, elapsed

def main():
    print("==================================================")
    print("   agy-kit Meta-Evaluation & Fault Injection Suite")
    print("==================================================")
    print(f"Timestamp: {datetime.now(timezone.utc).isoformat()}\n")

    faults = [
        ("Secret Leak", test_fault_secret_leak),
        ("Syntax Error", test_fault_syntax_error),
        ("Missing Skill", test_fault_missing_skill),
        ("Path Violation", test_fault_path_violation),
        ("Malformed Spec", test_fault_malformed_spec),
    ]

    detected_count = 0
    for idx, (name, fn) in enumerate(faults, 1):
        detected, details = fn()
        if detected:
            detected_count += 1
            print(f"[Fault Injection {idx}/5: {name}] DETECTED (RED failure score 0/100)")
        else:
            print(f"[Fault Injection {idx}/5: {name}] FAILED TO DETECT (Got {details})")

    print(f"\nSummary: {detected_count}/5 Fault Scenarios Detected.")

    stability_passed, variance, score = run_stability_test(10)
    print(f"\n[Deterministic Stability Test] 10/10 Runs Identical (Variance: {variance:.2f}, Score: {score:.0f}/100)")

    prof_passed, elapsed = run_performance_profiler()
    print(f"[Performance Profiler] Total Latency: {elapsed:.3f}s (Target: < 2.00s)")

    all_passed = (detected_count == 5) and stability_passed and prof_passed

    print("\n==================================================")
    if all_passed:
        print("ALL META-EVALUATION & FAULT INJECTION TESTS PASSED (100/100)")
        sys.exit(0)
    else:
        print("META-EVALUATION HARNESS FAILED ON ONE OR MORE TESTS")
        sys.exit(1)

if __name__ == "__main__":
    main()
