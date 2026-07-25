---
name: ui-ux-baseline:interaction-a11y
description: มาตรฐาน interaction และ accessibility สำหรับ UI ที่มี interactive element ใช้ทุกครั้งที่เพิ่มหรือแก้ button, link, input, menu, dialog, tooltip, disclosure, drag/drop หรือ custom control ไม่ว่าหน้าจอจะเล็กเพียงใด
---

# Interaction & Accessibility

- ใช้ semantic HTML ก่อน: ปุ่มคือ `<button>`, navigation คือ link/nav, input คือ form control; ห้ามใช้ `<div onClick>` แทน control ที่มี semantics อยู่แล้ว
- interactive element ต้องมี state ที่สังเกตได้ตามที่เกิดได้จริง: hover, active, **focus-visible**, disabled และ pending; keyboard user ต้องเห็นตำแหน่ง focus เสมอ
- ทุก action ต้อง keyboard reachable และทำงานด้วย keyboard ตาม native expectation; อย่าเขียน role/keyboard handler ซ้ำเมื่อ native element ทำให้ได้แล้ว
- dialog, menu, tooltip และ disclosure ให้ทำตาม WAI-ARIA APG: focus management, Escape, labeling และ announcement ถูกต้อง; อย่าใส่ ARIA ซ้ำกับ accessible name ที่มีอยู่
- validation/error และ dynamic update ต้องมี name, instruction และ announcement ที่ผู้ใช้ assistive technology เข้าใจได้; สีอย่างเดียวไม่ใช่การสื่อสารที่พอ
- motion ที่มีความหมายหรือเล่นต่อเนื่องต้องเคารพ `prefers-reduced-motion`; ลดหรือปิดโดยไม่ซ่อนข้อมูล, state หรือทางสั่งงาน
- icon-only control ต้องมี accessible name; action ที่กำกวมหรือเสี่ยงต้องมี visible label ไม่พึ่ง tooltip อย่างเดียว. icon ตกแต่งต้องซ่อนจาก accessibility tree และ emoji ห้ามเป็นช่องทางเดียวที่สื่อ action/state/severity

ตรวจอย่างน้อยด้วย keyboard: tab order, focus-visible, activate, dismiss และ focus return สำหรับ pattern ที่มีจริง
