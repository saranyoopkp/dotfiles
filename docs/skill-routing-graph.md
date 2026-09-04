# Agent and Skill Routing Graph

Skill routing is a graph rather than a strict tree. One task may invoke several families when work surfaces or decisions cross domains. This document covers skill routing only; agent and session selection is a manual user decision outside this graph.

Solid edges represent primary or parent routing; dashed edges represent cross-domain triggers that may co-load. `ui-ux-baseline` is the generic quality baseline and shared lens for UI, UX, and frontend work. Usability, accessibility, information hierarchy, content clarity, responsive behavior, and visual consistency route there. Open-ended aesthetic direction and requests to make an existing page more beautiful route to `visual-direction`; clean-up and polish preserving the current direction route to `visual-polish`. Child edges identify on-demand owners of specialized procedures.

```mermaid
flowchart LR
    REQ["User request / current task"]
    SCC["SCC-v1.0.1"]
    REQ -->|Primary implementation agent| SCC

    SCC -->|Frontend, page, component, table| UI
    SCC -->|HTTP endpoint or public contract| API
    SCC -->|Schema, transaction, cache, queue| DATA
    SCC -->|Auth, money, integration, production| RISK
    SCC -->|Infrastructure or reliability| OPS
    SCC -->|Current external evidence| RESEARCH
    SCC -->|Documentation system| DOCS
    SCC -->|New project or foundation| GREENFIELD
    SCC -->|Measured performance concern| PERFORMANCE
    SCC -->|Dependency or shared contract| STACK
    SCC -->|Test design or coverage gap| TESTING
    SCC -->|Agent/session feedback| RETRO

    subgraph UI_FAMILY["UI / UX"]
        UI["ui-ux-baseline"]
        UI -->|Table, list, search, filter, bulk| UI_COLLECTIONS["ui-ux-baseline:collections"]
        UI -->|Create, edit, toggle, delete, retry| UI_FLOWS["ui-ux-baseline:task-flows"]
        UI -->|Loading, empty, error, stale| UI_STATES["ui-ux-baseline:resource-states"]
        UI -->|Button, input, menu, dialog| UI_A11Y["ui-ux-baseline:interaction-a11y"]
        UI -->|Page, route, shell, navigation state, responsive| UI_LAYOUT["ui-ux-baseline:layout-navigation"]
        UI -->|Toast, banner, result, recovery| UI_FEEDBACK["ui-ux-baseline:feedback-notifications"]
        UI -->|Shared component or variant| UI_SYSTEM["ui-ux-baseline:design-system"]
        UI -->|Shared token, theme, icon| UI_FOUNDATION["ui-ux-baseline:design-foundations"]
        UI -->|New identity, redesign, or aesthetic direction| UI_DIRECTION["ui-ux-baseline:visual-direction"]
        UI -->|Clean/polish existing screen| UI_POLISH["ui-ux-baseline:visual-polish"]
        UI -->|Animation or transition| UI_MOTION["ui-ux-baseline:motion-microinteractions"]
        UI -->|i18n, locale, RTL| UI_I18N["ui-ux-baseline:content-localization"]
        UI -->|Labels, headings, actions, helper text| UI_COPY["ui-ux-baseline:content-copy"]
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
        DOCS -->|Choose knowledge owner, organize docs topology, or audit comments| DOCS_PLACEMENT["docs:placement"]
        DOCS -->|Broken reference| DOCS_LINK["docs:link"]
        DOCS -->|Content contradicts live code| DOCS_STALE["docs:stale"]
    end

    GREENFIELD["greenfield-foundation"]
    PERFORMANCE["performance"]
    STACK["stack-contracts"]
    subgraph TESTING_FAMILY["Testing strategy"]
        TESTING["testing-strategy"]
        TESTING -->|State, time, retry, recovery, concurrency| TEST_BEHAVIOR["testing-strategy:behavior-boundaries"]
        TESTING -->|Validation, partitions, input boundaries| TEST_INPUT["testing-strategy:input-domains"]
    end
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
    API_EVOLUTION -.->|Affected frontend consumer| UI
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

Requests enter through the primary SCC role, which classifies triggers and routes to relevant skills:

1. **Surface trigger:** which UI, API, data, operations, or documentation surface is affected?
2. **Decision trigger:** does the task require a specialized decision such as pagination, mutation, migration, or permissions?
3. **Risk trigger:** does it cross authentication or tenancy, money, production, external, or irreversible boundaries?

Skill families do not activate from keywords alone. Mentioning `RBAC` while fixing a prose typo should not invoke `risk-review`, while designing or changing role and permission behavior must invoke the authorization reference.

## Verification

```bash
python3 test/config/verify-skill-routing-graph.py --self-test
```

The validator checks that every skill has exactly one node, each top-level skill routes from `SCC`, nested skills have parent-child edges and appear in their parent router, every edge targets a declared node, and relative `SKILL.md` references resolve. `--self-test` temporarily removes one skill edge and `SCC → ACV`, confirming expected failure. Cross-domain semantics and trigger recognition still require separate `test/routing/run.sh` evidence.
