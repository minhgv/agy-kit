# Quality Gate Skill — Lint, Typecheck, Security Audit

## Trigger
- Trước khi commit hoặc merge code mới.

## Procedure

### 1. Lint & Type Check
- **JavaScript/TypeScript:** `npm run lint && npx tsc --noEmit`
- **Python:** `ruff check . && mypy .`
- **PHP:** `./vendor/bin/pint --test && ./vendor/bin/phpstan analyse`
- **Fix:** Tự sửa mọi warning/error. Zero tolerance.

### 2. Secret Leak Scan
```bash
# Kiểm tra hardcode secrets trong git diff
git diff --cached | grep -iE "(api_key|password|secret|token|private_key)" || echo "CLEAN"
```
- Nếu phát hiện → remove, chuyển vào env var, patch ngay.

### 3. OWASP Security Audit
- **SQL Injection:** Tìm query string concatenation, raw SQL.
- **XSS:** Tìm `innerHTML`, unescaped output, `dangerouslySetInnerHTML`.
- **CSRF:** Verify token middleware trên POST/PUT/DELETE.
- **Access Control:** Kiểm tra authorization trên mỗi endpoint.

### 4. Test Coverage
- Chạy coverage report: `npm run test:coverage` / `pytest --cov`.
- Threshold: ≥80% cho code mới.

## Verification
- Lint: 0 error, 0 warning.
- Security: 0 hardcode secret, 0 OWASP vulnerability.
- Coverage: ≥80%.
