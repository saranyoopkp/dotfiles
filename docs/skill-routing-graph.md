# Skill Routing Graph

Skill routing เป็น graph ไม่ใช่ strict tree: งานหนึ่งอาจ invoke หลาย family พร้อมกันเมื่อมี
work surface หรือ decision ข้าม domain. เส้นทึบคือ parent → child routing; เส้นประคือ
cross-domain trigger ที่อาจโหลดร่วมกัน.

```mermaid
flowchart LR
    REQ["User request / current task"]

    REQ -->|Frontend, page, component, table| UI
    REQ -->|HTTP endpoint or public contract| API
    REQ -->|Schema, transaction, cache, queue| DATA
    REQ -->|Auth, money, integration, production| RISK
    REQ -->|Infrastructure or reliability| OPS
    REQ -->|Current external evidence| RESEARCH
    REQ -->|Documentation system| DOCS
    REQ -->|New project or foundation| GREENFIELD
    REQ -->|Measured performance concern| PERFORMANCE
    REQ -->|Dependency or shared contract| STACK
    REQ -->|Test design or coverage gap| TESTING
    REQ -->|Agent/session feedback| RETRO

    subgraph UI_FAMILY["UI / UX"]
        UI["ui-ux-baseline"]
        UI -->|Table, list, search, filter, bulk| UI_COLLECTIONS["ui-ux-baseline:collections"]
        UI -->|Create, edit, toggle, delete, retry| UI_FLOWS["ui-ux-baseline:task-flows"]
        UI -->|Loading, empty, error, stale| UI_STATES["ui-ux-baseline:resource-states"]
        UI -->|Button, input, menu, dialog| UI_A11Y["ui-ux-baseline:interaction-a11y"]
        UI -->|Page, route, shell, responsive| UI_LAYOUT["ui-ux-baseline:layout-navigation"]
        UI -->|Toast, banner, result, recovery| UI_FEEDBACK["ui-ux-baseline:feedback-notifications"]
        UI -->|Shared component or variant| UI_SYSTEM["ui-ux-baseline:design-system"]
        UI -->|Shared token, theme, icon| UI_FOUNDATION["ui-ux-baseline:design-foundations"]
        UI -->|New identity or redesign| UI_DIRECTION["ui-ux-baseline:visual-direction"]
        UI -->|Polish existing screen| UI_POLISH["ui-ux-baseline:visual-polish"]
        UI -->|Animation or transition| UI_MOTION["ui-ux-baseline:motion-microinteractions"]
        UI -->|i18n, locale, RTL| UI_I18N["ui-ux-baseline:content-localization"]
        UI -->|Chat, feed, live stream| UI_REALTIME["ui-ux-baseline:realtime-conversation"]
    end

    subgraph API_FAMILY["HTTP / REST API"]
        API["api-design"]
        API -->|New endpoint or request/response| API_CORE["api-design:contract-core"]
        API -->|List, filter, sort, pagination| API_COLLECTIONS["api-design:collections"]
        API -->|POST, PUT, PATCH, DELETE| API_MUTATIONS["api-design:mutations"]
        API -->|4xx, 5xx, validation| API_ERRORS["api-design:errors"]
        API -->|202, job, import, export| API_ASYNC["api-design:async-operations"]
        API -->|ETag, 304, stale write| API_CACHE["api-design:caching-concurrency"]
        API -->|Compatibility or deprecation| API_EVOLUTION["api-design:evolution"]
    end

    subgraph DATA_FAMILY["Data layer"]
        DATA["data-design"]
        DATA -->|Table, column, index, backfill| DATA_SCHEMA["data-design:schema-migrations"]
        DATA -->|Atomicity, race, lock, outbox| DATA_TX["data-design:transactions-invariants"]
        DATA -->|Key, TTL, invalidation| DATA_CACHE["data-design:caching"]
        DATA -->|Queue, worker, sync, replay| DATA_ASYNC["data-design:async-dataflow"]
        DATA -->|Retention, delete, PII, audit| DATA_LIFECYCLE["data-design:lifecycle-governance"]
    end

    subgraph RISK_FAMILY["Risk boundaries"]
        RISK["risk-review"]
        RISK -->|Role, permission, tenant| RISK_AUTH["authorization reference"]
        RISK -->|Amount, currency, timezone| RISK_MONEY["money-time reference"]
        RISK -->|Webhook, OAuth, provider| RISK_EXTERNAL["external-integrations reference"]
        RISK -->|Secret, PII, deploy, recovery| RISK_PRODUCTION["production reference"]
    end

    subgraph OPS_FAMILY["Operations"]
        OPS["ops"]
        OPS -->|Outage or degradation| OPS_INCIDENT["ops:incident-response"]
        OPS -->|Logs, metrics, traces, alerts| OPS_OBSERVE["ops:observability"]
        OPS -->|IaC, cloud, IAM, resource| OPS_INFRA["ops:infra-change"]
    end

    subgraph RESEARCH_FAMILY["Research"]
        RESEARCH["research"]
        RESEARCH -->|CVE or vulnerability| RES_SECURITY["research:security-advisories"]
        RESEARCH -->|Dependency or vendor choice| RES_VENDOR["research:technology-vendor"]
        RESEARCH -->|User, market, competitor| RES_PRODUCT["research:product-market-user"]
        RESEARCH -->|Broad or uncertain research| RES_CONTROL["research:research-control"]
    end

    subgraph DOCS_FAMILY["Documentation"]
        DOCS["docs"]
        DOCS -->|Initialize documentation system| DOCS_SETUP["docs:setup"]
        DOCS -->|Multiple independent repos| DOCS_WORKSPACE["docs:workspace"]
        DOCS -->|Choose knowledge owner| DOCS_PLACEMENT["docs:placement"]
        DOCS -->|Broken reference| DOCS_LINK["docs:link"]
        DOCS -->|Content contradicts live code| DOCS_STALE["docs:stale"]
    end

    GREENFIELD["greenfield-foundation"]
    PERFORMANCE["performance"]
    STACK["stack-contracts"]
    TESTING["testing-strategy"]
    RETRO["retro"]

    UI_COLLECTIONS -.->|Management actions require API work| API
    UI_FLOWS -.->|Mutation contract changes| API_MUTATIONS
    UI_STATES -.->|Resource contract changes| API
    UI_REALTIME -.->|Queue or event flow| DATA_ASYNC
    UI -.->|RBAC or tenant UI| RISK_AUTH
    API -.->|Auth, money, external side effect| RISK
    DATA -.->|PII, destructive lifecycle| RISK
    OPS -.->|Production boundary| RISK_PRODUCTION
    API_MUTATIONS -.->|Transaction or race| DATA_TX
    API_EVOLUTION -.->|Persisted shape changes| DATA_SCHEMA
    DATA_CACHE -.->|Measured latency concern| PERFORMANCE
    UI_COLLECTIONS -.->|Measured rendering concern| PERFORMANCE
    API -.->|Test design unclear| TESTING
    DATA -.->|Invariant or migration test| TESTING
    RISK_AUTH -.->|Role and tenant matrix| TESTING
    API -.->|Shared schema or enum| STACK
    DATA -.->|Shared contract| STACK
    STACK -.->|Dependency comparison| RES_VENDOR
```

## Trigger model

1. **Surface trigger** — งานกำลังแตะ UI, API, data, operations หรือ documentation surface ใด
2. **Decision trigger** — มี decision เฉพาะด้าน เช่น pagination, mutation, migration หรือ permission หรือไม่
3. **Risk trigger** — งานข้าม auth/tenant, money, production, external หรือ irreversible boundary หรือไม่

Skill family ไม่ได้ถูก invoke จาก keyword อย่างเดียว. ตัวอย่าง `RBAC` ใน prose ที่แก้ typo ไม่ควร
invoke `risk-review`; แต่การออกแบบหรือเปลี่ยน role/permission behavior ต้อง invoke authorization reference.

## Verification

```bash
python3 test/config/verify-skill-routing-graph.py --self-test
```

Validator ตรวจว่า skill ทุกตัวมี node เดียว, top-level skill reachable จาก `REQ`, nested skill มี
parent-child edge และถูกกล่าวถึงใน parent router, graph edge ทุกเส้นชี้ node ที่ประกาศแล้ว และ relative
reference ใน `SKILL.md` มีปลายทางจริง. `--self-test` จะตัด edge ชั่วคราวและยืนยันว่า validator fail
ตามที่คาด. Cross-domain semantics และ trigger recognition ยังต้องพิสูจน์ด้วย
`test/routing/run.sh` แยกต่างหาก.
