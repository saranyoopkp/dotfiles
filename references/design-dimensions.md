# Dimension Sweep — "when A, then maybe B"

เครื่องมือคิดตอนออกแบบ feature: กวาดทุกมิติ แล้ว**ตัดสินใจ**ต่อมิติ — คำตอบต้องห้าม
คือ "ไม่เคยคิดถึง" คำตัดสินมี 4 แบบ ชะตากรรมต่างกัน:

| คำตัดสิน | ความหมาย | ต้องทำอะไร |
|---|---|---|
| **ทำเลย** | อยู่ใน scope ปัจจุบัน | implement |
| **เผื่อโครง** | ยังไม่ทำ แต่ schema/interface รองรับ | type field, nullable ref, enum ขยายได้ — **code อย่าเผื่อ schema เผื่อได้** |
| **เลื่อน** (ยังไม่ใช่ตอนนี้) | อนาคตยังไงก็ต้องทำ แค่ไม่ใช่วันนี้ | จดลง **Future boundaries** ใน CLAUDE.md + เช็คว่า design วันนี้ไม่ block มัน |
| **ตัดถาวร** | ขัด mission/constraint | จดเหตุผลหนึ่งบรรทัด กัน re-litigate |

> เส้นแบ่ง "เลื่อน" vs "ตัดถาวร" สำคัญที่สุด: ของที่เลื่อน**จะวนกลับมา** — ถ้าไม่มีบ้าน
> ให้รอ (Future boundaries) มันจะกลับมาแบบ surprise แล้วชน design ที่ block มันไว้;
> ถ้ามองแล้วว่ายังไงก็ต้องทำ อย่างน้อยที่สุดต้องผ่านเกณฑ์ "design วันนี้ไม่ปิดประตู"
> YAGNI ยังศักดิ์สิทธิ์สำหรับ *code* — แต่ไม่ใช่ข้ออ้างให้ *schema/boundary* ปิดตาย

## มิติมาตรฐาน (กวาดตามนี้)

| มิติ | คำถาม trigger | ตัวอย่าง (message inbox) |
|---|---|---|
| **Content type** | รับแค่แบบเดียวหรือหลายแบบ? | text → media, ไฟล์, voice, sticker, link preview |
| **Cardinality** | 1 → หลาย → หมื่น? | 1 แชท → หลาย tab → pagination/virtualize |
| **Actor** | ใครใช้ได้อีก? | user → หลาย role, guest, bot, ระบบอื่นผ่าน API |
| **Direction** | อ่านอย่างเดียวหรือครบวงจร? | รับ → ตอบ → แก้ → ลบ → undo → forward |
| **Time** | เฉพาะตอนนี้ หรือมีอดีต/อนาคต? | realtime → history, ค้นหา, ตั้งเวลา ส่ง, หมดอายุ, audit |
| **State** | นอกจาก happy path? | loading/empty/error/partial → offline, draft, retry |
| **Sync** | เครื่องเดียวหรือหลายจุด? | 1 จอ → หลาย device, หลาย agent ตอบพร้อมกัน, conflict |
| **Locale** | ภาษา/สกุล/เขตเวลาเดียว? | ไทย → i18n, หลายสกุลเงิน, timezone ลูกค้า |
| **Scale/Failure** | ถ้า 100 เท่า / ถ้าพัง? | provider ล่ม, ส่งซ้ำ, burst, rate limit |
| **Permission** | ใครเห็น/ทำอะไรได้? | ทุกคนเห็นหมด → per-role, per-tenant, per-conversation |
| **Lifecycle** | เกิด-แก่-เจ็บ-ตาย ของ data? | สร้าง → archive → export → ลบจริง (PDPA) |
| **Integration** | อยู่เดี่ยวหรือเชื่อมต่อ? | manual → import/export, API, webhook ออก, embed |

## วิธีใช้

1. ก่อนลง schema/API ของ feature ใหม่ → กวาดตาราง 1 รอบ (~5 นาที)
2. "เผื่อโครง" → สะท้อนใน schema ตั้งแต่แรก / "เลื่อน" → Future boundaries + เช็คไม่ block
   / "ตัดถาวร" → จดเหตุผล
3. requirement จาก user มักเล่าแค่ happy path มิติเดียว — sweep นี้คือคำถามที่ควรถามกลับ
4. ทุกครั้งที่หยิบของจาก Future boundaries มาทำจริง → ตรวจว่า assumption ตอนจดยังจริงไหม
   ก่อนลงมือ (ของที่รอนานความจริงรอบตัวมันเปลี่ยน)

## เพิ่มมิติใหม่เมื่อไหร่

เจอเหตุการณ์ "ลืมคิด" ที่ retrofit แพงจริง → เพิ่มแถวในตาราง (ที่มาเดียวกับ rules:
กลั่นจากแผล ไม่ใช่เผื่อ)
