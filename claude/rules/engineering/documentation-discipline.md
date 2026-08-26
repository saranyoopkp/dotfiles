# Documentation Safety

- Update an owned contract, decision, runbook, or recall hook when the current change makes it stale; do not perform
  a general documentation audit on every mutation.
- Keep one authoritative owner for a fact and use pointers where another surface needs discovery. Runtime-sensitive
  claims must be checked against the owner or live source before being treated as current.
- Never commit secrets or private operational data to shared documentation. A durable audit finding needs evidence
  and a status that does not overstate what was verified.
- Put explanation where its future reader will encounter it: local constraints near code, interface contracts in
  the language's normal API documentation, and broader rationale/runbooks in repository docs. Length alone does not
  determine placement.

Invoke `docs` or a relevant `docs:*` child when documentation itself is the task, placement is genuinely ambiguous,
or topology/link/staleness requires a procedure. Incidental code comments do not require a docs skill.
