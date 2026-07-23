---
name: ui-ux-baseline:realtime-conversation
description: ออกแบบ chat, feed และ realtime event stream ที่มีข้อความ/รายการเข้าตามเวลา ใช้เมื่อมี sticky bottom, unread indicator, history prepend, websocket/socket event, presence หรือ live update ที่อาจรบกวนตำแหน่งอ่านของผู้ใช้
---

# Realtime Conversation

- **sticky bottom**: อยู่ล่างสุดและมีข้อความใหม่เข้า → auto-scroll ตาม
- **scroll ขึ้น = ปลด sticky**: เมื่อผู้ใช้กำลังอ่านย้อน ห้าม scroll ทับ; แสดง indicator “มีข้อความใหม่” และให้ผู้ใช้เลือกกลับลงล่าง
- ผู้ใช้ส่งข้อความเอง = intent กลับล่างสุด จึง scroll ลงเสมอหลังผลที่แสดงได้ถูก reconcile
- history ใช้ pagination เมื่อ scroll ขึ้น และต้องรักษา scroll position ตอน prepend; ห้ามโหลดทั้งหมดตั้งแต่แรกโดยไม่มีเหตุผลด้านขนาดข้อมูล
- event จาก realtime ต้องจัดการ ordering, duplicate, reconnect และ reconciliation กับ server state; debounce mutation ที่มาเป็น burst และอย่าให้ effect depend on reference ที่เปลี่ยนทุก refetch จนเกิด feedback loop
- reserve ขนาด media ก่อนโหลด และแยก event ใหม่ที่ยังไม่อ่านออกจาก event ที่ผู้ใช้เห็นแล้ว

ตรวจอย่างน้อย: อยู่ล่างสุด, อ่านย้อนขณะ event เข้า, ส่งเอง, prepend history และ reconnect/duplicate event ตามระบบที่มีจริง
