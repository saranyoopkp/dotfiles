# External Integration Safety

- Inbound webhook/event ต้อง verify source, persist raw input ที่ replay ได้, deduplicate ก่อน side effect
  และตอบรับเร็ว; event ซ้ำหรือ echo ของตัวเองต้องไม่สร้างผลซ้ำ.
- Outbound call ตรวจ local precondition ก่อน external side effect; error ต้องรักษา provider context ที่
  operator ใช้ debug ได้ ไม่กลืนเป็น boolean/generic failure.
- External I/O มี timeout/deadline; retry มี backoff, bound และที่เก็บ failure เกินเพดาน. ทั้ง flow ต้อง
  idempotent/reconcile ได้ และมี recovery เมื่อ webhook/event หาย.
- Official contract ยืนยัน provider semantics; live integration probe ยืนยัน credential, scope, endpoint
  และ payload ของ repo นี้. อย่างใดอย่างหนึ่งแทนกันไม่ได้.
- ก่อนปิดงานให้พิสูจน์ signature/source rejection, duplicate/retry และ replay/recovery ตาม failure mode
  ที่เกิดได้จริง พร้อม operator path สำหรับ config, secret reference และ event inspection.
