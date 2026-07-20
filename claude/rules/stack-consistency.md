# Stack Consistency & Shared Contracts

กันปัญหา "แต่ละส่วนของระบบใช้คนละเครื่องมือทั้งที่ใช้ร่วมกันได้"

> **Spirit ของ rule นี้: consistency เป็น default ไม่ใช่กรงขัง** — ถ้ามีวิธี/lib ที่ดีกว่า
> ของที่ใช้อยู่ **ให้เสนอ** พร้อมเหตุผล+แนวทาง migrate แล้วให้ user ตัดสิน
> สิ่งเดียวที่ไม่ควรทำคือ*เพิ่มความแตกต่างเงียบ ๆ* โดยไม่มีใครได้ตัดสินใจ

## ก่อนเพิ่ม dependency ใหม่ — เช็คก่อนเสมอ
- **มีของที่ทำหน้าที่เดียวกันใน workspace อยู่แล้วไหม?** ถ้ามี → default คือใช้ตัวเดิม
  สำหรับ concern เดียวกัน (validation, date, http client, state, styling)
- **คิดว่ามีตัวที่ดีกว่า?** → เสนอเปรียบเทียบ (ดีกว่ายังไง, ต้นทุน migrate, กระทบอะไร)
  ให้ user เลือก — ได้ไฟเขียวแล้วค่อย migrate ให้*ทั้ง workspace* ไม่ใช่ใช้ปนสองตัว
- ตัดสินใจแล้วว่าต่าง/เปลี่ยน → บันทึก decision + เหตุผลใน CLAUDE.md

## Shared contracts (FE ↔ BE ↔ bot/worker)
- **schema/validation เขียนครั้งเดียว แชร์ทุกฝั่ง** — เช่น zod schema อยู่ใน shared package
  (`packages/contracts` pattern) แล้วทั้ง API และ FE import ตัวเดียวกัน; อย่าปล่อยให้สองฝั่ง
  ใช้คนละ validation lib ทั้งที่ contract คือของชิ้นเดียวกัน — เจอแบบนี้ให้เสนอ consolidate
- **types = single source of truth** — generate/infer จาก schema หรือ DB schema เดียว
  (`z.infer`, Prisma types) ไม่เขียน type ซ้ำสองที่ให้ drift กัน
- enum/constant ที่สองฝั่งต้องตรงกัน (status, role, error code) → อยู่ใน shared package เท่านั้น

## ภายใน monorepo
- convention เดียวกันทุก package: error shape ของ API, การตั้งชื่อ, โครง folder,
  formatter/linter config ตัวเดียวที่ root
- utility ที่เขียนซ้ำเกิน 2 ที่ → ยกเข้า shared package

เจอความไม่สอดคล้องเดิม: ทัก+เสนอ consolidate — อย่าเพิ่มความต่างใหม่ตามของเดิมเงียบ ๆ
