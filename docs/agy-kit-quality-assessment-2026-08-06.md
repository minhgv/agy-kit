# agy-kit Repository Quality Assessment Report

> **Repo:** `github.com/minhgv/agy-kit` | **Branch:** `main` @ `b70c99e`
> **Ngày đánh giá:** 2026-08-06 | **Người đánh giá:** Hermes Agent (glm-5.2)
> **Tiêu chí:** Đảm bảo chất lượng code khi dùng repo làm harness scaffold cho Antigravity CLI
> **Phương pháp:** Phân tích tĩnh (ruff, mypy, pytest, pygount) + đánh giá cấu trúc/security/CI

---

## 1. Executive Summary

| Tiêu chí | Điểm | Trạng thái |
|----------|------|------------|
| Cấu trúc & Organization | 8.5/10 | ✅ Mạnh |
| CI/CD Pipeline | 6/10 | ⚠️ Có lỗ hổng |
| Code Quality (Python) | 4/10 | ❌ Nghiêm trọng |
| Test Coverage & Correctness | 5/10 | ❌ Test fail |
| Security & Secret Hygiene | 7/10 | ⚠️ Cần cải thiện |
| Template Drift Management | 6/10 | ⚠️ Có drift |
| Documentation | 9/10 | ✅ Xuất sắc |
| **Tổng thể** | **6.5/10** | **⚠️ Chưa production-ready** |

**Verdict:** Repo có thiết kế kiến trúc scaffold tốt và documentation cực kỳ chi tiết, nhưng **code Python thực tế có lỗi type nghiêm trọng, test bị fail, và CI không chạy test**. Chưa an toàn để dùng làm harness scaffold đảm bảo chất lượng cho coding workflow.

---

## 2. Thống kê Code (pygount)

| Language | Files | Code LOC | Comment LOC |
|----------|-------|----------|-------------|
| Python | 27 | 1,400 | 237 |
| Bash | 20 | 1,068 | 112 |
| JSON | 17 | 326 | 0 |
| Markdown | 89 | 0 (doc) | 4,996 |
| Makefile | 1 | 65 | 45 |
| **Total (code)** | ~70 | **~2,900 LOC** | — |

**Vấn đề nghiêm trọng:** **101 file trùng lặp (`__duplicate__`)** — chiếm 36.9% tổng file. Đây là do repo lưu cùng nội dung ở 3 thư mục `.agents/`, `.antigravity/`, `.hermes/` (triplet mirroring). Dù có design rationale, việc commit 101 file identical vào git là **anti-pattern** gây phình repo và nguy cơ drift.

---

## 3. Đánh giá chi tiết theo tiêu chí Harness Scaffold

### 3.1. Cấu trúc & Organization — 8.5/10 ✅

**Điểm mạnh:**
- Hybrid `src/` layout chuẩn Python (PEP 517): `src/agy_kit/` cho package logic, `src/templates/` cho scaffold assets
- Tách bạch rõ: agents, skills, workflows, adapters, validators, orchestrator
- Multi-language adapters cho 5 ngôn ngữ (Python, TS, Go, Rust, PHP)
- Cấu trúc Phase-based phát triển rõ ràng (Phase 1-21), có plans/ SPEC cho mỗi phase

**Điểm yếu:**
- Triplet mirroring (`.agents/` + `.antigravity/` + `.hermes/`) tạo ra 101 file duplicate
- `src/templates/` không sync hoàn toàn với `.agents/` (skills không được template hóa)
- File `task.md` và `tests/evals/__pycache__/` bị commit vào repo (nên trong .gitignore)

### 3.2. CI/CD Pipeline — 6/10 ⚠️

**File:** `.github/workflows/ci.yml`

**Điểm mạnh:**
- Chạy trên cả push và PR
- Có 3 lớp security scan: ruff lint, gitleaks, trufflehog (verified)
- Chạy eval_harness.py benchmark

**Lỗ hổng nghiêm trọng:**
1. **❌ KHÔNG CHẬY UNIT TESTS** — CI chỉ chạy `ruff check` và `eval_harness.py`, bỏ qua hoàn toàn `pytest tests/unit/`. Test suite đang **4 test fail** mà CI vẫn pass!
2. **❌ KHÔNG CHẠY MYPY** — pyproject.toml không cấu hình mypy, CI không chạy type check
3. **❌ KHÔNG CHẠY PRE-COMMIT** — `.pre-commit-config.yaml` tồn tại nhưng CI không activate `pre-commit run --all-files`
4. **❌ RUFF CÓ 132 ERRORS** mà CI "Lint & Format Check" step somehow pass (hoặc fail mà không block)
5. Không có matrix testing cho multiple Python versions (chỉ test 3.12, nhưng pyproject.toml khai báo `requires-python >= 3.9`)

### 3.3. Code Quality (Python) — 4/10 ❌

#### Ruff: 132 errors

| Rule | Count | Severity |
|------|-------|----------|
| I001 (unsorted-imports) | 27 | Low |
| RUF059 (unused-unpacked-variable) | 26 | Medium |
| UP006/UP035 (deprecated type annotations) | 25 | Medium |
| PLW1510 (subprocess without check) | 10 | **High** |
| **F821 (undefined-name)** | **8** | **🔴 Critical** |
| EXE001 (shebang not executable) | 8 | Low |
| BLE001 (blind except) | 7 | Medium |
| F401 (unused-import) | 5 | Low |

#### Mypy: 12 errors trong 3 files

**🔴 `src/agy_kit/safety/locks.py:20` — LỖI NGHIÊM TRỌNG:**
```python
def acquire() -> bool:  # ❌ THIẾU `self`!
    os.makedirs(self.lock_dir, ...)  # Name "self" is not defined
```
Phương thức `acquire()` thiếu tham số `self`, dẫn đến 8 lỗi mypy liên quan. **Đây là lỗi runtime thực tế** — gọi `lock.acquire()` sẽ raise `TypeError`.

**`config.py:13` — Type redefinition:**
```python
tomllib = None  # ❌ Mismatch: declared as Module, assigned None
```

**`worktree.py:20` — Type mismatch:**
```python
self.worktree_dir = None  # ❌ Declared as None, later assigned str
```

#### Đánh giá code patterns:
- `cli.py` dùng lazy imports bên trong functions (acceptable cho CLI, nhưng không best practice)
- `validators.py` hàm `validate_path_safety` **không reject whitespace-only input** (test `test_attack_1` fail)
- `orchestrator.py` state machine sạch, nhưng `VALID_TRANSITIONS` matrix có lỗi: `CREATED → BUILT` bị từ chối dù có thể là path hợp lệ trong một số scenario

### 3.4. Test Coverage & Correctness — 5/10 ❌

**Kết quả pytest:** `4 failed, 18 passed`

| Test fail | Nguyên nhân | Severity |
|-----------|-------------|----------|
| `test_r005_concurrent_run_lock` | `RunLock.acquire()` thiếu `self` → `TypeError` | 🔴 Bug code |
| `test_attack_1_boundary_edge_bombardment` | Validator không reject input whitespace `'   '` | 🔴 Security |
| `test_attack_2_concurrency_race_conditions` | Orchestrator transition matrix sai | ⚠️ Logic |
| `test_forbidden_paths_detection` | Validator không flag `/etc/passwd` | 🔴 Security |

**Coverage:**
| Module | Coverage |
|--------|----------|
| orchestrator.py | 100% |
| validators.py | 92% |
| models/ | 94-96% |
| cli.py | 39% |
| **safety/locks.py** | **35%** |
| worktree.py | 43% |
| **Total** | **66%** |

**Đánh giá:**
- Core modules (orchestrator, validators, models) có coverage tốt (90%+)
- Nhưng module safety/locks — module security quan trọng nhất — chỉ 35% coverage và **đang fail**
- Không có integration tests, không có E2E tests thực tế
- Eval harness (`eval_harness.py`) **cũng fail** (4/8 benchmarks = 0/100)

### 3.5. Security & Secret Hygiene — 7/10 ⚠️

**Điểm mạnh:**
- `.gitleaks.toml` custom rules cho API key, JWT, private key
- CI chạy cả gitleaks + trufflehog (double scan)
- Git hooks enforce conventional commits + secret scan
- `.gitignore` đúng đắn (exclude .env, .pem, .key)
- AGENTS.md quy tắc rõ: "NEVER hardcode secrets"
- Không phát hiện secret hardcoded trong code (git grep sạch)

**Điểm yếu:**
- Path validator (`validators.py`) có **lỗ hổng bảo mật thực tế**:
  - Không reject whitespace-only input → có thể bypass
  - Không flag `/etc/passwd` (absolute path) → test fail
- `worktree.py` sử dụng `/tmp/` hardcoded cho worktree — nguy cơ symlink attack
- `cli.py:15` dùng `os.path.abspath` + `os.path.dirname(__file__)` để locate scripts — có thể bị path manipulation nếu package install ở location bất thường

### 3.6. Template Drift Management — 6/10 ⚠️

**Điểm mạnh:**
- Có `bin/sync_templates.py` và Makefile target `sync-templates`
- Có `--check` mode để CI detect drift

**Drift phát hiện:**
1. **`.agents/workflows/pipeline.md` ≠ `.antigravity/workflows/pipeline.md`** — nội dung khác nhau (Shift-Left Destructive TDD vs TDD thông thường)
2. **`.agents/version.json` ≠ `src/templates/version.json.tpl`** — version drift
3. **`.agents/mcp_config.json` không có template tương ứng** — file orphan
4. **Skills directory không sync** vào `src/templates/` — sync_templates chỉ cover agents/workflows, bỏ qua skills

**Đánh giá:** Sync mechanism tồn tại nhưng không cover toàn bộ assets và đã có drift thực tế.

### 3.7. Bash Script Quality — 7/10 ✅

- **15/15 script pass `bash -n` syntax check**
- Tất cả có header documentation rõ ràng
- Sử dụng `set -euo pipefail` (qua pre-commit hooks, không phải trong script trực tiếp)
- **Nhưng:** không có `set -euo pipefail` trong phần lớn script trực tiếp — dựa vào caller
- Không chạy được shellcheck (not installed) để đánh giá sâu hơn

### 3.8. Documentation — 9/10 ✅

**Điểm mạnh:**
- README.md chi tiết (210 dòng), có badges, architecture diagram, workflow table
- 22 file docs/ covering mọi khía cạnh (PRD, quality framework, rollback, OWASP, model routing...)
- AGENTS.md rules rõ ràng (10 sections)
- CONTRIBUTING.md, CHANGELOG.md, LICENSE đầy đủ
- Mỗi skill có SKILL.md + references chi tiết
- 5 examples cho 5 ngôn ngữ khác nhau

**Điểm yếu:**
- Nội dung README/docs bằng tiếng Việt ở nhiều chỗ (vi phạm quy ước "repo chia sẻ công khai PHẢI viết tiếng Anh")
- Docs cho phase cũ (Phase 1-17) vẫn còn, chưa có archive/cleanup

---

## 4. Top Priority Issues (Cần fix trước khi dùng production)

### 🔴 Critical (Block)

| # | Issue | File | Fix |
|---|-------|------|-----|
| 1 | `RunLock.acquire()` thiếu `self` | `src/agy_kit/safety/locks.py:20` | Thêm `self` vào signature |
| 2 | Path validator không reject whitespace | `src/agy_kit/validators.py:7-22` | Thêm `.strip()` check |
| 3 | Path validator không flag absolute path `/etc/passwd` | `src/agy_kit/validators.py` | Thêm `os.path.isabs()` check |
| 4 | CI không chạy `pytest tests/unit/` | `.github/workflows/ci.yml` | Thêm step pytest |
| 5 | 132 ruff errors, CI không enforce | `.github/workflows/ci.yml` | Thêm `ruff check --exit-non-zero-on-error` |

### ⚠️ High (Nên fix sớm)

| # | Issue | Recommendation |
|---|-------|----------------|
| 6 | Eval harness fail 4/8 benchmarks | Debug từng benchmark, fix root cause |
| 7 | 12 mypy type errors | Fix type annotations, đặc biệt config.py và worktree.py |
| 8 | Template drift `.agents` ↔ `.antigravity` | Sync pipeline.md, quyết định canonical source |
| 9 | 101 file duplicate (triplet mirroring) | Chuyển sang symlink hoặc generate tại runtime |
| 10 | Coverage safety/locks.py chỉ 35% | Viết thêm test cho release(), edge cases |

---

## 5. Khuyến nghị theo thứ tự ưu tiên

### Phase A: Fix Critical Bugs (Ngay lập tức)

```bash
# 1. Fix RunLock.acquire() — thêm self parameter
# src/agy_kit/safety/locks.py:20
# TRƯỚC: def acquire() -> bool:
# SAU:   def acquire(self) -> bool:

# 2. Fix path validator — reject whitespace + absolute paths
# src/agy_kit/validators.py:11-15
# Thêm: if not file_path.strip(): return False
# Thêm: if os.path.isabs(file_path): return False

# 3. Thêm pytest vào CI
# .github/workflows/ci.yml — thêm step:
#       - name: Run Unit Tests
#         run: |
#           pip install pytest pytest-cov
#           python -m pytest tests/unit/ --cov=src/agy_kit --cov-report=term-missing

# 4. Fix 132 ruff errors
cd ~/code/github/agy-kit
uv run --with ruff ruff check . --fix  # 35 auto-fixable
# 97 errors còn lại cần fix thủ công
```

### Phase B: CI Hardening (1-2 ngày)

1. Thêm mypy vào CI: `mypy src/agy_kit/ --ignore-missing-imports`
2. Thêm `pre-commit run --all-files` vào CI
3. Thêm ruff format check: `ruff format --check .`
4. Thêm test coverage gate: `--cov-fail-under=80`
5. Matrix test Python 3.9, 3.10, 3.11, 3.12

### Phase C: Architecture Cleanup (1 tuần)

1. **Giải quyết triplet mirroring:** Chọn 1 canonical dir (`.agents/`), generate `.antigravity/` và `.hermes/` tại runtime qua `init-agy-kit.sh`
2. **Sync toàn bộ skills vào `src/templates/`** (hiện chỉ cover agents + workflows)
3. **Archive docs phase cũ** vào `docs/archive/`
4. **Dịch nội dung tiếng Việt trong docs sang tiếng Anh** (tuân thủ quy ước repo công khai)

### Phase D: Test & Eval Harness Repair (1 tuần)

1. Fix 4 test fail + viết test cho các module coverage thấp
2. Fix eval_harness.py benchmarks fail (4/8 đang = 0/100)
3. Thêm integration tests thực tế (không chỉ unit tests)
4. Thêm property-based testing cho validators (hypothesis)

---

## 6. Đánh giá Suitability làm Harness Scaffold

### Khi nào nên dùng agy-kit?

✅ **Phù hợp cho:**
- Project cá nhân / experiment với Antigravity CLI
- Template tham khảo cho scaffold design patterns
- Học tập về agent orchestration, TDD workflow design

❌ **Chưa phù hợp cho:**
- Production coding workflow cần đảm bảo chất lượng code tự động
- Team nhiều người (CI không enforce quality, test fail)
- Project yêu cầu security cao (path validator có lỗ hổng)
- Project cần reproducible builds (template drift, 101 duplicate files)

### Điều kiện để production-ready

1. **Tất cả 5 Critical issues phải được fix**
2. **CI phải pass 100%** (ruff 0 error, pytest 0 fail, mypy 0 error)
3. **Eval harness phải pass 8/8 benchmarks**
4. **Test coverage ≥ 80%** cho toàn bộ `src/agy_kit/`
5. **Template drift = 0** (sync pipeline cover toàn bộ assets)

---

## 7. Kết luận

`agy-kit` là một scaffold có **thiết kế tham vọng và documentation xuất sắc**, thể hiện tầm nhìn rõ ràng về agent engineering workflow. Kiến trúc state machine, multi-language adapters, và quality gate framework đều được design tốt ở mức khái niệm.

Tuy nhiên, ở trạng thái hiện tại (`b70c99e`), repo **chưa đáp ứng được chính tiêu chí cốt lõi của nó là "đảm bảo chất lượng code"**:

- Code Python thực tế có **bug runtime** (locks.py thiếu `self`)
- **Path validator có lỗ hổng security** (không reject whitespace, absolute paths)
- **CI pipeline bypass hoàn toàn unit tests** → test fail mà CI vẫn xanh
- **132 lint errors** không được enforce

Đây là tình trạng phổ biến của scaffold tự reference: framework đặt ra rules khắt khe nhưng chính bản thân framework chưa tuân thủ rules đó. Cần **1-2 tuần fix focus** trước khi có thể dùng agy-kit làm harness scaffold đáng tin cậy cho coding workflow.

---

*Report generated by Hermes Agent (glm-5.2) — 2026-08-06*
*Phân tích tĩnh: ruff 0.4.4, mypy 1.13, pytest 8.x, pygount 1.6*
