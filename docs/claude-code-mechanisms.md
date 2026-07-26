# Claude Code — กลไก .claude/ ที่เกี่ยวกับ on-demand rules (research 2026-07-16)

> durable platform facts (version-gated) — กันขุดซ้ำ. ที่มา: docs `code.claude.com/docs`
> (claude-directory, skills.md) + claude-code-guide agent. verify จริงบางส่วนด้วย `claude -p`.
> ⚠️ platform เปลี่ยนตาม version — ระบุ version ที่รู้; เจอต่างจากนี้ = docs อัปเดตแล้ว

## กลไกโหลด instruction (always-on vs on-demand)

| กลไก | โหลดเมื่อ | หมายเหตุ |
|---|---|---|
| `CLAUDE.md`, `~/.claude/CLAUDE.md` | ทุก session | always |
| `~/.claude/rules/**/*.md` (ไม่มี `paths:`) | ทุก session | always — นี่คือ rules ปัจจุบัน |
| rule ที่มี `paths:` frontmatter (glob) | **เมื่อ Claude อ่านไฟล์ match glob** | ⚠️ **reload ทุก turn ที่แตะไฟล์** → แพงในโดเมน (verify จริง — user เจอเอง) |
| **skill description** (frontmatter) | ทุก session (thin, ใน skill listing) | = routing signal |
| **skill body** | **ตอน invoke (Skill tool)** | load-once, no pointer ← **กลไกที่เลือกใช้** |
| `@import` ใน CLAUDE.md (`@path`, `@~/...`) | launch (inline) | **ไม่ lazy** — expand เข้า context ทันที |
| nested `CLAUDE.md` (subdir) | เมื่ออ่านไฟล์ใน subdir นั้น | on-demand |

**สรุปที่ทดสอบแล้ว (ground-truth ผ่าน `claude -p` stream-json)**: skill = ตัวเดียวที่ให้
on-demand จริง (fresh + long-session invoke ผ่าน), no pointer (ไม่ fail-open), load-once
(ไม่แพงทุก turn แบบ `paths:`). ดู decision เต็มใน `dogfood-audit-2026-07-15.md`

## Skill grouping / namespacing

🔴 **nested dir แบบ documented ไม่ทำงานจริง (ground-truth 2026-07-17, v2.1.212)** —
`skills/<grp>/<sub>/SKILL.md` ไม่ถูก register (ทดสอบทั้งผ่าน junction และ dir จริง:
"Unknown skill" ทุกแบบ) — ซ้ำ class เดียวกับ FileChanged: documented แต่ harness ไม่ scan

**วิธีที่ใช้ได้จริง (ทดสอบผ่านครบ):** dir แบนระดับบนสุด + **ตั้ง frontmatter `name:` มี
colon ได้** (`name: docs:link`) → invoke `/docs:link` ทำงาน; บน repo เก็บโครงกลุ่มสวย ๆ ได้
(`claude/skills/docs/{setup,placement,link}`) แล้วสร้าง junction แบนรายตัว
(`~/.claude/skills/docs-link` → `.../docs/link` — ชื่อ dir ห้ามมี colon บน Windows)
+ root router junction (`docs` → `.../docs`) ให้ /docs ใช้เป็นเมนูเลือก sub
- **เกณฑ์ใช้**: skill เดี่ยวจน SKILL.md **เกิน ~200 บรรทัด + sub-concern ต่างชัด** → ค่อยแตก group;
  ต่ำกว่านั้น = โครงเผื่ออนาคต (ห้ามทำก่อนถึง)

## Path resolution (สำหรับ pointer ใน instruction)

- Read tool **expand `~`** ได้ (มักได้ — verify FOUND) แต่ **ไม่ expand `$HOME`/env var** (ERROR)
- ผ่าน junction/symlink ได้ (matching through symlink v2.1.207+)
- ⚠️ `~` เคย fail ใน long session ครั้งหนึ่ง (non-deterministic) — **อย่าพึ่ง pointer, ใช้ skill (harness โหลดให้)**
- ตัวแปรที่ harness substitute ใน skill: `${CLAUDE_SKILL_DIR}`, `${CLAUDE_PROJECT_DIR}`, `${CLAUDE_SESSION_ID}`, `${CLAUDE_EFFORT}`

## `claude -p` = fresh-session test bed

- fresh process โหลด `~/.claude/rules|skills` **สดจากไฟล์ปัจจุบัน** (subagent ทำไม่ได้ — สืบทอด context ค้าง)
- รันเป็น **agent จาก `settings.json`** (`--agent <name>` override; ชื่อผิด = fail loud list agents)
- **ยิงขนานได้** (scenario อิสระ → ยิงพร้อมกัน parse ทีหลัง; 87s vs 15-18min)
- **ground truth**: `--output-format stream-json --verbose` → ดู `tool_use` จริง ไม่ใช่ self-report+grep
- ⚠️ cwd ต้อง**นอก dotfiles** (ไม่งั้นโหลด dotfiles/CLAUDE.md ปน); **ห้ามแก้ script ที่รันอยู่** (bash อ่าน incremental)

## Taxonomy: rule ↔ skill (ตัดสิน 2026-07-16)

rule ย้ายเป็น skill เมื่อครบ**ทั้งสาม**: (ก) work type ประกาศตัวชัด (ข) miss แล้วกู้ได้
(ค) ลึก/จะลึกจริง — skills ปัจจุบันรวม `docs`, `ui-ux-baseline`, `data-design`, `api-design`,
`ops`, `greenfield-foundation`, `research`, `retro`, `performance`, `stack-contracts` และ
`testing-strategy`; ที่คง **always-on**:
money/authz/time (ฝังในงานอื่น + miss เจ็บถาวร) · `external-integration-safety` (**ทดลองย้ายแล้ว
revert** — เนื้อเป็นแนวทาง/bounded ไม่ลึกพอ) · cross-cutting rules (ใช้เกือบทุกงาน) ·
compatibility/documentation safety floor แบบสั้น · thin routing stub ของ domain ที่ miss แล้ว
เสีย baseline (`performance`, `stack-contracts`, `testing-strategy`) โดย procedure เต็มอยู่ใน skill
**ห้ามย้ายเพราะเพดาน 400 อย่างเดียว — depth คือเหตุผลจริง**

Growth path ของ skill เดี่ยว: แตกเป็น group เมื่อ SKILL.md เกิน ~200 บรรทัด + มี
sub-concern ต่างกันชัด (แต่ละ sub ได้ description/routing ของตัวเอง) — ต่ำกว่านั้น
ห้ามทำก่อนถึง (โครงเผื่ออนาคต = over-engineering); วิธี group จริงดู §grouping ด้านบน
(nested พัง → junction แบน + colon name)

## Current ownership map

ตารางนี้คือสถานะปัจจุบัน ไม่ใช่ changelog. `rules` เป็น safety floor ที่โหลดเสมอ,
`SCC` แปลง trigger เป็น action, `ACV` ตรวจผลแบบอิสระ และ skill เป็น procedure แบบ on-demand.
เรื่องเดียวกันข้ามชั้นได้เมื่อทำคนละหน้าที่เท่านั้น.

### Always-on rules

| Concern | Shared invariant owner | Agent behavior / on-demand procedure |
|---|---|---|
| หลักการทำงาน, pain/ข้อเสนอ, complexity, greenfield และ research floor | `claude/rules/core/operating-contract.md` | SCC เป็น behavior owner; procedure อยู่ใน `greenfield-foundation`, `research` และ `retro` |
| ความถูกต้องของ claim/report/durable finding | `claude/rules/core/evidence-integrity.md` | SCC รายงานด้วยหลักฐาน; ACV ตรวจ acceptance evidence อิสระ |
| intent, behavioral change, refactor, instruction-system change และ task tracking | `claude/rules/core/change-control.md` | SCC เป็น behavior owner; ACV ตรวจ authorization และ observable behavior |
| compatibility และ rollout | `claude/rules/engineering/compatibility-rollout.md` | SCC route ไป `api-design:evolution`, `data-design:schema-migrations`, `ops:infra-change`; ACV ตรวจผลที่อนุมัติ |
| docs/memory safety floor | `claude/rules/engineering/documentation-discipline.md` | SCC route ไป `docs`; child skill เป็น owner ของ placement/setup/link/stale/workspace |
| performance safety floor | `claude/rules/engineering/performance-discipline.md` | SCC route ไป `performance` |
| shared dependency/contract safety floor | `claude/rules/engineering/stack-contracts.md` | SCC route ไป `stack-contracts`; technology choice ใช้ `research:technology-vendor` ร่วม |
| test-evidence safety floor | `claude/rules/engineering/testing-strategy.md` | SCC route ไป `testing-strategy`; ACV เป็น independent acceptance oracle |
| authorization และ tenant isolation | `claude/rules/risk/authz-multitenancy.md` | rule เป็น owner ของ safety floor; procedure เฉพาะ domain อยู่ใน skill ที่งานนั้น route เข้า |
| external integration safety | `claude/rules/risk/external-integration-safety.md` | rule เป็น owner ของ safety floor; API/data/ops skill เติม procedure ตาม surface |
| money correctness | `claude/rules/risk/money-handling.md` | rule เป็น owner ของ safety floor; API/data skill เติม contract/transaction procedure |
| production recovery | `claude/rules/risk/production-recovery.md` | rule เป็น owner ของ safety floor; `ops:incident-response`, `ops:observability`, `ops:infra-change` เติม procedure |
| time/timezone correctness | `claude/rules/risk/time-timezone.md` | rule เป็น owner ของ safety floor; API/data/UI skill เติม procedure ตาม boundary |

### On-demand skill entry points

| Domain | Entry-point owner | Routing source |
|---|---|---|
| API contract และ evolution | `claude/skills/api-design/SKILL.md` | description ของ router + child routing ใน body; compatibility route จาก SCC |
| Data model, lifecycle และ consistency | `claude/skills/data-design/SKILL.md` | description ของ router + child routing ใน body |
| Documentation และ memory | `claude/skills/docs/SKILL.md` | description ของ router + child routing ใน body; SCC มี docs trigger |
| Greenfield foundation | `claude/skills/greenfield-foundation/SKILL.md` | description + SCC greenfield trigger |
| Operations และ infrastructure | `claude/skills/ops/SKILL.md` | description ของ router + child routing ใน body |
| Performance | `claude/skills/performance/SKILL.md` | description + thin rule + SCC trigger |
| Research | `claude/skills/research/SKILL.md` | description ของ router + child routing ใน body; SCC มี research triggers |
| Session feedback | `claude/skills/retro/SKILL.md` | description; read-only by default |
| Shared stack/contracts | `claude/skills/stack-contracts/SKILL.md` | description + thin rule + SCC trigger |
| Testing strategy | `claude/skills/testing-strategy/SKILL.md` | description + thin rule + SCC trigger |
| UI/UX/frontend | `claude/skills/ui-ux-baseline/SKILL.md` | description ของ router + child routing ใน body |

### Map maintenance and change traceability

- map นี้ต้องมี rule ทุกไฟล์และ top-level skill entry point ทุกตัว; child skill ทุกตัวต้องถูก route
  จาก parent `SKILL.md` โดยชื่อจริง
- ก่อนแก้หลาย owner หรือย้าย routing ให้แสดง impact map
  `คงไว้ | ย้าย old → new | เปลี่ยน behavior | ถอดออก | ยังไม่ยืนยัน`; หลังแก้ reconcile
  กับ diff จริงและใส่สรุปเดียวกันใน commit/PR
- structural move กับ semantic change แยกกันเมื่อทำได้. ของที่ย้ายต้องบอก destination และ
  routing ต้นทาง→ปลายทาง; ของที่ถอดต้องบอกเหตุผลและ replacement
- `test/config/verify-guardrails.sh` ตรวจ structural coverage และ key invariant เท่านั้น;
  ไม่พิสูจน์ semantic equivalence. ผู้แก้ยังต้องเทียบ impact map, diff และ targeted behavior test
- ประวัติใช้ Git; ห้ามเติม historical ledger ใน map นี้ เพราะจะสร้าง source of truth ซ้ำ

Regression หลังแก้ skill/description: `test/routing/run.sh`
