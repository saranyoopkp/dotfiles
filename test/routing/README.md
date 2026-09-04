# Skill Routing Tests

Deep domain rules such as `ui-ux-baseline`, `data-design`, and `risk-review` are on-demand skills. Their lightweight descriptions provide always-available routing signals, while bodies load once when invoked. The main risks are missing an appropriate invocation and invoking an unrelated skill.

This suite sends cross-domain and simple negative-routing tasks through fresh `claude -p` sessions. It passes when required primary skills fire and `NONE` cases invoke no on-demand skill. Related skills may co-fire: overlapping concerns such as webhooks and data design can route nondeterministically without constituting over-invocation.

The registry is derived automatically from skill frontmatter. The parser compares exact names after converting `:` to `-`, so a child-name prefix does not count as invoking its parent.

## Run

```bash
bash test/routing/run.sh
```

- Every scenario uses a fresh session so rules and skills load from a clean start. A subagent cannot substitute because it inherits existing context.
- The default runs at most four sessions concurrently to reduce CLI startup races. Configure `ROUTING_MAX_PARALLEL` and select colon-separated files with `ROUTING_SCENARIO_FILES`.
- The suite runs in a sandbox outside the repository so `dotfiles/CLAUDE.md` cannot contaminate results. Configure `ROUTING_SANDBOX` or `.local.sh`; an environment value supplied at execution takes precedence.
- Each scenario consumes API tokens. Run after changing skill descriptions or scenarios, not on every commit.
- Verdicts inspect actual Skill tool use from raw stream-json and require CLI exit status 0. Startup failures and timeouts are harness failures distinct from routing conclusions.
- Validate the registry without model calls using `ROUTING_LIST_SKILLS=1 bash test/routing/run.sh`. This fails for missing, ambiguous, or duplicate frontmatter names and normalizes CRLF before comparison.

## Targeted child routes

The default suite covers surface-level routing and negative cases. `scenarios-routing-children.tsv` covers every registry child and should run after changing a parent router, child description, or routing graph:

```bash
ROUTING_SCENARIO_FILES=test/routing/scenarios-routing-children.tsv bash test/routing/run.sh
```

Cross-domain co-fire is not a success requirement because those related edges may load nondeterministically. Validate their structure with the graph validator and use scenarios with real surface or decision evidence.

Silent-miss and registry-parser regressions are in `scenarios-routing-defects.tsv`:

```bash
ROUTING_SCENARIO_FILES=test/routing/scenarios-routing-defects.tsv bash test/routing/run.sh
```

## Add a case

Preferred format:

```text
require<TAB>forbid<TAB>label<TAB>task
```

- Separate multiple `require` or `forbid` skill names with spaces; `-` means unspecified.
- Use `forbid` to test over-triggering while allowing unrelated skills to fire.
- The legacy `expect<TAB>label<TAB>task` format remains supported; `NONE` forbids every on-demand skill.

## Artifacts

Each run saves raw stream-json and stderr per scenario under the configured sandbox's timestamped `runs/` directory. Failed summaries point to the relevant labeled artifact. The harness also stores sessions under `~/.claude/projects/<cwd-hash>/<session-id>.jsonl`, but those are unlabeled and mixed together; prefer these run artifacts. The playground stays outside the repository and old runs may be deleted.

Repeated long-conversation testing showed routing still invokes after later turns where an earlier pointer-based workaround failed. Continue collecting evidence during real use rather than treating the observed depth as a universal limit.
