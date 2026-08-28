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

rule คงอยู่เมื่อเป็น invariant ที่ต้องเห็นก่อนจำแนก domain และ miss แล้วเกิดความเสียหายที่กู้ยาก.
รายละเอียดที่ผูกกับ work surface, stage หรือ decision เฉพาะงานอยู่ใน skill แม้เป็น domain เสี่ยง;
always-on เก็บ risk classifier สั้น ๆ แล้ว route ไป `risk-review`. Skills ปัจจุบันรวม `docs`,
`ui-ux-baseline`, `data-design`, `api-design`, `ops`, `greenfield-foundation`, `research`, `retro`,
`performance`, `stack-contracts`, `testing-strategy` และ `risk-review`.

Growth path ของ skill เดี่ยว: แตกเป็น group เมื่อ SKILL.md เกิน ~200 บรรทัด + มี
sub-concern ต่างกันชัด (แต่ละ sub ได้ description/routing ของตัวเอง) — ต่ำกว่านั้น
ห้ามทำก่อนถึง (โครงเผื่ออนาคต = over-engineering); วิธี group จริงดู §grouping ด้านบน
(nested พัง → junction แบน + colon name)

## Current ownership map

ตารางนี้คือสถานะปัจจุบัน ไม่ใช่ changelog. `rules` เป็น safety floor ที่โหลดเสมอ,
`SCC` แปลง trigger เป็น action, `ACV` ตรวจผลแบบอิสระ และ skill เป็น procedure แบบ on-demand.
เรื่องเดียวกันข้ามชั้นได้เมื่อทำคนละหน้าที่เท่านั้น.

### Agent execution topology

role ใน repository (`SCC`, `Scout`, `ACV`) แยกจาก topology ที่ Claude Code ใช้รันงาน. เกณฑ์เลือก
และ delegation packet อยู่ที่ [`references/agent-orchestration.md`](../references/agent-orchestration.md).
`subagent`/fork/team/background session จัด context หรือ coordination; `worktree` จัด file/branch
isolation และไม่ใช่ role ใหม่. การเปลี่ยน topology ไม่เปลี่ยน owner ของ objective หรือ acceptance:
SCC ยังต้องสังเคราะห์และตรวจผล ส่วน ACV ยังเป็นผู้ตรวจอิสระเมื่อเข้า acceptance trigger.

Coordinator ต้องกำหนด foundation ของงานใหญ่ก่อน fan-out เพื่อให้ slices มี boundary และ context
พอดี. ค่า `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH=1` ใน docs setup kit ปิดการ redispatch จาก worker
แต่ยังให้ Coordinator สร้าง worker ระดับบนสุดได้. การต่อเนื่องของงานใช้ `SendMessage` กับ agent เดิม
เมื่อ continuity ตรงกัน; เรื่องที่เพียงเกี่ยวข้องกันให้สร้าง context ใหม่.

### Always-on rules

| Concern | Shared invariant owner | Agent behavior / on-demand procedure |
|---|---|---|
| หลักการทำงาน, material proposal/pain, complexity, greenfield และ research floor | `claude/rules/core/operating-contract.md` | SCC เป็น behavior owner; procedure อยู่ใน `greenfield-foundation`, `research` และ `retro` |
| ความถูกต้องของ claim/report/durable finding | `claude/rules/core/evidence-integrity.md` | SCC รายงานด้วยหลักฐาน; ACV ตรวจ acceptance evidence อิสระ |
| intent, objective continuity/detour, behavioral change, refactor, instruction-system change และ task tracking | `claude/rules/core/change-control.md` | SCC เป็น behavior owner; ACV ตรวจ authorization และ observable behavior |
| compatibility และ rollout | `claude/rules/engineering/compatibility-rollout.md` | SCC route ไป `api-design:evolution`, `data-design:schema-migrations`, `ops:infra-change`; ACV ตรวจผลที่อนุมัติ |
| docs/memory safety floor | `claude/rules/engineering/documentation-discipline.md` | SCC route ไป `docs`; child skill เป็น owner ของ placement/setup/link/stale/workspace |
| test evidence, performance และ shared contracts | core evidence/operating invariants | SCC route ไป `testing-strategy`, `performance` หรือ `stack-contracts` เมื่อมี decision ที่ตรง |
| auth, tenant, money, time, integration, production และ destructive boundaries | `claude/rules/risk/risk-boundaries.md` | `risk-review` โหลดเฉพาะ reference ที่ตรงกับ active surface |

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
| Behavioral signals/surprise, session feedback, objective loss และ attention drift | `claude/skills/retro/SKILL.md` | description; read-only by default; runtime continuity อยู่ใน `change-control` + SCC ไม่ใช่ skill |
| Shared stack/contracts | `claude/skills/stack-contracts/SKILL.md` | description + thin rule + SCC trigger |
| Testing strategy | `claude/skills/testing-strategy/SKILL.md` | description + SCC trigger |
| UI/UX/frontend | `claude/skills/ui-ux-baseline/SKILL.md` | description ของ router + child routing ใน body |
| Risk-domain procedure | `claude/skills/risk-review/SKILL.md` | thin risk boundary rule + SCC trigger; references โหลดตาม active surface |

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
