# Authorization and tenant isolation

- Enforce authentication and authorization at the server boundary; UI visibility is only UX.
- Default-deny endpoints/actions that require permission. Derive tenant identity from trusted auth context and scope
  reads/writes to it; never trust a client-supplied tenant identifier without verifying membership.
- Centralize policy evaluation where the stack supports it. Prefer capabilities/permissions over role-name checks
  when roles can evolve, but do not introduce a policy framework for a fixed local-only prototype without a driver.
- Test the roles and tenant boundaries affected by the change, including unauthenticated/unauthorized and at least
  one cross-tenant attempt when multitenancy exists.
- Log privileged permission, deletion, or financial actions when the product's audit requirements call for it.

Do not invent multitenancy or a role matrix. Establish them from requirements and the existing model first.
