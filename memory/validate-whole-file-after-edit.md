---
name: validate-whole-file-after-edit
description: แก้ไฟล์เอกสาร/skill แบบ append/sed แล้ว ต้องอ่านเต็มไฟล์ตรวจโครงก่อน commit — spot-check เฉพาะจุดแก้จับ defect เชิงโครงไม่ได้
metadata:
  type: feedback
---

หลังแก้ไฟล์ (โดยเฉพาะ append ท้ายไฟล์ / sed / string-replace) → **อ่านเต็มไฟล์** ตรวจ:
โครง/ลำดับ section, ของที่ควรอัปเดตตามกัน (สรุป/ตาราง/shortcut ที่อ้างเนื้อที่เพิ่ม), footer ยังอยู่ท้าย

**Why:** 2026-07-18 user สั่ง "แก้แล้ว validate เต็มไฟล์ด้วย" — อ่านเต็มแล้วเจอ 2 defect ทันที
(shortcut ตกชั้นใหม่, footer ค้างกลางไฟล์) ทั้งคู่เกิดจาก append โดยไม่มองทั้งไฟล์;
วันเดียวกันยังมีบทเรียนพี่น้อง: heredoc string-replace fail เงียบ 3 ครั้ง → ไฟล์สำคัญใช้ Edit tool

**How to apply:** แก้เสร็จ → Read เต็มไฟล์ (หรือ tail ส่วนโครง) → เช็คลำดับ+ความสอดคล้อง →
ถ้าเป็นเอกสาร ปิดด้วย /docs:link
