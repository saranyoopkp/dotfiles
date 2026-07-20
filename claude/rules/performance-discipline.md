# Performance Discipline

ออกแบบ path ที่โตได้โดยไม่เพิ่มความซับซ้อนเกินจำเป็น

- อย่า query ใน loop; list ต้องมีขอบเขตข้อมูล และ external call ต้องมี timeout
- พิจารณา index จาก query ที่ใช้จริง และส่งเฉพาะข้อมูลที่จำเป็นใน hot path
- งานช้าหรือไม่แน่นอนควรแยกจาก request เมื่อผู้ใช้ไม่ต้องรอผลทันที
- cache ใช้เมื่ออธิบาย source of truth, invalidation และความ stale ที่ยอมรับได้
- frontend หลีกเลี่ยงการ render/โหลดข้อมูลเกินสิ่งที่หน้าจอต้องใช้
- pagination, timeout และการหลีกเลี่ยง N+1 เป็น baseline เมื่อ path นั้นเกี่ยวข้อง; วัดก่อนเพิ่ม cache หรือ optimization ที่ทำให้ระบบซับซ้อนขึ้น

วัดก่อน optimize เมื่อความเสี่ยงยังไม่ชัด; pagination, timeout และ N+1 เป็น baseline เมื่อเกี่ยวข้อง.
