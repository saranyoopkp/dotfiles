---
name: ui-ux-baseline:layout-navigation
description: ออกแบบ page layout, information hierarchy, navigation, responsive/mobile behavior และ viewport priority ใช้เมื่อสร้างหรือแก้หน้าจอ, route, shell, header/sidebar, responsive CSS หรือการจัดวาง action/content
---

# Layout & Navigation

- nav หลักต้องอยู่ในตำแหน่งและภาษาที่สม่ำเสมอข้ามหน้าที่มีหน้าที่เดียวกัน; ผู้ใช้ต้องรู้ว่าตนอยู่ที่ใดและกลับไปยัง context ก่อนหน้าได้อย่างไร
- action หลักและสถานะที่ต้องตัดสินใจควรเข้าถึงได้จาก viewport แรกเมื่อบริบทของงานต้องการ; อย่าซ่อน action สำคัญหลัง overflow โดยไม่มีเหตุผล
- จัด content ตาม decision priority: ข้อมูลที่ผู้ใช้ต้องใช้ตัดสินใจ เห็นสถานะปัจจุบัน หรือทำ action/recover ต่อได้ต้องอยู่ใน primary view; คำอธิบายประกอบ ตัวอย่าง และรายละเอียดเชิงเทคนิคค่อยใช้ progressive disclosure และห้ามซ่อน cost, consent, error หรือทาง recover ที่สำคัญไว้เพียง tooltip
- responsive คือการจัดลำดับข้อมูลและ action ใหม่ตามพื้นที่ ไม่ใช่เพียงย่อ desktop; กำหนด behavior ของ sidebar, table overflow, action group และ content priority ที่ breakpoint จริง
- ตรวจ mobile viewport, narrow desktop และ wide viewport ที่ UI รองรับ; ห้ามมี horizontal overflow หรือ action ที่แตะไม่ได้โดยไม่ตั้งใจ
- layout เปลี่ยน state แล้วต้องคง orientation ของผู้ใช้: title, context, selection และ action ที่กำลังทำไม่ควรกระโดดหรือหายเงียบ ๆ

เกณฑ์ accessibility ของ interactive element อยู่ที่ `interaction-a11y`; อย่าซ้ำ ARIA/keyboard detail ที่นี่
scale ของ grid/spacing อยู่ `design-foundations`; ส่วนการจัดลำดับและวาง content/action ของหน้านี้ยังเป็น owner ของ skill นี้
