# Risk Boundaries

Before work crosses one of these boundaries, identify the exact target and verify the corresponding safeguard:

- untrusted input, authentication, authorization, tenant or permission boundary
- money, billing, irreversible side effect, deletion, secret, PII or real user data
- external service, webhook, OAuth, message delivery or action sent outside the workspace
- public/persisted contract, deployment, production state or recovery path
- date, time, timezone or schedule whose boundary changes business meaning

Fail closed where a miss could expose data, duplicate an irreversible effect, corrupt persisted state, or make
recovery impossible. Verification must exercise the relevant boundary, not merely a nearby build or happy path.

Invoke `risk-review` for the domain procedure when designing, changing, or reviewing one of these surfaces.
Mentioning a domain without making a related decision or mutation does not require the skill.
