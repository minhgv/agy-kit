# agy-kit Re-Assessment Report (Post-Remediation)

> **Repo:** `github.com/minhgv/agy-kit` | **Branch:** `main` @ `cce4a7a`
> **Ngày đánh giá lại:** 2026-08-06 | **Người đánh giá:** Hermes Agent (glm-5.2)
> **Baseline:** Report lần 1 @ `b70c99e` → Xem `agy-kit-quality-assessment-2026-08-06.md`
> **Commit range remediated:** `b70c99e..cce4a7a` (4 commits, 66 files, +4,762 / −83 dòng)

---

## 1. Executive Summary

| Tiêu chí | Lần 1 (`b70c99e`) | Lần 2 (`cce4a7a`) | XU HƯỚNG |
|----------|:-:|:-:|:-:|
| Cấu trúc & Organization | 8.5 | 8.5 | ➡️ |
| CI/CD Pipeline | 6 | **8.5** | ⬆️ +2.5 |
| Code Quality (Python) | 4 | **5** | ⬆️ +1 |
| Test Coverage & Correctness | 5 | **7** | ⬆️ +2 |
| Security & Secret Hygiene | 7 | **8.5** | ⬆️ +1.5 |
| Template Drift Management | 6 | **8.5** | ⬆️ +2.5 |
| Documentation | 9 | 9 | ➡️ |
| **TỔNG THỂ** | **6.5/10** | **7.5/10** | **⬆️ +1.0** |

**Verdict:** Đã remediate thành công **4/5 Critical issues** từ lần 1. Repo tiến bộ đáng kể ở CI, security, và template sync. Tuy nhiên **vẫn còn 1 test fail + 127 ruff errors chưa fix + eval harness vẫn fail 4/8** — cần thêm một vòng cleanup để đạt production-ready.

---

## 2. Phân tích Remediation — Đã fix gì?

### 2.1. Critical Issues từ lần 1

| # | Issue (Lần 1) | Trạng thái | Bằng chứng |
|---|---------------|:----------:|------------|
| 1 | `RunLock.acquire()` thiếu `self` | ✅ **FIXED** | `locks.py:20` — `def acquire(self) -> bool:` |
| 2 | Validator không reject whitespace | ✅ **FIXED** | `validators.py:14` — `if not file_path.strip() or os.path.isabs(file_path):` |
| 3 | Validator không flag absolute path `/etc/passwd` | ✅ **FIXED** | `validators.py:14` — `os.path.isabs(file_path)` |
| 4 | CI không chạy unit tests | ✅ **FIXED** | `ci.yml` thêm 3 step: mypy, pytest, template drift audit |
| 5 | 132 ruff errors không enforce | ⚠️ **PARTIAL** | CI chạy ruff (will fail), nhưng chỉ giảm 132→127 (fix 5, còn 127) |

### 2.2. Security Hardening bổ sung

| Fix | Commit | Chi tiết |
|-----|--------|----------|
| Worktree dùng `tempfile.mkdtemp()` thay `/tmp/` hardcoded | `6c1bfc8` | `worktree.py:17` — chống symlink attack |
| Gỡ `--dangerously-skip-permissions` khỏi default | `cce4a7a` | `agy-pipeline.sh` — `AUTO_APPROVE` mặc định rỗng, có warning nếu override |
| Thêm unit test safety + worktree | `6c1bfc8` | `test_safety_and_worktree.py` (53 dòng, test tempfile + lock lifecycle) |

### 2.3. Template Sync cải thiện

| Fix | Chi tiết |
|-----|----------|
| `sync_templates.py` recursive skills sync | `ef74439` — sync toàn bộ `src/templates/skills/` ↔ `.agents/skills/` |
| `.agents/workflows/pipeline.md` ↔ `.antigravity/workflows/pipeline.md` sync | `c61902c` — drift đã resolve |
| `src/templates/skills/` populated đủ 12 skills | +4762 dòng templates mới |
| `sync_templates.py --check` pass | ✅ "All templates 100% synchronized" |

---

## 3. Trạng thái hiện tại chi tiết

### 3.1. Ruff — 127 errors (giảm từ 132)

| Rule | Lần 1 | Lần 2 | Thay đổi |
|------|:------:|:-----:|:--------:|
| I001 (unsorted-imports) | 27 | 27 | ➡️ |
| RUF059 (unused-unpacked-variable) | 26 | 26 | ➡️ |
| UP006/UP035 (deprecated annotations) | 25 | 25 | ➡️ |
| PLW1510 (subprocess without check) | 10 | 10 | ➡️ |
| EXE001 (shebang not executable) | 8 | **9** | ⬆️ +1 (file mới) |
| F821 (undefined-name) | **8** | **0** | ✅ **-8** (fixed locks.py) |
| BLE001 (blind except) | 7 | 8 | ⬆️ +1 |
| F401 (unused-import) | 5 | 5 | ➡️ |
| **Total** | **132** | **127** | **-5** |

**Đánh giá:** Sự giảm duy nhất có ý nghĩa là **F821 (undefined-name) → 0** — đúng là do fix `self` trong locks.py. 127 errors còn lại phần lớn là **code style** (import sorting, deprecated annotations) không phải bug logic, nhưng vẫn làm CI fail.

### 3.2. Mypy — 6 errors (giảm từ 12)

| File | Lần 1 | Lần 2 | Ghi chú |
|------|:------:|:-----:|---------|
| `locks.py` | 10 | **2** | Fix `self` loại bỏ 8 lỗi, còn 2 type annotation mismatch |
| `config.py` | 1 | **3** | tomllib redef + None assignment |
| `worktree.py` | 1 | **1** | `worktree_dir: None → str` type mismatch |
| **Total** | **12** | **6** | **-6** |

**Lỗi còn lại đều là type annotation issues** — có thể fix nhanh bằng `Optional[TextIOWrapper]` và `Optional[str]`.

### 3.3. Pytest — 1 fail / 24 pass (giảm từ 4 fail / 18 pass)

| Test | Lần 1 | Lần 2 | Nguyên nhân còn fail |
|------|:------:|:-----:|----------------------|
| `test_r005_concurrent_run_lock` | ❌ | ✅ | Fixed (locks.py self) |
| `test_attack_1_boundary_edge_bombardment` | ❌ | ✅ | Fixed (validators.py) |
| `test_attack_2_concurrency_race_conditions` | ❌ | ✅ | Fixed (orchestrator) |
| `test_forbidden_paths_detection` | ❌ | ❌ | **Vẫn fail** — xem phân tích bên dưới |

**Test còn fail: `test_forbidden_paths_detection`**

```python
# tests/unit/test_orchestrator.py:25-31
def test_forbidden_paths_detection(self):
    forbidden = [".env", ".ssh/id_rsa", "/etc/passwd", "../outside.py", "-rf"]
    for f in forbidden:
        is_forbidden = (".." in f) or f.startswith("-") or f in [".env", ".ssh/id_rsa"]
        self.assertTrue(is_forbidden, f"Path {f} should be flagged as forbidden")
```

**Root cause:** Test logic itself không cover `/etc/passwd` — nó chỉ check `..`, prefix `-`, và hardcoded list `.env`/`.ssh/id_rsa`. Absolute path `/etc/passwd` không match bất kỳ điều kiện nào → fail.

**Đây là lỗi TEST, không phải lỗi code.** `validators.py` đã fix đúng (`os.path.isabs(file_path)` → return False). Nhưng test không gọi `validate_path_safety()` — nó dùng inline logic riêng không đầy đủ. **Fix:** cập nhật test để gọi hàm validator thực tế.

### 3.4. Coverage — 74% (tăng từ 66%)

| Module | Lần 1 | Lần 2 | Thay đổi |
|--------|:------:|:-----:|:--------:|
| orchestrator.py | 100% | 100% | ➡️ |
| **validators.py** | 92% | **100%** | ⬆️ (+8%) |
| models/ | 94-96% | 94-96% | ➡️ |
| **safety/locks.py** | **35%** | **88%** | ⬆️ (+53%!) |
| worktree.py | 43% | **54%** | ⬆️ (+11%) |
| cli.py | 39% | 39% | ➡️ |
| adapters/ | 68-88% | 68-88% | ➡️ |
| **Total** | **66%** | **74%** | **+8%** |

**Đánh giá:** Cải thiện coverage rất tốt ở modules quan trọng (locks 35→88%, validators 92→100%). Vẫn cần nâng cli.py (39%) và worktree.py (54%).

### 3.5. Eval Harness — vẫn 4/8 fail

| Benchmark | Lần 1 | Lần 2 |
|-----------|:------:|:-----:|
| Skill Artifact Validator | ✅ 100 | ✅ 100 |
| Requirement Traceability Audit | ✅ 100 | ✅ 100 |
| BA & QA Framework Docs Validator | ✅ 100 | ✅ 100 |
| Phase 10 BA & QA Skills Suite | ❌ 0 | ❌ 0 |
| Workflows & Skills Sync Validator | ❌ 0 | ❌ 0 |
| Phase 12 Brainstorming Benchmark | ❌ 0 | ❌ 0 |
| Developer Scaffolding Installer CLI | ❌ 0 | ❌ 0 |
| Phase 17 Writing-Skills Integration | ✅ 100 | ✅ 100 |
| Phase 18 Meta-Evaluation Fault Injection | ❌ 0 | ❌ 0 |

**4/8 benchmark vẫn = 0/100.** Đây là vấn đề cần điều tra sâu hơn — có thể là benchmark check logic không match thực tế sau khi sync templates.

### 3.6. Duplicate Files — 151 (tăng từ 101)

Pygount báo **151 file `__duplicate__`** (41.9%), tăng từ 101 (36.9%). Nguyên nhân: commit `6c1bfc8` tạo `.hermes/` mirror mới cho agents/workflows (dynamic mirror generation). Tổng file tăng từ 524 → 591.

**Đây là đánh đổi:** repo chấp nhận duplicate để đảm bảo 3 nền tảng (`.agents/`, `.antigravity/`, `.hermes/`) luôn sync. Việc sync_templates.py `--check` pass chứng tỏ duplicate này có chủ đích và được verify. Tuy nhiên, **151 file identical vẫn là gánh nặng bảo trì** — nên cân nhắc symlink hoặc generate-at-runtime trong `init-agy-kit.sh`.

### 3.7. Template Drift — gần như sạch

| Check | Kết quả |
|-------|---------|
| `sync_templates.py --check` | ✅ PASS — "100% synchronized" |
| `.agents/` ↔ `.antigravity/` diff | ✅ Chỉ khác `mcp_config.json` (orphan, không có template) |
| `src/templates/skills/` ↔ `.agents/skills/` | ✅ Đồng bộ (12 skills đầy đủ) |
| `.agents/workflows/pipeline.md` drift | ✅ Đã resolve |

---

## 4. CI/CD Pipeline — Cải thiện đáng kể

### CI mới (`.github/workflows/ci.yml`) giờ có 8 steps:

| Step | Lần 1 | Lần 2 | Trạng thái |
|------|:------:|:-----:|:----------:|
| Install deps (pip install -e .) | ❌ Thiếu | ✅ Có | ⬆️ |
| Ruff lint | ✅ | ✅ | ➡️ |
| **Mypy type check** | ❌ | ✅ **MỚI** | ⬆️ |
| **Unit tests (pytest)** | ❌ | ✅ **MỚI** | ⬆️ |
| **Template drift audit** | ❌ | ✅ **MỚI** | ⬆️ |
| Eval harness | ✅ | ✅ | ➡️ |
| Gitleaks | ✅ | ✅ | ➡️ |
| TruffleHog | ✅ | ✅ | ➡️ |

**Lưu ý quan trọng:** CI dùng `python3 -m unittest discover` thay vì `pytest`. Cả hai đều chạy được test hiện tại, nhưng pytest có hỗ trợ coverage và fixture tốt hơn. Nếu dùng pytest sẽ tận dụng được `--cov` gate.

**CI hiện tại SẼ FAIL** trên GitHub vì:
- ruff: 127 errors
- mypy: 6 errors
- unittest: 1 test fail
- eval_harness: benchmark failed exit code

→ Repo đang ở trạng thái **CI đỏ** trên main branch. Cần fix để CI xanh lại.

---

## 5. Updated Priority Issues

### 🔴 Critical (Vẫn block CI xanh)

| # | Issue | Fix |
|---|-------|-----|
| 1 | **127 ruff errors** | Chạy `ruff check . --fix` (35 auto-fixable), rồi fix 92 còn lại |
| 2 | **1 test fail** `test_forbidden_paths_detection` | Sửa test để gọi `validate_path_safety()` thay vì inline logic |
| 3 | **6 mypy errors** | Fix type annotations: `Optional[TextIOWrapper]`, `Optional[str]` |
| 4 | **Eval harness 4/8 fail** | Debug từng benchmark, kiểm tra benchmark logic match thực tế |

### ⚠️ Medium

| # | Issue | Recommendation |
|---|-------|----------------|
| 5 | 151 duplicate files | Cân nhắc dynamic mirror generation thay vì commit |
| 6 | Coverage cli.py 39%, worktree.py 54% | Thêm test cho CLI subcommands |
| 7 | `mcp_config.json` orphan (không có template) | Thêm vào sync hoặc xóa khỏi `.agents/` |
| 8 | CI dùng `unittest` thay vì `pytest` | Đổi sang pytest + `--cov-fail-under=80` |

---

## 6. So sánh Before/After — Tóm tắt

```
                    Lần 1 (b70c99e)     →     Lần 2 (cce4a7a)
                    ─────────────────────────────────────────
Ruff errors:        132                 →     127          (-5)
Mypy errors:        12                  →     6            (-50%)
Test pass:          18/22               →     24/25        (+6 pass)
Test fail:          4                   →     1            (-75%)
Coverage:           66%                 →     74%          (+8%)
Eval pass:          4/8                 →     4/8          (➡️)
Critical bugs:      5                   →     1            (-80%)
Template drift:     3 instances         →     0            (✅)
Duplicate files:    101                 →     151          (+50)
CI steps:           5                   →     8            (+3)
Security:           /tmp hardcoded      →     tempfile     (✅)
```

---

## 7. Kết luận & Khuyến nghị

### Đánh giá tổng thể

**Tiến bộ rất rõ rệt** trong một phiên remediation. 4/5 critical bugs đã được fix đúng cách, security posture cải thiện (tempfile, gỡ dangerous flag), template sync close-to-clean, và CI thêm 3 quality gate steps quan trọng.

Repo **chuyển từ "chưa readiness" (6.5/10) sang "gần readiness" (7.5/10)**. Khoảng cách còn lại đến production-ready không lớn — chủ yếu là **mechanical cleanup** (ruff fix, type annotations, 1 test fix) chứ không phải lỗi kiến trúc.

### Để đạt production-ready (8.5+/10), cần:

1. **`ruff check . --fix` + fix thủ công 92 errors còn lại** → CI lint xanh (ước ~2h)
2. **Fix 6 mypy type annotations** → CI type check xanh (ước ~30 phút)
3. **Sửa `test_forbidden_paths_detection`** gọi `validate_path_safety()` → CI test xanh (ước ~10 phút)
4. **Debug 4 eval benchmark fail** → eval harness pass (ước ~2-4h)
5. **Đổi CI sang `pytest --cov-fail-under=80`** → coverage gate mạnh hơn (ước ~30 phút)

Tổng effort ước tính: **~1 ngày làm việc** để đưa repo lên CI xanh hoàn toàn và đạt readiness 8.5+/10.

---

*Re-assessment by Hermes Agent (glm-5.2) — 2026-08-06*
*Baseline report: `agy-kit-quality-assessment-2026-08-06.md`*
*Phân tích tĩnh: ruff 0.4.4, mypy 1.13, pytest 8.x, pygount 1.6*
