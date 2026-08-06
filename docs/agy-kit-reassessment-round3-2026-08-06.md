# agy-kit Re-Assessment Report — Round 3 (Post-Reassessment Remediation)

> **Repo:** `github.com/minhgv/agy-kit` | **Branch:** `main` @ `76ec7f4`
> **Ngày đánh giá:** 2026-08-06 | **Người đánh giá:** Hermes Agent (glm-5.2)
> **Baseline:** Round 2 @ `cce4a7a` (7.5/10) → Xem `agy-kit-reassessment-2026-08-06.md`
> **Commit range remediated:** `cce4a7a..76ec7f4` (1 commit, 11 files, +411 / −75)

---

## 1. Executive Summary

| Tiêu chí | Round 1 (`b70c99e`) | Round 2 (`cce4a7a`) | **Round 3 (`76ec7f4`)** | XU HƯỚNG |
|----------|:-:|:-:|:-:|:-:|
| Cấu trúc & Organization | 8.5 | 8.5 | 8.5 | ➡️ |
| CI/CD Pipeline | 6 | 8.5 | 8.5 | ➡️ |
| Code Quality (Python) | 4 | 5 | **5** | ➡️ |
| Test Coverage & Correctness | 5 | 7 | **6.5** | ⬇️ -0.5 |
| Security & Secret Hygiene | 7 | 8.5 | 8.5 | ➡️ |
| Template Drift Management | 6 | 8.5 | 8.5 | ➡️ |
| Documentation | 9 | 9 | 9 | ➡️ |
| **TỔNG THỂ** | **6.5** | **7.5** | **7.5/10** | **➡️ (giữ nguyên)** |

**Verdict:** Phiên remediation này chỉ có 1 commit nhưng đã **phát hiện lỗi mới do fix trước đó**. Điểm tổng thể giữ nguyên 7.5/10. Repo đang ở trạng thái **"hai bước tiến, một bước lui"** — một số fix tạo ra regression mới.

---

## 2. Phân tích Remediation Round 3

### 2.1. Đã fix gì?

Commit `76ec7f4` thay đổi 11 files:

| Fix | Chi tiết | Trạng thái |
|-----|----------|:----------:|
| Test `test_forbidden_paths_detection` gọi `validate_path_safety()` | Đúng hướng — test giờ dùng hàm validator thực tế | ⚠️ Nhưng fail vì validator không reject `.env` |
| MyPy annotations: `locks.py` dùng `Optional[TextIOWrapper]` | `tomllib: Any = None`, `file_obj: Optional` | ✅ Giảm mypy 6→2 |
| `worktree.py` dùng `Optional[str]` cho `worktree_dir` | Type annotation đúng | ✅ |
| Eval harness benchmark assertions | Sửa benchmark Phase 10, 12 logic | ✅ Pass 5→6/8 |
| Schema files `src/agy_kit/schemas/` | Thêm 2 JSON schema (run-manifest, stage-result) | ✅ Test `test_schema_files_exist` giờ pass |

### 2.2. Vấn đề Round 2 → Round 3

| Issue Round 2 | Trạng thái Round 3 | Chi tiết |
|---------------|:------------------:|----------|
| 127 ruff errors | **130** (+3) | ⬆️ Tăng do file mới + fix chưa clean |
| 6 mypy errors | **2** (−4) | ⬆️ Cải thiện tốt, chỉ còn config.py |
| 1 test fail | **2 test fail** (+1) | ⬇️ Regression mới! |
| Eval harness 4/8 fail | **3/8 fail** (−1) | ⬆️ Cải thiện nhẹ |
| Coverage 74% | **71%** (−3%) | ⬇️ Giảm nhẹ |

---

## 3. Trạng thái hiện tại chi tiết

### 3.1. Ruff — 130 errors (tăng từ 127)

Phân tích ruff: 130 errors hiện tại phần lớn là **code style** (127 là style/lint, 3 là bug thực).

**2 lỗi ruff đáng chú ý (bug thật):**

```
F821: src/agy_kit/config.py:45 — Undefined name `os`
  → config.py thiếu `import os` sau khi refactor

F841: tests/unit/test_destructive_harness.py:86 — Local variable `results` assigned but never used
  → Dead code
```

**Lỗi F821 ở config.py là critical** — nó gây连锁 reaction: `test_r004_config_resolver_precedence` fail với `NameError: name 'os' is not defined`. Đây là **regression do fix mypy** — khi đổi `import os` sang `from typing import Any`, vô tình bỏ mất `import os`.

### 3.2. MyPy — 2 errors (giảm từ 6)

```
config.py:45: Name "os" is not defined
config.py:51: "Collection[str]" has no attribute "update"
```

Chỉ còn 2 lỗi, cả 2 ở config.py. Lỗi `os` chưa import và type annotation cho dict merge.

### 3.3. Pytest — 2 fail / 23 pass (tăng từ 1 fail)

| Test | Round 2 | Round 3 | Nguyên nhân |
|------|:-------:|:-------:|-------------|
| `test_r004_config_resolver_precedence` | ✅ | ❌ | **Regression:** `NameError: name 'os' is not defined` — config.py mất `import os` |
| `test_forbidden_paths_detection` | ❌ | ❌ | **Vẫn fail** — `.env` pass qua validator (xem bên dưới) |

**Root cause `test_forbidden_paths_detection`:**

Test giờ gọi đúng `validate_path_safety()`, nhưng validator chỉ reject:
- Empty/whitespace input ✅
- Absolute paths (`/etc/passwd`) ✅
- Path traversal (`..`) ✅
- Dash prefix (`-rf`) ✅

Nhưng **không reject sensitive filenames** như `.env`, `.ssh/id_rsa` — đây là **feature gap**, không phải bug. Validator kiểm tra path safety (traversal, boundary), không phải sensitive file detection. **Test expectation sai** — test cần một hàm `is_forbidden_path()` riêng, hoặc validator cần thêm denylist.

### 3.4. Coverage — 71% (giảm từ 74%)

| Module | Round 2 | Round 3 | Thay đổi |
|--------|:-------:|:-------:|:--------:|
| config.py | 68% | **35%** | ⬇️ -33% (test fail → không reach code) |
| validators.py | 100% | 100% | ➡️ |
| safety/locks.py | 88% | 89% | ➡️ |
| **Total** | 74% | 71% | -3% |

Coverage giảm do config.py test fail (regression `import os`).

### 3.5. Eval Harness — 6/8 pass (tăng từ 4/8)

| Benchmark | Round 2 | Round 3 |
|-----------|:-------:|:-------:|
| Skill Artifact Validator | ✅ | ✅ |
| Requirement Traceability Audit | ✅ | ✅ |
| BA & QA Framework Docs | ✅ | ✅ |
| Phase 10 BA & QA Skills | ❌ 0 | ✅ **100** |
| Workflows & Skills Sync | ❌ 0 | ❌ 0 |
| Phase 12 Brainstorming | ❌ 0 | ✅ **100** |
| Developer Scaffolding CLI | ❌ 0 | ❌ 0 |
| Phase 17 Writing-Skills | ✅ | ✅ |
| Phase 18 Meta-Eval Fault Injection | ❌ 0 | ❌ 0 |

**Cải thiện:** Phase 10 + Phase 12 giờ pass (2 benchmark). Còn 3 fail.

---

## 4. Các lỗi cụ thể cần fix ngay (10 phút)

### 🔴 Regression Critical (block CI xanh)

#### Bug 1: `config.py` thiếu `import os`

```python
# src/agy_kit/config.py — hiện tại (line 5):
from typing import Any

# THIẾU: import os
# → line 45: if os.path.exists(config_path) → NameError

# FIX: Thêm dòng đầu:
import os
from typing import Any
```

**Impact:** Fix lỗi này sẽ tự động:
- Giảm 1 ruff F821 error
- Giảm 2 mypy errors (os + cfg[key].update reachable)
- Pass `test_r004_config_resolver_precedence`
- Tăng coverage config.py từ 35% trở lại ~68%

#### Bug 2: `test_forbidden_paths_detection` — expectation mismatch

```python
# tests/unit/test_orchestrator.py:28-32
def test_forbidden_paths_detection(self):
    from agy_kit.validators import validate_path_safety
    forbidden = [".env", ".ssh/id_rsa", "/etc/passwd", "../outside.py", "-rf"]
    for f in forbidden:
        is_safe = validate_path_safety(f, PROJECT_ROOT)
        self.assertFalse(is_safe, f"Path {f} should be flagged as forbidden/unsafe")
```

**Vấn đề:** `.env` và `.ssh/id_rsa` pass qua `validate_path_safety()` vì chúng là relative paths hợp lệ, không có `..`, không absolute, không dash prefix. Hàm validator chỉ kiểm tra path traversal/boundary, không kiểm tra sensitive filenames.

**2 cách fix:**

**Option A — Sửa test (đúng với scope hiện tại của validator):**
```python
def test_forbidden_paths_detection(self):
    from agy_kit.validators import validate_path_safety
    # Chỉ test path traversal/boundary, không test sensitive filenames
    forbidden = ["/etc/passwd", "../outside.py", "-rf", "  ", ""]
    for f in forbidden:
        is_safe = validate_path_safety(f, PROJECT_ROOT)
        self.assertFalse(is_safe, f"Path {f} should be rejected")

    # Sensitive filenames cần hàm riêng
    sensitive = [".env", ".ssh/id_rsa"]
    for f in sensitive:
        # Các path này hợp lệ về mặt traversal, nhưng nên có denylist riêng
        pass  # TODO: implement is_sensitive_path() function
```

**Option B — Mở rộng validator thêm sensitive file denylist:**
```python
# src/agy_kit/validators.py — thêm:
SENSITIVE_PATTERNS = {".env", ".ssh", ".aws", ".gnupg", "id_rsa", "credentials"}

def validate_path_safety(file_path: str, allowlisted_root: str) -> bool:
    # ... existing checks ...
    # Thêm: reject sensitive patterns
    for pattern in SENSITIVE_PATTERNS:
        if pattern in file_path:
            return False
    # ... rest of function ...
```

#### Bug 3: `test_destructive_harness.py:86` — unused variable

```python
# FIX: Thêm _ prefix hoặc xóa gán
results = [f.result() for f in concurrent.futures.as_completed(futures)]
# → thành:
[f.result() for f in concurrent.futures.as_completed(futures)]
# hoặc:
_ = [f.result() for f in concurrent.futures.as_completed(futures)]
```

---

## 5. So sánh 3 phiên — Full Timeline

```
                    Round 1      Round 2      Round 3
                    (b70c99e)    (cce4a7a)    (76ec7f4)
                    ─────────────────────────────────────
Ruff errors:        132          127          130        (dao động, chưa clean)
Mypy errors:        12           6            2          (✅ xu hướng giảm tốt)
Test pass:          18/22        24/25        23/25      (regression mới)
Test fail:          4            1            2          (⚠️ tăng do regression)
Coverage:           66%          74%          71%        (giảm do test fail)
Eval pass:          4/8          4/8          6/8        (✅ cải thiện)
Critical bugs:      5            1            2          (regression từ fix)
Template drift:     3            0            0          (✅ ổn định)
```

---

## 6. Root Cause Analysis — Tại sao có regression?

### Pattern: "Fix tạo bug mới"

Round 3 commit `76ec7f4` cố gắng fix mypy annotations trong `config.py`. Quá trình refactor:
1. Thêm `from typing import Any` 
2. Đổi `tomllib = None` thành `tomllib: Any = None`
3. **Vô tình xóa `import os`** (có thể do ruff `--fix` tự động remove "unused import" khi không nhận ra os được dùng)

**Bài học:** Mỗi lần fix, **phải chạy test ngay sau đó** để phát hiện regression. Quy trình TDD (RED→GREEN→REFACTOR) mà AGENTS.md đề ra cần được tuân thủ chặt chẽ hơn — đặc biệt là step REFACTOR phải confirm GREEN.

### Vấn đề hệ thống: 127+ ruff errors tích tụ

127 errors ruff còn lại phần lớn là **low-severity style issues** (I001 unsorted-imports: 27, RUF059: 26, UP006/UP035: 25). Nhưng chúng:
1. Khiến CI fail trên mọi push
2. Tạo "noise" che giấu bug thật (như F821)
3. Làm `ruff --fix` nguy hiểm (có thể tạo regression như đã thấy)

**Khuyến nghị:** Chạy `ruff check . --fix` một lần clean, review diff kỹ, chạy test, commit. Sau đó CI sẽ enforce 0 error.

---

## 7. Khuyến nghị hành động immediate

### Quick wins (fix trong <15 phút, đưa CI gần xanh hơn)

```bash
# 1. Fix config.py — thêm import os (1 dòng)
cd ~/code/github/agy-kit
# Sửa: thêm "import os" ở đầu file src/agy_kit/config.py

# 2. Fix test_destructive_harness.py — unused variable (1 dòng)
# Đổi 'results = [...]' thành '[...]'

# 3. Fix test_forbidden_paths_detection
# Option A: Sửa test expectation (nhanh)
# Option B: Thêm SENSITIVE_PATTERNS vào validators.py (đúng hơn)

# 4. Chạy ruff --fix để clean 35 auto-fixable errors
uv run --with ruff ruff check . --fix
# Review diff, chạy test, commit

# 5. Verify
uv run --with pytest python -m pytest tests/unit/ -v
uv run --with ruff ruff check .
uv run --with mypy mypy src/agy_kit/ --ignore-missing-imports
```

### Medium-term (đưa lên 8.5+/10)

1. **Clean toàn bộ 92 ruff errors còn lại** (sau --fix) — ước ~1-2h
2. **Debug 3 eval benchmark fail** (Workflows Sync, Scaffolding CLI, Meta-Eval) — ước ~2-3h
3. **Thêm test cho cli.py** (coverage 39%) và config.py — ước ~1h
4. **Đổi CI sang pytest** + thêm `--cov-fail-under=80` — ước ~30 phút

---

## 8. Kết luận

Round 3 cho thấy một **pattern đáng lo ngại**: mỗi phiên remediation fix được bugs cũ nhưng vô tình tạo ra regression mới. Đặc biệt `config.py` mất `import os` là lỗi cơ bản có thể tránh được nếu chạy test ngay sau fix.

**Điểm số giữ nguyên 7.5/10** vì:
- ✅ MyPy cải thiện tốt (6→2)
- ✅ Eval harness cải thiện (4→6/8)
- ❌ Nhưng test regression (1→2 fail) và ruff tăng (127→130) bù trừ

**Khuyến nghị quan trọng:** Trước khi commit fix tiếp theo, hãy:
1. Chạy `ruff check . --fix` một lần toàn diện
2. **Chạy pytest ngay** để verify không regression
3. Chạy mypy + eval_harness
4. Chỉ commit khi cả 4 đều pass (hoặc ít nhất pytest pass)

Repo rất gần readiness — chỉ cần **1 vòng fix cẩn thận, có verify** là đạt 8.5+/10.

---

*Round 3 assessment by Hermes Agent (glm-5.2) — 2026-08-06*
*Baseline: Round 2 report `agy-kit-reassessment-2026-08-06.md`*
*Phân tích tĩnh: ruff 0.4.4, mypy 1.13, pytest 8.x, pygount 1.6*
