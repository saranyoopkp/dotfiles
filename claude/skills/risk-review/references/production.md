# Production safety and recovery

- Validate untrusted input at the trusted boundary. Give external I/O a bounded failure path and keep user-facing
  errors free of secrets/internal detail while retaining operator diagnostics.
- Keep secrets out of tracked files and logs; rotate a secret exposed to Git or an unauthorized party. Minimize,
  redact, retain, and restrict PII/telemetry according to the actual sensitivity and requirements.
- For services that must stay available, monitor the state and dependencies whose silent failure would harm users;
  a process being alive or a deploy returning success is not sufficient evidence of service health.
- Before a production mutation, know the rollback or forward-recovery path. Account for persisted data that code
  rollback cannot reverse.
- Backups matter only when they cover required data, survive the relevant failure domain, and can be restored.
  Require a restore drill and runbook when recovery objectives or operational ownership make them necessary.
- After release, exercise a health/user path that covers the changed dependency. Record a material recovery or
  observability gap rather than claiming readiness.

Calibrate to the stage the repository or user establishes. If stage is unknown, ask only when it changes the current
decision; do not silently impose a full production platform on exploratory work.
