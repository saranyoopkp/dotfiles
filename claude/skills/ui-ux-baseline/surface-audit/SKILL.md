---
name: ui-ux-baseline:surface-audit
description: Audit และแก้ product UI ที่อาจเผย implementation, raw diagnostic, deployment/version/protocol detail หรือสั่ง action ที่ audience ทำไม่ได้ ใช้เมื่อผู้ใช้ขอตรวจ current repo/diff/flow เพื่อแยก user-facing recovery ออกจาก operator evidence; audit อย่างเดียวไม่อนุญาตให้แก้ไฟล์
---

# Product Surface Audit

เป้าหมายคือให้ product surface อธิบาย **สถานะที่ผู้ใช้พบ ผลกระทบ และทางไปต่อที่ผู้ใช้ทำได้** ขณะที่ integration control และหลักฐานวินิจฉัยยังคงอยู่ในช่องทางของ operator ไม่ใช่ลบข้อมูลทิ้ง

## Audit

1. ระบุ audience ของ surface และ action ที่ audience นั้นมีสิทธิ์ทำจริงก่อนตัดสิน copy.
2. ไล่ render path ของ flow ที่อยู่ใน scope จาก state/response mapping ไปถึง component, copy, disabled action และ recovery. เริ่มจาก current diff และ flow ที่ผู้ใช้ชี้ แล้วตาม shared primitive เฉพาะที่มีผลต่อ flow นั้น.
3. ใช้ search หา candidate ได้ แต่ห้ามถือ keyword match หรือ no-match เป็น coverage: ข้อความอาจมาจาก i18n, server payload, status map หรือ component กลาง และคำเชิงเทคนิคอาจถูกต้องบน operator surface.
4. แยกแต่ละ finding เป็น:
   - **product** — สถานะ ผลกระทบ และ recovery ที่ audience เข้าใจและทำได้;
   - **operator** — deploy/version/protocol/schema, raw field/error/stack หรือ remediation ที่ต้องใช้สิทธิ์ระบบ;
   - **mixed** — ต้องแยก product copy ออกจาก operator signal โดยยังรักษาหลักฐานทั้งสองฝั่ง.

Audit-only ให้รายงาน finding พร้อม render path และหลักฐาน ห้ามแก้ไฟล์. เมื่อผู้ใช้ขอ fix ให้แก้เฉพาะ flow ที่อยู่ใน scope และ shared owner ที่จำเป็น; finding ข้างเคียงที่ไม่บล็อกให้ park ไว้แทนการขยายเป็น redesign ทั้ง repo.

## Fix

- แก้สาเหตุ integration ด้วย compatible fallback, feature/version gate, deploy precondition หรือ operator signal ตาม boundary จริง; copy บน UI ไม่ใช่ตัวควบคุม rollout.
- Product copy ห้ามสั่งผู้ใช้ deploy, อัปเดต API, ตรวจ protocol หรือแก้ config หาก audience ทำไม่ได้. ถ้าไม่มี recovery ที่ผู้ใช้ทำได้ ให้บอกผลกระทบอย่างเป็นกลางและคง navigation/context ที่ปลอดภัย.
- อย่าแสดง blank screen หรือซ่อน failure เพื่อเลี่ยงข้อความ. ออกแบบ state ตาม `ui-ux-baseline:resource-states` และเลือก channel ตาม `ui-ux-baseline:feedback-notifications`.
- เก็บรายละเอียด operator ไว้ใน structured log, telemetry, test artifact หรือ operator-facing surface ที่มี owner และ correlation เพียงพอ; ห้ามย้าย narrative ไปไว้ใน source comment แทน observability.

## Verify

ทดสอบจาก entry path ของผู้ใช้ ไม่ใช่เปิด URL ปลายทางอย่างเดียว และครอบ transition ที่ทำให้ finding เกิดจริง. สำหรับ mixed-version ให้พิสูจน์อย่างน้อย:

- client ใหม่กับ response รุ่นที่รองรับ field ปัจจุบัน;
- client ใหม่กับ response รุ่นเก่าหรือ field ที่หาย;
- product surface ไม่เผย operator remediation และยังมี state/navigation ที่สมเหตุผล;
- operator evidence ยังระบุ mismatch ได้จากช่องทางของมัน.

สรุปผลเป็น affected surface, product behavior หลังแก้, ที่อยู่ของ operator evidence, verification และ parked findings. ห้ามอ้างว่า audit ครบทั้ง repo หากตรวจเพียง diff, keyword หรือบาง route.
