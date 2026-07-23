---
name: ui-ux-baseline:resource-states
description: ออกแบบ UI state ของ resource ที่ระบบโหลดหรือ refresh เช่น loading, empty, error, loaded, stale data และ retry ใช้เมื่อ component/page แสดงข้อมูลจาก API, query, cache หรือ async read operation
---

# Resource States

เริ่มจาก data flow จริง: state ไหนเกิดได้จาก request, cache, permission, query หรือ action ของผู้ใช้ แล้วออกแบบเฉพาะ state เหล่านั้น ไม่สร้างครบชุดเพื่อ checklist

- loading, empty, error และ loaded ต้องมีเมื่อเกิดได้จริงจาก data flow หรือ action ของผู้ใช้
- loading ที่รู้ shape ของ content ใช้ skeleton ที่ใกล้ layout จริง เพื่อไม่ให้ layout shift; ถ้าไม่รู้ shape ให้ใช้ progress ที่ไม่หลอกว่ามี content แล้ว
- แยก `ไม่มีข้อมูลในระบบ` ออกจาก `ค้นหาแล้วไม่พบผลลัพธ์`; แต่ละ state ต้องบอกความหมายและทางไปต่อที่เหมาะสม
- error บอกสิ่งที่ผู้ใช้ทำต่อได้: retry, เปลี่ยน query, ตรวจ permission หรือกลับไปหน้าที่ปลอดภัย; อย่าลบ context ที่กรอก/เลือกไว้โดยไม่จำเป็น — หากต้องเลือก toast/banner/inline error ให้อ่าน `ui-ux-baseline:feedback-notifications`
- refresh หรือ stale data ต้องสื่อว่าข้อมูลเก่าแค่ไหนและ interaction ใดปลอดภัยระหว่างรอ; อย่าแสดงข้อมูลเก่าเป็นข้อมูลใหม่เงียบ ๆ

ตรวจ state transition อย่างน้อย: initial load → loaded, load → error → retry, และ query/action ที่ทำให้ empty หรือ refresh หาก flow นั้นมีอยู่จริง
