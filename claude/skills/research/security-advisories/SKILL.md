---
name: research:security-advisories
description: ตรวจ advisory/CVE/vulnerability, affected/fixed version, precondition, transitive path และ remediation ปัจจุบัน. ใช้กับ alert/audit/upgrade หรือ claim ว่า repo affected/safe; map กลับ exact version และ reachable deployment
---

# Security Advisories

ใช้ `research:research-control` เมื่อมีหลาย advisory, หลาย component หรือผลตรวจจะนำไปสู่
upgrade/mitigation ที่มี compatibility risk.

1. Inventory ตัวตนจริงก่อน: ecosystem, package/product, exact resolved version, dependency path,
   OS/image/runtime, deployment และ feature/code path ที่เกี่ยวข้อง. ชื่อคล้ายกันไม่ใช่ artifact เดียวกัน
2. ตรวจ source ปัจจุบันตามลำดับ claim: vendor/project advisory และ fixed release,
   authoritative CVE record, ecosystem advisory database แล้วจึงใช้ scanner/secondary source
   เป็น lead. เก็บ advisory ID, affected range, fixed range, publication/update date และ checked date
3. แยก `present → affected version → vulnerable configuration/precondition → reachable/exposed`.
   package มีอยู่หรือ scanner match ไม่ได้พิสูจน์ว่า exploit path ใช้งานได้; unreachable ก็ไม่ทำให้
   advisory หายไป ต้องรายงาน residual risk
4. ตรวจ backport, distro/vendor patch, fork, alias, transitive resolution และ runtime flag จาก
   source ของผู้ดูแลจริง; เปรียบเทียบ version string อย่างเดียวอาจให้ผลผิด
5. ประเมินผลกระทบจาก confidentiality/integrity/availability, privilege, exposure, exploit maturity
   และข้อมูลของ repo; CVSS/severity label เป็น input ไม่ใช่ verdict
6. เสนอ remediation เป็นลำดับ: fixed compatible version, configuration/feature mitigation,
   exposure reduction หรือ compensating control พร้อม compatibility, rollout และ rollback risk.
   Research ไม่ใช่ authorization ให้อัปเกรดหรือเปลี่ยน behavior

ส่งมอบต่อ advisory เป็น `Affected / Not affected / Unknown` พร้อม component/version/path,
precondition/reachability, source + checked date, probe และ remediation/residual risk.
ห้ามใช้ audit exit code อย่างเดียวรับรองว่า “ปลอดภัย”.
