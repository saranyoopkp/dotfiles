---
name: ui-ux-baseline:content-localization
description: ออกแบบหรือแก้ UI localization/i18n, translation key, locale fallback, pluralization/interpolation, date/number/currency formatting, text expansion และ RTL ใช้เมื่อ UI รองรับหลายภาษา/locale หรือเพิ่มข้อความที่อยู่ใน localized surface
---

# Content & Localization

ตรวจระบบ localization, locale source, key convention และ formatter ที่มีอยู่ใน repo ก่อนแก้;
ห้ามสมมติ library, locale หรือ fallback และห้ามสร้างระบบ i18n ขนาน.

- เก็บข้อความที่ผู้ใช้เห็นใน translation source ตาม convention เดิม; ห้ามใช้ข้อความแปลเป็น logic key, persisted enum หรือ selector ที่ code พึ่งพา
- ใช้ pluralization, gender และ interpolation ของระบบเดิม ไม่ต่อประโยคจาก fragment ที่ผู้แปลจัดลำดับใหม่ไม่ได้; ตัวแปรต้องมี context และ escape ตาม output boundary
- format date/time, number และ currency ด้วย locale-aware formatter โดยคงค่าต้นทาง, timezone และ currency semantics จาก owner เดิม; localization เปลี่ยนการแสดงผล ไม่เปลี่ยนข้อมูล
- กำหนด missing-key/fallback behavior ที่ตรวจพบจริง และให้ error, validation, toast, empty/loading state, accessible name และ metadata ที่ผู้ใช้เห็นอยู่ใน coverage เดียวกัน
- ออกแบบให้รับ text expansion, wrapping, font fallback และภาษาที่ไม่มีช่องว่าง; ห้ามล็อกความสูง/ความกว้างจากข้อความภาษาเดียว
- ตรวจ RTL ทั้ง reading/order, alignment, focus/navigation และ directional icon; mirror เฉพาะสิ่งที่สื่อทิศทาง ไม่ mirror logo, trademark หรือ media content

## Refactor Existing UI

inventory ข้อความที่ผู้ใช้เห็นจาก repo จริง รวม inline string, validation/error, state, accessible name,
metadata และข้อความที่ประกอบตอน runtime. แยก migration เป็นสองชั้น:

1. **Extract โดยคง behavior**: ย้าย copy เดิมไป translation key/source, ต่อ fallback และรักษา
   wording, formatting, variable และ fallback behavior เดิม
2. **Localize/ปรับ semantics**: เพิ่ม locale, plural rule, formatter, wording หรือ RTL เป็นงานแยก;
    สิ่งที่เปลี่ยนความหมาย/default/behavior ต้องใช้ authorization และ impact rules ใน
    `claude/rules/core/change-control.md`

migrate ทีละ surface ที่ตรวจได้, ใช้ key convention/source เดียว และค้น consumer ก่อนลบ inline
source เดิม; ห้ามปล่อยข้อความเดียวมี owner สองที่โดยไม่มี migration plan. ตรวจ default locale เทียบ
baseline ก่อน แล้วจึงตรวจ fallback, missing key, plural, text expansion และ RTL ที่รองรับจริง.

visual icon system อยู่ `design-foundations`; accessible label/semantics อยู่ `interaction-a11y`;
timezone และ money semantics อยู่ rules เจ้าของเดิม. ก่อนส่งมอบ ตรวจ locale หลัก, fallback,
ข้อความยาว/plural และ RTL เมื่อ product ระบุว่ารองรับ; locale ที่ยังไม่รองรับให้รายงานตามจริง.
