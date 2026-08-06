---
description: "Review git diff, check DRY/SOLID/security, and create Conventional Commits. Run before pushing."
---

# /review

Review toàn bộ thay đổi và tạo commits.

## Steps

### Step 1: Pre-Commit Diff Audit
```bash
// turbo
agy run --agent reviewer "Bạn là Principal Code Reviewer. Thực hiện:

1. PRE-COMMIT DIFF AUDIT — kiểm tra 5 tiêu chí:
   - Có dư thừa debug log/print/console.log không?
   - Có sửa nhầm file ngoài File Mutation Manifest (SPEC) không?
   - Có phá vỡ kiểu dữ liệu / API contract không?
   - Code có tuân thủ naming convention không?
   - Đã viết test bù đắp cho code mới chưa?

2. THREE-STATE VERIFICATION — phân loại mỗi nghi vấn:
   - CONFIRMED: chỉ ra line + trigger path
   - PLAUSIBLE: cần thêm test/env để xác nhận
   - REFUTED: chứng minh không phải lỗi bằng code line

3. CONVENTIONAL COMMITS — gom các file thay đổi thành commit có ý nghĩa:
   - feat:, fix:, test:, docs:, refactor:, chore:
   - KHÔNG commit từng file đơn lẻ."
```
