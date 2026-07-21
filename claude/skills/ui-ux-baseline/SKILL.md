---
name: ui-ux-baseline
description: มาตรฐานขั้นต่ำ UI/UX/frontend — 4 data states (loading skeleton/empty/error/loaded), interaction+focus states, chat-feed sticky-bottom pattern, navigation, responsive, accessibility. ใช้เมื่อสร้าง/แก้ frontend component, หน้าจอ, layout, form, list/feed, chat, loading/empty/error state, responsive/mobile, หรือ UI ใด ๆ (React/Vue/Svelte/ไฟล์ .tsx/.jsx/.vue/.css). โหลดก่อนลงมือทำงาน UI เสมอ
---

# UI/UX Baseline

มาตรฐานขั้นต่ำ — ทำโดยไม่ต้องรอสั่ง; ถ้า design ที่ขอมาขัดข้อไหน ให้ทักและเสนอทางเลือกก่อนลงมือ

## Loading / data states — ทุก state ที่ผู้ใช้อาจพบต้องมีทางไปต่อ
- loading, empty, error และ loaded ต้องมีเมื่อเกิดได้จริงจาก data flow หรือ action ของผู้ใช้—not เพื่อให้ครบ checklist
- loading ที่รู้ shape ของ content ใช้ skeleton ของ layout จริง; empty มีข้อความและทางไปต่อ; error บอกปัญหาและ retry เมื่อทำได้
- ห้าม layout shift ตอนเปลี่ยน state (skeleton ขนาดใกล้ content จริง)

## Chat / feed / realtime list (pattern ตายตัว — ทำครบทุกข้อ)
- **sticky bottom**: อยู่ล่างสุด + ข้อความใหม่เข้า → auto-scroll ตาม
- **scroll ขึ้น = ปลด sticky**: user เลื่อนอ่านย้อน แล้วมีข้อความใหม่ → **ห้าม scroll ทับ**
  ให้แสดง indicator "มีข้อความใหม่ ↓" กดแล้วค่อยลงล่าง
- **ส่งข้อความเอง → scroll ลงเสมอ** (การส่งคือ intent กลับล่างสุด)
- **history = pagination on scroll ขึ้น** (โหลดเป็นช่วง, รักษา scroll position ตอน prepend)
  — ห้ามโหลดทั้งหมดตั้งแต่แรก
- **realtime client-state**: debounce mutation จาก socket event (มาเป็น burst); effect
  ห้าม depend on reference ที่เปลี่ยนทุก refetch — ใช้ derived primitive (กัน feedback
  loop ยิง request รัว); event-driven หลัก polling เป็น fallback ช้า; media reserve ขนาดก่อนโหลด

## Navigation / layout
- nav หลักอยู่ตำแหน่งเดิมทุกหน้า — ห้ามย้าย/สลับตามหน้า
- action หลักของหน้าเข้าถึงได้จาก viewport แรกโดยไม่ต้อง scroll
- destructive action (ลบ/ยกเลิก/สลับสถานะสำคัญ) ต้องมี confirm และบอกผลลัพธ์

## Interaction / accessibility states (ทุก interactive element)
- hover / active / **focus-visible** / disabled — ครบทุกตัว (focus สำหรับ keyboard user
  ห้ามลืม: element ที่ interactive แต่ไม่มี focus state = keyboard user มองไม่เห็นตัวเอง)
- keyboard reachable: ปุ่มจริงคือ `<button>` ไม่ใช่ `<div onClick>` (ได้ focus + Enter/Space + role ฟรี)
- tooltip/disclosure ตาม WAI-ARIA APG (อย่าใส่ aria ซ้ำกับ accessible name)
- responsive: เช็ค mobile viewport ก่อนปิดงานทุกครั้ง ไม่ใช่เฉพาะตอนถูกขอ
