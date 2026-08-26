# External integrations

## Inbound events

- Verify origin/signature before accepting a webhook. Persist enough of the event to diagnose or replay failures.
- Assume retries and duplicates; use provider event identity or a documented equivalent so repeated delivery cannot
  repeat a non-idempotent effect. Filter provider echo events when the protocol can reflect the system's own action.
- Keep the receiver within the provider deadline; defer substantial processing only when the flow actually needs it.

## Outbound calls

- Set an appropriate timeout/deadline and surface provider errors with enough context for operators without leaking
  secrets. Do not collapse materially different failures into a boolean.
- Check local preconditions before an external side effect. Make retry semantics explicit and cap automatic retries.
- Verify provider contract from current official documentation and verify credentials/scope/payload against the live
  integration when authorized; neither form of evidence replaces the other.

Add queues, dead letters, pollers, or reconciliation only when delivery guarantees, volume, or recovery requirements
justify them. Test duplicate, invalid-origin, and failure/retry paths that the integration can actually produce.
