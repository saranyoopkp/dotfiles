---
name: research:security-advisories
description: Investigate current security advisories, CVEs, vulnerabilities, affected and fixed versions, exploit preconditions, transitive dependencies, and remediation. Use for dependency, runtime, image, or OS audits, vulnerability alerts, package additions or upgrades, or claims that a repository is affected or safe. Map advisories to exact resolved versions and reachable deployments.
---

# Security Advisories

Use `research:research-control` when several advisories or components are involved, or when remediation carries
compatibility risk.

1. Inventory the real artifact first: ecosystem, package or product, exact resolved version, dependency path,
   OS/image/runtime, deployment, and relevant feature or code path. Similar names do not identify the same artifact.
2. Check current sources by claim: vendor or project advisory and fixed release, authoritative CVE record,
   ecosystem advisory database, then scanner or secondary sources as leads. Preserve advisory ID, affected and
   fixed ranges, publication or update date, and checked date.
3. Separate `present → affected version → vulnerable configuration or precondition → reachable or exposed`.
   Presence or a scanner match does not prove exploitability; lack of reachability does not erase residual risk.
4. Verify backports, distribution patches, forks, aliases, transitive resolution, and runtime flags from maintainer
   sources. Version-string comparison alone may be wrong.
5. Assess confidentiality, integrity, availability, privileges, exposure, exploit maturity, and repository context.
   CVSS and severity labels are inputs, not verdicts.
6. Order remediation options: compatible fixed version, configuration or feature mitigation, exposure reduction,
   or compensating control, with compatibility, rollout, and rollback risks. Research does not authorize changes.

For each advisory report `Affected / Not affected / Unknown`, component, version, path, preconditions,
reachability, source and checked date, probe, remediation, and residual risk. Never use an audit exit code alone
to certify safety.
