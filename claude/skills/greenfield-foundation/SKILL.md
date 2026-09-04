---
name: greenfield-foundation
description: Establish foundations for a new software project, application, service, package, or repository. Use when starting from zero, scaffolding, selecting architecture, stack, runtime, framework, or database, or defining the first baseline without an active implementation or contract. Always verify current official support lifecycle and compatibility across the version chain before selecting or creating.
---

# Greenfield Foundation

Use `verify scope → discover constraints → verify version chain → obtain decisions → build a vertical slice → verify`.
Greenfield work allows more choice but does not authorize guessed requirements or speculative architecture.

## 1. Verify greenfield status

- Inspect task, repository, decisions, contracts, entry points, and accessible runtime. One empty search does not prove no prior system exists.
- Distinguish a new system from a new component in brownfield. Existing consumers, contracts, data, deployments, and conventions create compatibility boundaries.
- Separate verified facts, inference, and assumptions. Lack of precedent does not authorize product behavior, stack, cost, or irreversible architecture.

## 2. Discover before asking

First gather available outcomes and users, project stage and maintenance horizon, target environment and deployment,
data sensitivity, integrations, budget and operational constraints, and prior user decisions. Ask only for decisions
that materially change behavior, security, cost, compatibility, or scope. Define the problem boundary and minimum
end-to-end outcome before choosing a framework.

## 3. LTS and compatibility gate — required for every greenfield project

Before proposing or pinning a runtime, framework, database, compiler, build tool, SDK, or deployment platform:

1. Check current primary sources for official releases and support policy, LTS schedules, end of life, compatibility matrices, and major-version migration notes.
2. If the ecosystem has no official LTS designation, say so and select a stable supported release from its policy. Never infer LTS from familiarity.
3. Verify the actual chain: OS and architecture → runtime → package manager/compiler/build → framework → driver/SDK → database/service → deployment platform.
4. Compare support windows with the maintenance horizon. “Latest” and “LTS” alone are insufficient, and a near-EOL LTS may provide less runway.
5. Preview, RC, nightly, EOL, or unsupported combinations require risks, alternatives, and authorization before selection.
6. Record `component | selected version/line | support status/EOL | compatible-with | source | checked date | unresolved risk`. External sources prove policy; clean install, build, and runtime prove the selected combination.

If primary sources are unavailable, stop before a version-bound decision or scaffold, report the unknown, and state
the next check. Never use model memory to certify a current LTS.

## 4. Decide foundations before mutation

Present material decisions with rationale and cost: system boundary and minimum vertical slice; currently justified
architecture and dependencies; verified stack chain; required data ownership, lifecycle, auth, tenancy, and
integrations; and stage-appropriate testing, delivery, observability, and recovery. Apply KISS/YAGNI: abstractions
need verified consumers or variation, and starters are inputs to inspect rather than architecture decisions.
Obtain user decisions for behavior, lock-in, recurring cost, and expensive-to-reverse choices.

## 5. Build and prove a vertical slice

- Scaffold only what the first slice needs and pin toolchain or lockfiles by ecosystem convention.
- Invoke domain owners for API, data, UI/UX, and operations rather than duplicating their checklists.
- From clean state, install or restore dependencies, typecheck, build, test, start runtime, and exercise the smallest end-to-end flow near the target environment.
- Confirm actual runtime versions match the compatibility record and remove unused generated defaults.
- Deliver decisions, sources and checked dates, verification results, assumptions, and known gaps. Never call the foundation ready while install, build, runtime, or compatibility criteria remain unproven.
