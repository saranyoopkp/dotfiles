---
name: powershell-commit-no-quotes
description: commit message ผ่าน harness PowerShell tool ห้ามใส่เครื่องหมายคำพูดใน here-string (PS 5.1 parse พัง) — ใช้ ASCII เรียบ ๆ
metadata:
  type: project
---

commit ผ่าน PowerShell tool: here-string ที่มีเครื่องหมายคำพูด/อักขระพิเศษ = parse พัง
**How to apply:** เขียน commit message เป็น ASCII เรียบ ๆ ไม่มี quote; หรือ commit ผ่าน Bash tool
