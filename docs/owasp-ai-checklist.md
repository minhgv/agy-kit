# OWASP Security Checklist for AI-Generated Code

> Used for reviewer subagent and CI pipeline. Check each item before merging.

## Checklist

### OWASP-AI-01: Slopsquatting / Package Hallucination
- **Risk:** AI generates non-existent package imports; attackers publish malicious packages with matching names.
- **Verification:** Verify all new imports against lockfiles (`package-lock.json`, `requirements.txt`, `pyproject.toml`).
- **Tool:** `npm audit`, `pip audit`, `socket.dev`.

### OWASP-AI-02: Broken Object Level Authorization (IDOR/BOLA)
- **Risk:** AI generates CRUD endpoints without checking ownership or user roles.
- **Verification:** Every endpoint receiving a resource ID must have an authorization check (user owns this resource?).
- **Tool:** Manual review + integration test with 2 different users.

### OWASP-AI-03: SQL / Command Injection
- **Risk:** AI uses f-strings or string concatenation in DB queries / shell commands.
- **Verification:** Require parameterized queries (`cursor.execute("... WHERE id = %s", (id,))`). Prohibit `shell=True`, `eval()`, raw string concat.
- **Tool:** `ruff` S-rules, `bandit`, `eslint security plugin`.

### OWASP-AI-04: Hardcoded Credentials & Weak Defaults
- **Risk:** AI embeds test credentials, fallback keys, weak JWT secrets (`secret123`).
- **Verification:** Scan for hardcoded secrets. Require env var validation.
- **Tool:** Gitleaks, TruffleHog (verified mode).

### OWASP-AI-05: Excessive Agent Agency & Unrestricted Tool Privileges
- **Risk:** Scaffold grants unrestricted shell execution or unsandboxed system-level tools.
- **Verification:** Implement least-privilege tool execution, path sandboxing, approval thresholds for destructive ops.
- **Tool:** Review `.antigravity/agents/*.json` → verify `allowed_commands` whitelist.
