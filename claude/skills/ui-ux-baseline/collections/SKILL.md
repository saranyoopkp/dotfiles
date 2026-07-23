---
name: ui-ux-baseline:collections
description: ออกแบบ UI สำหรับค้นหา อ่าน จัดลำดับ เลือก และจัดการข้อมูลหลายรายการ เช่น table, list, grid, search/filter/sort, pagination, bulk action และ virtualized collection ใช้เมื่อผู้ใช้จัดการ collection ที่ไม่ใช่ realtime conversation โดยตรง
---

# Collections

ถือ query, filter, sort, pagination และ selection เป็น state ของงาน ไม่ใช่รายละเอียดของ widget

- แยก collection ว่างจริง ออกจากผลลัพธ์ว่างเพราะ query/filter; แสดง query ที่มีผลและทาง reset ที่ไม่ทำให้ผู้ใช้หลงทาง
- เมื่อผู้ใช้กลับมา, refresh หรือ share URL ให้รักษา state เท่าที่ architecture ของผลิตภัณฑ์รองรับ; อย่า reset filter/หน้า/selection เงียบ ๆ
- pagination/load more ต้องสื่อขอบเขตและสถานะกำลังโหลด; เปลี่ยน sort/filter แล้วต้องกำหนดอย่างชัดเจนว่า page และ selection ถูก reset หรือ reconcile อย่างไร
- bulk action ต้องแสดงจำนวนและขอบเขตของสิ่งที่จะได้รับผล รวมทั้ง failure แบบ partial หากเกิดได้
- ใช้ virtualization หรือ server-side query เมื่อขนาดข้อมูล/การวัดจริงบ่งชี้ว่าจำเป็น; อย่าทำให้ keyboard, focus และ scroll restoration พังเพียงเพื่อ optimization

ตรวจอย่างน้อย: empty collection, no-match query, paging/filter transition, selection และ bulk-action result ตาม flow ที่มีจริง
