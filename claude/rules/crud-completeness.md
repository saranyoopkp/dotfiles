# Resource Completeness

เมื่อเพิ่ม resource ที่ผู้ใช้จัดการได้ ให้ตัดสินใจอย่างตั้งใจว่า operation ใดมี: list, detail, create, update และ delete/retire. ไม่ต้องมีครบทุก operation แต่สิ่งที่ไม่มีต้องสอดคล้องกับ requirement และ lifecycle ของข้อมูล

- list ที่โตได้ต้องมีขอบเขตข้อมูล เช่น pagination, limit หรือ filter
- write ทุกชนิดมี validation, authorization และนิยาม field ที่แก้ได้
- การลบต้องระบุผลต่อข้อมูลสัมพันธ์และ retention; ใช้ soft delete เมื่อการกู้คืนหรือ audit จำเป็น
- action ที่ส่งผลข้างเคียงต้องทนต่อ double-submit/retry

รายละเอียดของ HTTP contract ใช้ skill `api-design`; เรื่องสิทธิ์ใช้ rule `authz-multitenancy`.
