---
name: research
description: Router สำหรับ research ที่มีผลต่อการตัดสินใจด้าน software, security, dependency, technology/vendor, product, market หรือ user. ใช้เมื่อคำตอบต้องอาศัยข้อมูลปัจจุบันจากภายนอก, ตรวจ security advisory/CVE, เปรียบเทียบทางเลือกหรือ build-vs-buy, ตรวจ user/market evidence หรือควบคุม scope/budget/stopping criteria/source disagreement; ให้กำหนดคำถามวิจัยแล้วอ่าน child skill ที่ตรงก่อนสรุป
---

# Research

เริ่มจาก decision ที่ research ต้องช่วยตอบ ไม่ใช่เริ่มจากการสะสมลิงก์. ใช้ `research:research-control`
กับงานที่มีผลต่อ decision, ต้องใช้หลาย source หรือมีความไม่แน่นอน แล้วเลือก domain เพิ่ม:

| งาน | Skill |
|---|---|
| CVE, security advisory, affected version, exploit precondition หรือ remediation | `research:security-advisories` |
| dependency/technology/vendor, build-vs-buy, pricing, support, license หรือ lock-in | `research:technology-vendor` |
| product opportunity, market/competitor, user need, interview, survey หรือ usage evidence | `research:product-market-user` |
| กำหนด research question, source plan, appetite, stopping criteria หรือจัดการ source ขัดกัน | `research:research-control` |

หนึ่ง decision ใช้หลาย child ได้ แต่ห้ามคัด workflow ข้ามกันจนกลายเป็น checklist รวม.

## Shared contract

- ตรวจ task/repository/decision/runtime ก่อนเพื่อรู้ context และ version; external source ไม่พิสูจน์
  ว่า repo นี้ได้รับผลจนกว่าจะ map กลับมาที่ code/config/runtime หรือ user context
- ใช้ source ที่ใกล้ claim ที่สุดและเป็นปัจจุบัน; แยก official fact, independent evidence,
  inference และ unknown พร้อม source/checked date
- research เป็นข้อมูลสำหรับ decision ไม่ใช่ authorization ให้เลือก vendor, เปลี่ยน behavior,
  เพิ่ม dependency, upgrade, ซื้อบริการ หรือเก็บข้อมูลผู้ใช้เอง
- สรุปตาม Report-integrity gate: claim สำคัญ, evidence, applicability, limitation และสิ่งที่
  ยังไม่ยืนยัน; จำนวนลิงก์หรือความมั่นใจไม่แทนคุณภาพหลักฐาน
