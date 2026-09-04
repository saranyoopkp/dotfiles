---
name: retro
description: Extract evidence-backed behavioral signals and feedback from sessions or transcripts to improve dotfiles. Use for /retro, retrospectives, session comparison, repeated corrections, objective or attention drift, agent pain, false claims, near misses, surprising behavior, or behavior worth preserving—even when the user only reports that something feels wrong or unusual. Read-only by default.
---

# Session Retro

Turn session observations into traceable dotfiles improvements without treating every signal as a defect or an
instruction gap.

## Boundary

- Analyze only accessible session, context, and repository evidence; never invent events or frequency.
- Compare only sessions relevant to the same objective and preserve each session's evidence separately.
- Remain read-only unless the user explicitly authorizes changes, memory updates, or promotion of findings.
- Seek correctable system causes rather than assigning blame to users or agents.
- A strange or uncomfortable feeling is a signal to investigate, not proof that behavior or configuration is wrong.
- Mark insufficient evidence `Unverified` and state the next check.

## Workflow

1. Identify signals: user surprise or discomfort; repeated corrections; agent stalls, manual rechecks, misuse of
   evidence, or dead ends; false claims, near misses, behavioral surprises, invalid verification; and effective
   behavior worth preserving.
2. Group events by root concern while retaining individual evidence. Repeated references to one event are not new occurrences.
3. Inspect existing repository coverage. Existing instructions suggest execution, routing, enforcement, or test gaps;
   absent or repeatedly misread guidance may indicate an instruction gap.
4. Classify supported causes as `instruction gap`, `instruction overload`, `execution miss`,
   `tool/harness limitation`, `repository-specific`, `user preference`, or `unknown`. For multi-turn work,
   also consider `objective loss`, `attention drift`, `reopened deferred issue`, or
   `beneficial scope deepening`. An interjected question does not prove an objective change, and necessary work
   for the original outcome, correctness, or safety is not drift.
5. Select an owner: practitioner trigger/action → Agent; shared invariant → Rule; domain procedure → Skill;
   regression or tool limitation → Test/Harness; cross-session preference → Memory; target-specific concern →
   Target repository.
6. Propose only the smallest root-cause correction and state instruction-noise, overlap, and behavior-change risks.

## Output

For each signal report:

```text
Finding:
Status: Verified | Inferred | Unverified | Contradicted
Evidence: traceable event or message
Frequency: occurrences verified in this scope
Pain/impact:
Likely cause:
Existing coverage: present | absent | unverified, with location when present
Candidate owner: Agent | Rule | Skill | Test/Harness | Memory | Target repository | None
Minimal improvement:
Risk/overlap:
```

Conclude with `Consider changing`, `Do not change dotfiles yet`, and `Preserve`. For scope drift, identify the
current objective, detour or interruption, resume or loss point, and the user message needed to restore work.
Never treat a user follow-up as retroactive authorization for an agent-originated proposal or mutation.

Do not mutate after reporting, even when the proposal is clear; wait for the user to select an action.
