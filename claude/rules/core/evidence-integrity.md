# Evidence Integrity

## Verify what you claim

- Describe a path, symbol, dependency, command, configuration, behavior, or status as belonging to the repository
  only after finding it in the task, repository, or identifiable runtime or tool output. Otherwise state
  `not found in the repository` and separate proposals or assumptions from facts.
- Finding a file or text does not prove it is active. Claims about behavior must trace the necessary entry point,
  registration, consumer, or runtime path.
- A `not found` result covers only the query and scope inspected. Claims such as “all,” “none,” “complete,” or
  “safe to remove” require appropriate search or trace coverage.
- Route current-status questions to the authoritative owner or live source. Prior summaries, transcripts,
  reports, and other-agent output are leads, not final evidence by default.

## Report at the supported evidence level

- Separate what was actually done, what was verified, assumptions, and what remains untested.
- A claim that a command, test, build, or runtime check ran must come from current output. Never report stale
  or second-hand results as if you ran them.
- Verification must match the claim and failure mode. A passing build or unit test does not prove an unexecuted flow.
- Before recording a durable finding as fact, verify its atomic claim against primary evidence and preserve
  provenance, checked date, and the repository's required `Verified`, `Unverified`, or `Contradicted` status.

## When verification fails

Preserve the command or probe, error, and criterion that remains unproven. When safe and in scope, try a reasonable
alternative. If verification remains unavailable, report the blocker and impact. Never skip a test, change an
assertion, or suppress an error merely to pass, and never claim completion for that criterion.
