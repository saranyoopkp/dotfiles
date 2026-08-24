# Money Handling

- เก็บและคำนวณเงินด้วย Decimal หรือ integer หน่วยย่อย ไม่ใช้ binary float; amount ต้องมี currency.
- FX conversion บันทึก rate/source/time กับ transaction; ห้ามคำนวณอดีตด้วย rate ปัจจุบัน.
- กำหนด rounding policy และจุดปัดที่ owner เดียว. Split/allocation ต้อง reconcile กลับยอดต้นฉบับเป๊ะ.
- สูตรเงิน ภาษี fee และ allocation มี independent oracle/ตัวเลขคำนวณมือ ครอบ zero, minimum และ boundary.
- Money mutation ต้อง idempotent, trace กลับรายการต้นทางได้ และ privileged adjustment มี actor/action/
  amount/time audit โดยไม่เปิดเผยข้อมูลเกินจำเป็น.
