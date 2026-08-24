# Documentation Discipline

- จดเฉพาะ decision, contract, operational context และ quirk ที่โค้ดเล่าเองไม่ได้; `CLAUDE.md`
  เป็น current state ไม่ใช่ changelog และประวัติอยู่ Git.
- Fact มี canonical owner เดียว ที่อื่นใช้ pointer. Claim ที่เปลี่ยนตาม environment/runtime ต้องเปิด
  authoritative owner/live source; root หรือเอกสารใกล้ตัวเป็น router ไม่ใช่หลักฐานแทน owner.
- Mutation ปัจจุบันทำให้ doc/memory stale ให้อัปเดตใน checkpoint เดียวกัน. Pre-existing/known/deferred
  ที่ไม่บล็อกให้ park ไม่ขยาย objective เป็น cleanup.
- Shared memory ที่ create/move/rename/delete ต้อง sync pointer + recall hook; edit เนื้อหาให้ตรวจว่า
  hook ยังตรง. Fact ถาวรมี status, provenance และ checked date.
- Private/sensitive data อยู่ `docs/private/` หรือ `memory/private/` ของ repo และต้อง gitignore;
  ห้าม index ลง shared memory หรือใช้ path เฉพาะเครื่องเป็น pointer ที่ commit.
- Comment เก็บ why/constraint หนึ่งบรรทัดพร้อม pointer. Narrative/history/detail ตั้งแต่ 2 บรรทัดอยู่
  project docs; public interface contract ใช้ docstring ตาม convention และต้องอ่านก่อนแก้/ทำซ้ำ symbol.
- บ้านของ fact, index หรือ topology ไม่ชัดให้ invoke `/docs:*` ที่ตรงก่อนจัดโครง; ห้าม cleanup เกิน scope.
