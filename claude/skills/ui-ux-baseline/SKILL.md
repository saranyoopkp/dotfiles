---
name: ui-ux-baseline
description: Router สำหรับมาตรฐาน UI/UX/frontend ใช้ทันทีเมื่อวางแผน, ออกแบบ, review, สร้างหรือแก้ frontend component, หน้าจอ, layout, form, list/feed/chat, shared UI component, localization/i18n หรือไฟล์ .tsx/.jsx/.vue/.css แม้ยังไม่มีไฟล์จริงหรือผู้ใช้ขอเพียงแผน. ให้ map data flow และ user action แล้วอ่าน child skill ที่ตรง; interactive UI ต้องอ่าน ui-ux-baseline:interaction-a11y เสมอ
---

# UI/UX Baseline

ก่อนแก้ UI ให้ระบุว่าผู้ใช้กำลังดูข้อมูล, สั่งงาน, จัดการข้อมูลหลายรายการ, ติดตามข้อมูลตามเวลา, หรือใช้ shared primitive แล้วอ่าน child skill ที่ตรง **ก่อน** ออกแบบหรือเขียนโค้ด

| ลักษณะงาน | ต้องอ่าน |
|---|---|
| สร้างหน้า/landing page ใหม่, redesign visual identity หรือผู้ใช้ขอ direction ด้านภาพลักษณ์ | `ui-ux-baseline:visual-direction` |
| ปรับ Visual Design หรือ UI effect ของหน้าจอเดิม เช่น spacing, typography, shadow, blur, gradient, overlay โดยคง brand/flow เดิม | `ui-ux-baseline:visual-polish` |
| เพิ่มหรือแก้ transition, animation, progress, reveal, scroll behavior หรือ microinteraction | `ui-ux-baseline:motion-microinteractions` |
| สร้างหรือแก้ shared color/type/spacing/grid/theme/elevation/icon หรือ motion token | `ui-ux-baseline:design-foundations` |
| เลือก icon/icon library, สร้าง icon language หรือพบ decorative emoji ใน UI | `ui-ux-baseline:design-foundations` |
| i18n/localization, translation, locale formatting, text expansion หรือ RTL | `ui-ux-baseline:content-localization` |
| render resource จาก server/client state | `ui-ux-baseline:resource-states` |
| submit, edit, toggle, delete, confirm หรือ retry | `ui-ux-baseline:task-flows` |
| เลือกหรือแก้ toast, banner, inline error, alert, success/failure message หรือ recovery feedback | `ui-ux-baseline:feedback-notifications` |
| search, filter, sort, table/list, pagination, selection หรือ bulk action | `ui-ux-baseline:collections` |
| chat, feed, event stream, presence หรือข้อมูลที่เข้าตามเวลา | `ui-ux-baseline:realtime-conversation` |
| page layout, navigation, responsive/mobile hierarchy | `ui-ux-baseline:layout-navigation` |
| interactive element ทุกชนิด | `ui-ux-baseline:interaction-a11y` |
| สร้างหรือแก้ shared component, primitive หรือ variant | `ui-ux-baseline:design-system` |

งานเดียวอ่านได้หลาย child ตาม data flow จริง; ห้ามโหลดทั้งหมดเพียงเพื่อทำ checklist และห้ามข้าม child ที่ trigger ตรงเพียงเพราะ UI ดูเล็ก

หาก design ที่ขอมาขัดกับ constraint จาก child skill ให้สรุปผลกระทบและทางเลือกก่อนลงมือ ตาม behavioral-change gate ของโครงการ
