# test/metrics — Agent Behavior from Session Corpora

This directory analyzes `~/.claude/projects` through two distinct pipelines:

- **Trend metrics** sample and aggregate behavior across SCC cutovers.
- **Evidence-grade retro indexing** inventories every source, preserves provenance, and creates one audit unit per human turn when coverage and traceability matter.

| Script | Purpose | Command |
|---|---|---|
| `lookback.py` | Regex and tool-use trends: correction, continuation, and ACV compliance by period | `python lookback.py --cuts <ts1> <ts2>` |
| `extract_turns.py` | Export user turns to `data/turns.jsonl` | `python extract_turns.py --since 2026-07-01` |
| `semantic_classify.py` | Haiku fan-out into seven categories, producing `data/merged.jsonl` and `data/daily.csv` | `python semantic_classify.py [--sample 600]` |
| `eval_groundtruth.py` | Create or evaluate a hand-labeled precision/recall set | Run `--make`, label manually, then run without it |
| `index_transcripts.py` | Build the SQLite index, reconcile source/line/turn coverage, and export objective-audit queues | See below |
| `test_index_transcripts.py` | Synthetic schema, branch, tool-result, and coverage regressions | `python test_index_transcripts.py` |
| `prepare_audit.py` | Create a deterministic pilot manifest and payload budget without a model | See below |
| `test_prepare_audit.py` | Sampling, edge-coverage, and budget regressions | `python test_prepare_audit.py` |
| `discover_events.py` | Create event candidates and branch-aware evidence packets | See below |
| `test_discover_events.py` | Verify packets follow lineage without mixing sibling branches | `python test_discover_events.py` |

## Evidence-grade retro index

```bash
cd test/metrics
python index_transcripts.py index
python index_transcripts.py status
python index_transcripts.py search 'I meant'
python index_transcripts.py context <session-uuid> <turn-ordinal>
python index_transcripts.py export --session <session-uuid>
python index_transcripts.py import data/reviewed.jsonl --reviewer <name> --prompt-version <version>
```

`index` recursively catalogs every JSONL file but audits only primary interactive sessions by default. Subagents, Temp or harness runs, and `sdk-cli` or print sessions are explicit exclusions. A session that uses Edit, Write, or NotebookEdit on this dotfiles repository—including paths through `~/.claude/rules`, skills, or agents symlinks—is excluded as `dotfiles_self_modification`, preventing evaluator changes from serving as independent evidence. Ordinary reads and config invocation remain included.

The database stores normalized conversations with source file, line, UUID, and raw hash. Raw JSONL remains the primary evidence and is not copied into the database.

Semantic coverage uses auditable human inputs, not sessions. Export wraps turns in sessions to preserve order, but reviewers must separate objectives and episodes and classify each turn as `CONTINUE | REFINE | QUESTION | PREREQUISITE | NEW | REPLACE | DEFER | RESUME | CANCEL | CORRECT | AMBIGUOUS`. Topic change alone does not prove objective replacement.

Status reconciles three layers:

```text
discovered files = indexed + explicitly excluded + failed
indexed lines = parsed + malformed + blank
auditable inputs = pending + classified + ambiguous + failed + input-only audit units
```

`fallback_human_prompts` contains legacy messages lacking `promptSource` that pass structural exclusion. `ambiguous_user_inputs` do not count as human input until reviewed. SQLite search uses exact substring matching through `instr`; it makes no unsupported word-segmentation claim. If ambiguity remains, inspect the shape, add a deterministic disposition with a fixture, and reindex rather than coercing individual records to complete a count.

Every shared-parent input remains in input coverage. Responded alternatives are `executed_branch` and require lineage-specific audit; unresponded edits are `unanswered_edit` with `input_only` status and do not enter alignment metrics or the primary objective ledger. Never read sibling candidates as one timeline merely because they share a session envelope.

Imported reviews require one item for every alignment-auditable turn in a session and reject partial imports. Each includes `turn_id`, `input_sha256`, `relation`, `objective_before[]`, `objective_after[]`, `alignment`, `confidence`, `rationale`, and `evidence[]`. Imports reject omissions, duplicates, stale inputs, invalid relations, and findings without source evidence.

## Semantic pilot planning

```bash
python prepare_audit.py \
  --known-session <session-uuid> \
  --random-size 100 \
  --context-turns 6
```

The planner separates known benchmark sessions from random holdout, includes every legacy fallback, and selects edge representatives across project, branch, confidence, session-size, and risk strata. Signals and strata select additional examples only; they never remove interactions or replace random holdout for prevalence. The report identifies represented and missing strata. Default behavior covers each stratum; `--edge-size` deliberately caps it and accepts partial coverage.

`data/audit-plan.json` contains manifest, provenance, and sizes without conversation text. Random holdout is a deterministic interaction-weighted sample and estimates prevalence per interaction, not per session. Selection reasons may overlap, so reports include multi-reason counts and pairwise intersections.

Budgets report normalized character and UTF-8 byte counts plus a broad planning heuristic, not model-token bounds. They exclude prompts, retries, and second reviewers. Do not start a semantic batch until model, packing strategy, per-call budget, and hard input budget are defined. Turn-only, bounded-context unique/repeated, full-session envelope, and objective-spine surfaces expose different costs. Physical context may cross alternate branches, so a branch-aware packer remains required. The planner fails closed with `pilot_ready: false` until packing, model budgets, and `--max-planned-input-chars` are present.

Targets are pending alignment turns, while context preserves surrounding classified and input-only turns. Full-corpus denominators include every alignment status. Sampling rank and plan identity bind seed, input hash, and database snapshot to expose corpus drift.

## Event discovery

```bash
python discover_events.py \
  --known-session <session-uuid> \
  --known-limit-per-session 10 \
  --discovery-limit 100 \
  --discovery-since 2026-07-27 \
  --before 6 \
  --after 2
```

`event-candidates.json` preserves provenance for every pending alignment turn so unopened items remain visible in coverage. Signals such as explicit correction, objective or boundary control, and a question followed by mutation only prioritize review; they do not classify incidents. `event-packets.jsonl` contains selected known benchmarks and the discovery frontier, following UUID parent lineage without concatenating alternate siblings. `--discovery-since` limits opened discovery packets while keeping the full manifest and backlog.

Review each packet as `incident | not_incident | insufficient_context`. An incident dossier records prior intent, divergence point, agent action, user correction or impact, recovery, source evidence, a dotfile-mechanism hypothesis, and a regression candidate. Trend and prevalence are post-processing after behavior changes, not the primary discovery deliverable.

## Rules

- `data/` is ignored because real conversations may contain secrets; never commit it.
- Even text-free audit plans contain local paths, projects, and UUIDs. Sanitize before sharing outside the machine.
- After changing `--sample` or `--since`, delete `data/out/` so index-keyed batch cache cannot mix populations.
- A sample of 600 is appropriate for trends and about five times cheaper; use the full corpus before establishing a baseline.
- Never edit scripts while a batch runs because Bash and subprocesses may read them incrementally.
- Measured baselines are recorded at the CLAUDE.md cutover marker for the 07-17 lookback and semantic run.
- Trend extractors are not exhaustive evidence: by design they truncate text, abbreviate session IDs, and remove abandoned branches. Use the retro index for traceable audits.
