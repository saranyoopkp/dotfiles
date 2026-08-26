# Money and business time

## Money

- Use decimal or integer minor units, never binary floating point for authoritative amounts.
- Keep currency with the amount; never aggregate different currencies silently. Preserve exchange rate and effective
  time when conversion must be auditable.
- Define rounding at one owner and reconcile splits/allocations exactly. Test representative values plus zero,
  minimum unit, rounding boundary, and duplicate/retry behavior relevant to the changed calculation.
- Give irreversible financial operations an idempotency key and an audit trail appropriate to the system.

## Time and timezone

- Store instants with UTC/offset semantics; keep date-only business concepts distinct from instants.
- Perform calendar arithmetic and business cutoffs in an explicit business/user timezone, then convert query bounds
  to UTC. Do not rely accidentally on the server timezone or string comparison.
- Give schedules an explicit timezone and test the boundaries the product can cross: midnight/month end, leap date,
  DST where applicable, and users/businesses in different zones.
