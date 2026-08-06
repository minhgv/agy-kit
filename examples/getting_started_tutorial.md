# Hướng Dẫn Bắt Đầu: Từ Zero Đến Feature Đầu Tiên Với agy-kit

Chào mừng bạn đến với **agy-kit** — bộ khung kĩ thuật Agent (Agent Engineering Kit) tối ưu hóa cho Antigravity CLI (`agy`). Tutorial này sẽ hướng dẫn bạn từ chưa có gì đến triển khai hoàn chỉnh một tính năng REST API theo đúng 5 bước tiêu chuẩn.

---

## 📋 Chuẩn Bị Môi Trường

Yêu cầu hệ thống:
- Antigravity CLI (`agy`) v2.0 trở lên
- Git & Python 3.11+ (hoặc Node.js / Go tùy stack của bạn)
- Thư viện `uv` (cho Python) hoặc `npm` / `pnpm` (cho JS/TS)

```bash
# 1. Cài đặt agy-kit vào dự án của bạn
mkdir my-api-service && cd my-api-service
git init

# Clone agy-kit scaffold
git clone https://github.com/vudovn/agy-kit.git /tmp/agy-kit
cp -r /tmp/agy-kit/{AGENTS.md,GEMINI.md,.antigravity,plans,Makefile,.gitleaks.toml} .
rm -rf /tmp/agy-kit
```

---

## 5 Bước Xây Dựng Feature: `GET /api/v1/healthcheck`

---

### Bước 1: Lập Kế Hoạch & Viết SPEC (`Planner Agent`)

Quy tắc cốt lõi của agy-kit: **Không gõ 1 dòng code nào trước khi có SPEC được duyệt.**

```bash
agy run --agent plan "Khảo sát dự án và tạo SPEC cho tính năng GET /api/v1/healthcheck trả về status OK, uptime, và version. Lưu tại plans/SPEC_healthcheck.md"
```

Agent `planner` sẽ khảo sát codebase và tự động sinh file `plans/SPEC_healthcheck.md` đầy đủ Use-cases, API schema, và File Mutation Manifest.

---

### Bước 2: Triển Khai TDD Red-Green-Refactor (`Coder Agent`)

Kích hoạt Subagent `coder` để thực hiện TDD:

```bash
agy run --agent coder "Đọc plans/SPEC_healthcheck.md. Thực hiện TDD: Viết test RED trước trong tests/test_healthcheck.py, chạy test xác nhận FAIL. Sau đó viết logic GREEN trong app/main.py. Cuối cùng Refactor."
```

**Diễn biến của Coder Agent:**
1. Tạo `tests/test_healthcheck.py` kiểm tra status 200 và response JSON `{"status": "ok"}`.
2. Chạy `pytest` -> Test **FAIL (RED)** (do endpoint chưa tồn tại).
3. Sửa `app/main.py` thêm router `GET /api/v1/healthcheck`.
4. Chạy lại `pytest` -> Test **PASS (GREEN)**.
5. Tự động chạy `ruff check app/` và `mypy app/` để refactor sạch sẽ.

---

### Bước 3: Chạy Cổng Kiểm Soát Chất Lượng (`Reviewer Agent`)

Trước khi commit, chạy audit bảo mật và linting:

```bash
agy run --agent reviewer "Audit git diff hiện tại. Chạy ruff check, mypy strict, và quét secret gitleaks. Kiểm tra OWASP-AI checklist."
```

Reviewer Agent sẽ kiểm tra:
- Có hardcode API key / Password nào trong code không?
- Type hint có bị thiếu không?
- Có hàm chưa được test không?

---

### Bước 4: Kiểm Thử E2E Dogfooding (`QA Agent`)

Cho phép QA Agent khởi động server thật và cURL kiểm tra trực tiếp:

```bash
agy run --agent qa "Khởi động FastAPI app bằng uvicorn. Chạy cURL test endpoint GET /api/v1/healthcheck. Thu thập bằng chứng HTTP headers và status code."
```

QA Agent sẽ xuất log bằng chứng E2E:
```text
HTTP/1.1 200 OK
content-type: application/json
date: Thu, 06 Aug 2026 02:25:00 GMT

{"status": "ok", "uptime": 12.4, "version": "1.0.0"}
```

---

### Bước 5: Review & Commit Theo Convention (`Reviewer Agent`)

Khi mọi cổng kiểm soát đã đạt, tiến hành gom commit chuẩn:

```bash
git add .
agy run --agent review "Tạo git commit theo định dạng Conventional Commits cho feature healthcheck"
```

Kết quả commit:
```text
feat(healthcheck): add GET /api/v1/healthcheck endpoint with uptime and version
```

---

## 🎯 Summary Cheatsheet

| Giai đoạn | Lệnh `agy` tương ứng | Sản phẩm đầu ra |
|-----------|----------------------|-----------------|
| **1. Plan** | `agy run --agent plan "..."` | `plans/SPEC_<feature>.md` |
| **2. TDD** | `agy run --agent coder "..."` | Unit/Integration Tests + Source code |
| **3. Gate** | `agy run --agent reviewer "..."` | Lint / Typecheck / Security Audit Report |
| **4. QA** | `agy run --agent qa "..."` | E2E cURL logs & Dogfooding Evidence |
| **5. Commit** | `agy run --agent review "..."` | Git commit Conventional Commits |
