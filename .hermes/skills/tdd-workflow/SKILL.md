# TDD Workflow Skill — Red → Green → Refactor

## Trigger
- Bất kỳ tác vụ code mới nào yêu cầu viết logic.

## Procedure

### RED Phase
1. Đọc SPEC file (`plans/SPEC_*.md`) để hiểu requirements.
2. Viết Unit Test + Integration Test mô phỏng toàn bộ requirements.
3. Chạy test runner: `npm run test` / `pytest` / `php artisan test`.
4. **Verify:** Tất cả test mới phải FAIL (vì chưa có logic). Nếu test PASS ngay → test sai hoặc logic đã tồn tại.

### GREEN Phase
1. Viết code logic tối thiểu để PASS tất cả test.
2. Không viết tính năng thừa ngoài SPEC.
3. Chạy lại test → **Verify:** 100% PASS.

### REFACTOR Phase
1. Tối ưu: tách hàm dài, đặt tên biến rõ ràng, gỡ code trùng (DRY).
2. Chạy lại test sau mỗi thay đổi → **Verify:** ALL TESTS STILL PASS.
3. Báo cáo final coverage.

## Pitfalls
- Không bỏ qua RED phase — nếu logic phức tạp, chia nhỏ thành nhiều test.
- Nếu test khó viết → SPEC có thể thiếu chi tiết → quay lại Planner.
- Coverage threshold: ≥80% cho code mới.
