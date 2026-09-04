# SCC behavior experiment — cutovers, measurements, and next-round draft

This living document is the canonical record for SCC behavior changes and measurement. `CLAUDE.md` keeps only timestamps and current status. Measurement tools live in `test/metrics/`; the original enforcement baseline is the point-in-time `docs/dogfood-audit-2026-07-15.md`.

## Cutover markers

```
cutover-1: 2026-07-15T02:44+07:00 · SCC 539 → 580 (finish the plan + declare evidence level)
cutover-2: 2026-07-16T16:10+07:00 · SCC 580 → 617 (calibrated action + record before done)
cutover-3: 2026-07-17T20:55+07:00 · SCC 617 → 626 (form ambiguity + declare assumptions)
cutover-4: 2026-07-26T00:53+07:00 · SCC 471 → 401 (responsibility boundary + compact triggers/actions)
cutover-5: 2026-07-27T22:29+07:00 · SCC 401 → 422 (objective continuity + detour resume + defer suppression)
cutover-6: 2026-07-31T23:47+07:00 · SCC 423 → 425 (parent deliverable + child prerequisite + load-test routing)
```

Measurement rules: sessions closed before a marker are before, sessions closed after are after, and sessions spanning it are excluded because SCC loads only at session start. Include main sessions only; exclude subagents, Temp, and `-p`. Inspect time trends rather than aggregate averages. Always deduplicate the corpus: rewind/edit creates about 9% ghost siblings biased toward corrective turns; `extract_turns.py` handles them.

## Primary hypothesis

**Trigger → action rules work better than abstract principles.** Supporting evidence:

- Cutover 1 reduced unnecessary “continue” prompts from 1.9 to 0.0–0.8 per 100 turns, and the reduction persisted.
- A report-miss on 07-17 showed the mechanism's boundary. A trigger enumerating target ambiguity did not fire for form ambiguity. Trigger rules are precise for enumerated classes; the unlisted tail is a blind spot by design. This led to cutover 3.

## Cutover content

**Cutover 1:** Finish your own plan: do not ask questions whose answer is known, offer to pause, or present A/B/C when all can be done. Declare evidence level: reserve “done” and “ready” for runtime evidence; checkmarks and emoji are not citations. Written as triggers and actions.

**Cutover 2:** Based on 345 corrective turns: calibrated action addressed wrong target (70), omission (64), and excess work (28), all forms of acting before checking. Record-before-done addressed stale status that misleads the next session. Expected signals were fewer corrective turns and less documentation drift.

**Cutover 3:** The owner ordered an early change on 07-17 because production work was affected. Hypothesis: removing unnecessary questions also removed the useful function of clarifying intent. Supporting but non-causal evidence: `corr_target` reached the month's high of 6.5/100 turns, approval reached its low, concession rose, and a real report-miss occurred. The change added deliverable-form ambiguity and required a one-line interpretation before proceeding rather than guessing silently. Desired result: lower `corr_target` without approval rebounding.

**Cutover 5:** A retro across sessions `f1d10083`, `caf674d7`, `a3fffd4a`, and `de808299` found a loop: the agent proposed adjacent work every turn, the user asked about it, and the agent treated that as a new objective, requiring the old objective to be restored.

- Rule: questions and observations are detours by default; switch only on explicit ordering. Do not reopen known/deferred work. Incidents may interrupt but must retain a resume point.
- SCC: add trigger/actions for detours, resumption, dependency classification, and current-slice-first behavior.
- Proposal/docs: remove mandatory footers, park adjacent work after delivery, and do not turn pre-existing documentation debt into a blocking question.

Preserve root-cause and dependency work required by the original outcome, such as Cognito flows, MythicArmors offline CLI, and incident recovery; those are not drift.

Post-cutover signals require raw-turn review: how often the user must say “return to,” “scope only,” or “later”; whether deferred work is reopened; whether the objective resumes after a detour; and whether blocking dependencies are still surfaced. Regex finds candidates only because the same text can represent a valid user-led switch.

Immediate smoke on 2026-07-27: targeted retro routing passed 3/3. A fresh-process detour scenario answered the interruption, retained the objective and resume point, and did not ask the user to choose ordering again. A deferred scenario correctly marked known/deferred and returned to deployment, but ended `budget_exhausted`; treat it as an observation, not a clean pass.

**Cutover 6:** In session `f40c4fd7`, the requested load-test script and metrics matrix were displaced by prerequisite tracing. Readiness was misreported as coverage, and a report replaced the executable deliverable. The rule and SCC gained parent/child objective handling. `testing-strategy` owns load-test harnesses; `performance` takes over for metric analysis and optimization choices. Signals: whether the user must restore the script objective, whether planned/runnable/measured are separated, and whether a report replaces the requested artifact.

Immediate smoke retained the script as primary, reported deliverable progress as 0% separately from completed tracing readiness, and resumed matrix enumeration/script creation. Targeted routing passed 7/7, including invoking `testing-strategy` without `performance` for a load-test harness.

## Accumulated measurements

Three-day window after cutover 1 (07-15, 20 sessions/206 turns, observer effect): unnecessary “continue” prompts fell from about 1.8/100 turns to zero; ACV compliance rose from 39% to 64%.

07-17 lookback using ground-truth tool calls and excluding straddles:

| Metric | P0 before cutover 1 (61s/1614t) | P1 (64s/247t) | P2 after cutover 2 (12s/125t) |
|---|---:|---:|---:|
| Continue commands per 100 turns | 1.9 | 0.0 | 0.8 |
| Corrective regex per 100 turns | 1.9 | 0.4 | 0.8 |
| ACV in edit sessions | 31% | 57% | **11%** |

The deduplicated semantic classifier on 07-17 had seven-category accuracy 0.84. Approval was about 19–20/100 turns early in the month, then 8.3 on 07-16 and 6.5 on 07-17. Corrective varied from 2–14 without a step at cutover 2; 07-17 included meta sessions. Approximate precision was 0.95 for approve/new-task and 0.73–0.80 for corrective, with 20–25% noise. Use trends, not absolute values; ground truth was 100 labels from Fable-judge, not humans.

Status: cutover 1 persisted beyond the observer window. Cutovers 2 and 3 awaited larger samples around 08-01. ACV at 11% crossed the tripwire and prompted the verify nudge below.

## Comment-discipline cutoff (2026-07-19)

```
comment-cutoff: 2026-07-19 · rule §in-code changed 71b9426→e2c6489:
maximum two lines plus pointer, docstring means contract, reading path required,
and no home paths; SCC implementation section gained “in-code writing discipline.”
```

The owner overrode the freeze after confirming the first rule deployment had not changed excessive-comment behavior. This variable therefore affects post-cutover-2/3 data. Baseline debt was 499 blocks in a work repository, scanned by `/docs:placement scan.py`.

Measure only owner reports from sessions opened after the cutoff; they are more precise and cheaper than semantic classification. Tripwire: two or more reports after cutoff means the always-on rule lacks salience. Escalate to a deterministic generic hook that counts new comment blocks in the diff, or combine with a later SCC revision. Do not repeatedly rewrite the same rule.

## Verify nudge (deployed 2026-07-17)

The agent had no price awareness and work repositories did not load this repository's `CLAUDE.md`. Avoiding ACV in 89% of cases likely meant the mandate was buried in start-of-session context, far from completion or after compaction, rather than deliberately skipped due to cost.

Intervention: a generic verification reminder in the kit's `docs-drift.sh` Stop hook when source changes remain, deduplicated by hash and naming no verification mechanism, plus TaskCompleted item 4. It was deployed to nine repositories. If ACV/self-verification rises from 11% in the next edit-session lookback, salience is likely causal; otherwise investigate enforcement.

### Follow-up guard update (2026-07-23)

Rule/SCC/ACV gained intent and failure-escalation gates: a question or problem report is not authorization to mutate, and failed/skipped verification needs evidence, an alternative, or a blocker before conclusions. An execution-tracking gate requires task tracking when task tools exist and work spans steps, turns, handoffs, or blockers; short read-only questions do not create ceremonial checklists. The kit added a non-blocking Stop audit for new two-line comments in diffs to encourage durable project documentation. Hooks must remain self-contained and may not depend on dotfiles rules or skills.

## Three confidence signals (latest values 2026-07-17)

| Level | Definition | Value | Direction |
|---|---|---:|---|
| Corrective, light | User corrects target, omission, or excess | 2–14/100 user turns | Flat |
| Concession, medium | Agent admits “you are right/I was wrong,” WORK only | 0.64/100 → 1.3–1.7 | Rising while corrective falls; not necessarily more errors |
| **User takeover, severe** | User stops delegating and performs the work; classifier candidates judged in a second pass | **13/month; 7 on the hook-saga day** | More than 2/day indicates an active saga |

META sessions inflate concession fivefold (3.31 vs 0.64/100), so separate WORK from META before interpretation.

## Partially surfaced insights

1. Operations are substantial: SSH 1,154 and `docker exec` 83; a remote-ops skill may be more valuable than more enforcement.
2. `find-skills` was invoked 54 times but did not exist: an easy defect.
3. Windows path tax: `MSYS_NO_PATHCONV` 622 and `cd` prepend 7,722.
4. ACV cost was about six minutes/213k tokens; prefer the verify-nudge or ACV-light investigation.
5. Two agents, rules, kit, hooks, and skills approached an unsustainable maintenance point. Every fix added machinery; absent clear aggregate improvement by 08-01, reduce mechanisms.
6. Verification was still pushed to the user. During the hook saga, the user caught a false claim, fixed the issue, found the root cause, and authored the verification rule in `809d32e`. On 07-17, all six user measurement objections identified real defects.

## Third SCC revision candidate

Repeated testable-claim failures:

- Tenant-type enum: “all/covered” without a search.
- Client backend env-vs-code, session `ace13c86` on 07-17: claimed code would fail and require changes, contradicted by a five-second curl (`SC-0000`). It trusted a GUID-like field name over actual type/use, treated self-authored docs as fact, and failed to ask whether configuration was sufficient.
- Context sweep on 07-17: told a causal story from aggregates without inspecting raw cases.

Candidate trigger/actions:

1. Before claiming “will fail,” “must change,” “complete,” or “no others,” run the cheapest falsifying test/search or state that it remains unchecked.
2. Before proposing code changes, determine whether existing configuration, environment, or data is sufficient.
3. Treat agent-authored docs as observations, not runtime facts.
4. If the same symptom reaches round three while tests pass but real use fails, stop patching and challenge the measurement channel. Evidence: the nine-fix/four-hour hook saga ended only when measurement changed.
5. Inspect raw cases before causal claims from aggregates.
6. For ambiguous scope or multiple targets, state a one-sentence interpretation before planning. Cutover 3 already partly addressed deliverable form.

SCC changes were originally frozen until about 2026-08-01 to isolate cutovers 1–3. On 2026-07-26, the owner overrode the freeze to reduce duplication while retaining `rule invariant → agent trigger/action → skill domain procedure`. Treat post-cutover-4 results as a new series; never merge them with earlier windows without preserving markers.

## Draft: `claude/agents-draft/SCC-v1.0.1.md` (2026-07-20, not promoted)

The candidate reduced four duplicative SCC-v1.0 checklists and removed poetic principles without actions, shrinking roughly 634 lines to 215. It retained every measured trigger/action section: code-writing discipline, finishing the plan, calibrated action, evidence declaration, and the Acceptance Validation Protocol with ACV verdict table. Responsibility-boundary ideas were partly deployed in cutover 4; the remaining checklist/poetry reduction was still only a candidate.
