# OWASP Security Checklist for AI-Generated Code

> Dùng cho reviewer subagent và CI pipeline. Kiểm tra mỗi item trước khi merge.

## Checklist

### OWASP-AI-01: Slopsquatting / Package Hallucination
- **Rủi ro:** AI sinh import package không tồn tại; kẻ tấn công đăng malicious package trùng tên.
- **Kiểm tra:** Verify mọi import mới against lockfiles (`package-lock.json`, `requirements.txt`, `pyproject.toml`).
- **Tool:** `npm audit`, `pip audit`, `socket.dev`.

### OWASP-AI-02: Broken Object Level Authorization (IDOR/BOLA)
- **Rủi ro:** AI sinh CRUD endpoints không kiểm tra ownership hoặc user roles.
- **Kiểm tra:** Mọi endpoint nhận resource ID phải có authorization check (user owns this resource?).
- **Tool:** Manual review + integration test với 2 users khác nhau.

### OWASP-AI-03: SQL / Command Injection
- **Rủi ro:** AI dùng f-string hoặc string concatenation trong DB queries / shell commands.
- **Kiểm tra:** Require parameterized queries (`cursor.execute("... WHERE id = %s", (id,))`). Cấm `shell=True`, `eval()`, raw string concat.
- **Tool:** `ruff` S-rules, `bandit`, `eslint security plugin`.

### OWASP-AI-04: Hardcoded Credentials & Weak Defaults
- **Rủi ro:** AI nhúng test credentials, fallback keys, JWT secret yếu (`secret123`).
- **Kiểm tra:** Scan hardcode secrets. Require env var validation.
- **Tool:** Gitleaks, TruffleHog (verified mode).

### OWASP-AI-05: Excessive Agent Agency & Unrestricted Tool Privileges
- **Rủi ro:** Scaffold cấp shell execution không giới hạn hoặc system-level tools không sandbox.
- **Kiểm tra:** Implement least-privilege tool execution, path sandboxing, approval thresholds cho destructive ops.
- **Tool:** Review `.antigravity/agents/*.json` → verify `allowed_commands` whitelist.
