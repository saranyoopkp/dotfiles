# Memory Index

## Feedback (preference/วิธีทำงานกับ user)
- [Deliverable form: data first](deliverable-form-data-first.md) — รายงาน/ผลวัด = ตัวเลข+กราฟเป็นหลัก ไม่ใช่ความเรียง
- [Audit questions = check evidence](audit-questions-mean-check-evidence.md) — คำถามสั้น "จริงหรอ/แม่นหรอ" = เปิดหลักฐานดิบ ไม่ใช่อธิบายเพิ่ม
- [Code comments: local why, broader rationale in docs](code-comments-why-plus-pointer.md) — ใช้ scope/reader เป็นเกณฑ์; ความยาวอย่างเดียวไม่บังคับย้าย
- [Validate whole file after edit](validate-whole-file-after-edit.md) — append/sed แล้วอ่านเต็มไฟล์ตรวจโครงก่อน commit

## Project quirks/กับดัก
- [Hook fix = verify via real restart](hook-fix-verify-real-restart.md) — Bash tool ≠ WSL hook runner
- [claude -p test bed limits](claude-p-testbed-limits.md) — ไม่ยิง Stop hook; ห้ามแก้ script ที่กำลังรัน
- [Metrics corpus: dedup first](metrics-corpus-dedup-first.md) — sibling ผี ~9%, main-only, time trend
- [Deploy docs-drift in pairs](deploy-docs-drift-in-pairs.md) — script+settings ไปคู่กัน
- [PowerShell commit: no quotes](powershell-commit-no-quotes.md) — here-string parse พัง
