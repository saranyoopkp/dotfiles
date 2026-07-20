---
name: ui-ux-baseline
description: "Baseline UX for building or changing user-facing views: feedback states, interaction safety, accessibility and responsive behavior. Use when a change affects UI behavior or layout."
---

# UI/UX Baseline

Use the project design system and existing interaction patterns first. Apply checks that match the affected user journey rather than adding every state to every component.

- ทุก state ที่ผู้ใช้อาจพบจาก data flow หรือ action ของตนต้องมี feedback และทางไปต่อที่ชัดเจน เช่น loading, empty, error หรือ success เมื่อ state นั้นเกิดได้จริง; ไม่ต้องสร้าง state เพื่อให้ครบ checklist
- Prevent duplicate destructive or costly actions; make pending work and recoverable failures understandable.
- form แสดง validation ใกล้ field ที่เกี่ยวข้อง, ย้าย focus ไปจุดผิดแรกเมื่อ submit ไม่ผ่าน และรักษาข้อมูลที่ผู้ใช้กรอกไว้เมื่อ request ล้มเหลว
- action ที่ลบ ยกเลิก หรือเปลี่ยนสิ่งที่ย้อนยาก ให้ใช้ confirmation หรือ undo ตามระดับผลกระทบ
- Lists, feeds and real-time views preserve the user's position and provide a clear strategy for new, missing or failed items when relevant.
- Interactive controls are keyboard-operable, have an accessible name, visible focus and a disabled/loading state when needed.
- Validate responsive layout, overflow and contrast for the changed view; respect `prefers-reduced-motion`, and make touch controls large and separated enough to use reliably. Use semantic HTML before custom accessibility workarounds.

Before delivery, exercise the primary changed journey at a representative viewport and state. State any meaningful state or device not checked.
