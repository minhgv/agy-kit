# MEMORY.md — agy-kit Project Memory

> Auto-loaded at session start. Stores architectural decisions, conventions, and patterns.

## Tech Stack
- Agent platform: Antigravity CLI (agy) v1.1.0+
- Skills format: SKILL.md (Agent Skills Open Standard)
- CI: GitHub Actions (lint + test + gitleaks + trufflehog)

## Architecture Decisions
- **Sequential Pipeline** as default orchestration (Plan→TDD→Gate→QA→Review)
- **Model Routing:** flash-high for Plan/Code/Review, flash-low for QA (cost optimization)
- **Dual-Constraint Security:** Prompt guidance + Schema-level tool filtering per subagent
- **SPEC-Driven:** Every feature >3 files requires plans/SPEC_*.md before code

## Conventions
- Commits: Conventional Commits (feat:, fix:, test:, docs:, refactor:)
- Test coverage threshold: ≥80% for new code
- Pre-commit hooks: ruff + eslint + gitleaks

## Known Issues & Fixes
- **Ruff Full Rule Alignment**: Always check all 6 warning classes (`EXE001`, `RUF059`, `UP006/UP035/FA100`, `PLW1510`, `BLE001/S110`, `SIM115`) simultaneously before declaring zero-error status.

## Lessons Learned & Linter Post-Mortem (2026-08-06)
- **Vấn đề (Mới đúc kết từ sai lầm)**: Khai báo "đã hết lỗi" khi mới chỉ sửa một phần danh sách linter mà chưa đối chiếu triệt để từng quy tắc của Ruff.
- **Quy tắc sửa dứt điểm Linter cho toàn bộ Repo agy-kit**:
  1. `EXE001`: Tất cả script Python có shebang `#!/usr/bin/env python3` trong `bin/` hoặc `tests/` phải được cấp quyền `chmod +x`.
  2. `RUF059`: Tất cả biến unpacked tuple return không sử dụng bắt buộc phải gắn tiền tố `_` (VD: `_code, out, _err = run_command(...)`).
  3. `UP006 / UP035 / FA100`: Thêm `from __future__ import annotations` ở đầu file và chuyển toàn bộ `List[T]` -> `list[T]`, `Dict[K, V]` -> `dict[K, V]`, `Optional[T]` -> `T | None`.
  4. `PLW1510`: Mọi lệnh `subprocess.run` phải khai báo tham số `check` tường minh (`check=False` hoặc `check=True`).
  5. `BLE001` & `S110`: Khối `try ... except Exception: pass` cố ý bắt buộc phải khai báo đầy đủ cả 2 tag `# noqa: BLE001, S110`. Thiếu 1 trong 2 ruff vẫn báo lỗi.
  6. `SIM115`: Các hàm mở file giữ handle khóa hệ thống (`fcntl.flock`) phải khai báo `# noqa: SIM115`.
