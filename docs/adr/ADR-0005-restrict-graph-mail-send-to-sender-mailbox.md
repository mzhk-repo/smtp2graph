# ADR-0005: Restrict Graph mail sending to the approved sender mailbox

- **Status:** Accepted
- **Date:** 2026-07-22
- **Related:** `docs/SPEC.md` sections 3, 4, 8, 14; Gate C

## Context

Microsoft Graph application `Mail.Send` is high impact if the application can send as arbitrary tenant mailboxes. The gateway has one approved sender mailbox, so the application identity must be restricted to that mailbox through Exchange Online authorization.

## Decision

Use application-only Graph authorization and restrict the application identity to the approved sender mailbox through Exchange Online RBAC for Applications (or the currently approved equivalent control). Production approval requires evidence that the identity can send from the approved mailbox and is denied from an out-of-scope mailbox.

## Alternatives Considered

- Unscoped tenant-wide `Mail.Send` — rejected as excessive privilege.
- Delegated user permission — rejected because it requires interactive user context and is incompatible with the service identity model.
- Separate application identity per client — deferred; it increases operational and credential lifecycle complexity.

## Consequences

- Microsoft 365 administration is a mandatory Gate C dependency.
- Authorization tests and redacted evidence must be retained before production use.
- Permission changes require coordinated review, revocation and rollback procedures.
