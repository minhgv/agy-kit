# Error Recovery & Self-Healing Scenario in agy-kit

Kịch bản này mô tả chi tiết cách `agy-kit` phát hiện, phân tích và tự động khắc phục lỗi (Self-Healing / Error Recovery) khi một Unit Test bị thất bại trong chu trình TDD.

---

## 1. Bối Cảnh Lỗi (Failure Context)

Trong lúc triển khai tính năng **User Registration**, Subagent `coder` chạy test suite để chuyển từ bước **RED** sang **GREEN**. Tuy nhiên, test case xác thực độ mạnh mật khẩu bị thất bại:

### Lệnh thực thi:
```bash
pytest tests/test_auth_register.py -k test_register_weak_password
```

### Log lỗi trả về (Stdout / Stacktrace):
```text
=================================== FAILURES =================------------------
_____________________ test_register_weak_password _____________________

client = <TestClient target=FastAPI>, db_session = <Session>

    def test_register_weak_password(client, db_session):
        payload = {
            "email": "user@example.com",
            "password": "123",  # Weak password (< 8 chars)
            "full_name": "Test User"
        }
        response = client.post("/api/v1/auth/register", json=payload)
>       assert response.status_code == 422
E       assert 201 == 422
E        +  where 201 = <Response [201 Created]>.status_code

tests/test_auth_register.py:48: AssertionError
----------------------------- Captured stderr call -----------------------------
INFO:     127.0.0.1:48291 - "POST /api/v1/auth/register HTTP/1.1" 201 Created
```

---

## 2. Error Recovery Prompt (Gửi đến Agent)

Mẫu prompt được hệ thống agy-kit tạo tự động để chuyển giao ngữ cảnh lỗi cho agent:

```xml
<error_recovery_context>
  <phase>TDD_GREEN_STEP_FAILED</phase>
  <failing_test>tests/test_auth_register.py::test_register_weak_password</failing_test>
  <error_type>AssertionError: Expected HTTP 422 for weak password '123', got 201 Created</error_type>
  
  <stacktrace>
> assert response.status_code == 422
E assert 201 == 422
  </stacktrace>

  <relevant_files>
    <file path="src/auth/schemas.py" lines="10-25" />
    <file path="src/auth/auth_service.py" lines="30-50" />
  </relevant_files>

  <instructions>
    1. DO NOT rewrite or modify the test file `tests/test_auth_register.py`. The test is correct.
    2. Analyze `src/auth/schemas.py` and `src/auth/auth_service.py`.
    3. Identify why a 3-character password ("123") bypassed validation and returned 201 Created.
    4. Apply a targeted patch adding minimum 8 characters and pattern validation using Pydantic Field constraint or regex.
    5. Re-run `pytest tests/test_auth_register.py` to confirm test passes GREEN.
  </instructions>
</error_recovery_context>
```

---

## 3. Suy Luận & Phản Hồi Của Agent (`coder`)

### Agent Thinking & Diagnosis:
> "Test `test_register_weak_password` mong đợi HTTP status 422 khi mật khẩu là '123', nhưng API trả về 201 Created.
> Nguyên nhân: Trọng `src/auth/schemas.py`, trường `password` thuộc `UserRegistrationRequest` chỉ khai báo `password: str` mà chưa áp dụng constraint `min_length=8` hoặc validator.
> Cần sửa: Cập nhật `src/auth/schemas.py` thêm `Field(..., min_length=8, description="Password must be at least 8 characters")`."

### Tool Call 1: Inspections via `read_file`
Agent đọc file `src/auth/schemas.py`:
```python
class UserRegistrationRequest(BaseModel):
    email: EmailStr
    password: str
    full_name: str
```

### Tool Call 2: Patch execution via `patch`
Agent thực thi sửa chữa trực tiếp:
```patch
*** Begin Patch
*** Update File: src/auth/schemas.py
@@ -10,3 +10,3 @@
 class UserRegistrationRequest(BaseModel):
     email: EmailStr
-    password: str
+    password: str = Field(..., min_length=8, max_length=128, description="Password must be at least 8 characters")
     full_name: str
*** End Patch
```

### Tool Call 3: Verification via `terminal`
Agent chạy lại test để kiểm minh:
```bash
pytest tests/test_auth_register.py
```

### Response Result (Stdout):
```text
tests/test_auth_register.py ........                                    [100%]

============================== 8 passed in 0.42s ===============================
```

---

## 4. Loop Prevention & Stalled Agent Rule

Để tránh trường hợp agent thử sửa đi sửa lại nhiều lần vô ích (Infinite Retry Loop):

```text
               +---------------------------+
               |  Test Fail Detected (1st) |
               +-------------+-------------+
                             |
                             v
               +---------------------------+
               | Apply Error Recovery Patch|
               +-------------+-------------+
                             |
                   Pass? ----+---- Fail?
                    |               |
                    v               v
               [DONE 100%]    +---------------------------+
                              | Retry Count == 3 Limit?  |
                              +-------------+-------------+
                                     |
                          No --------+-------- Yes
                          |                     |
                          v                     v
              [Re-analyze Stacktrace]   [TRIGGER LOOP BREAKER]
                                        - Pause Agent Execution
                                        - Re-evaluate Architecture
                                        - Escalate to Planner/User
```

**Quy tắc ngắt lặp (Loop-Breaker Rule):**
- Nếu agent thực hiện **3 lần patch thất bại liên tiếp** trên cùng một test case, agy-kit sẽ tự động ngắt phiên (abort turn).
- Agent buộc phải dừng lại, xuất báo cáo nguyên nhân bế tắc và đề xuất chuyển hướng cho Kiến trúc sư (Planner) hoặc người dùng hỗ trợ.
