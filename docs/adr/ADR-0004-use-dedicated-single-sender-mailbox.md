# ADR-0004: Use dedicated sender mailboxes per service in production

- **Status:** Accepted
- **Date:** 2026-07-22
- **Related:** `docs/SPEC.md` sections 1–4, 13; Gate C

## Context

Five internal applications need stable and auditable sender identities. During the MVP, one dedicated sender reduces onboarding and qualification complexity. Production requires service-level isolation: a credential or policy error for one service must not grant it the ability to impersonate another service.

## Decision

Use one dedicated sender mailbox for the MVP: `noreply@ldubgd.edu.ua`. Before production, provision one dedicated mailbox per service and map each SMTP client to its own exact sender allowlist. Applications may provide an allowed `Reply-To` according to the client policy, but the envelope sender and message `From` must remain within the service-specific sender policy. All service mailboxes are separate from human interactive accounts.

## Alternatives Considered

- One shared mailbox for production — rejected because it weakens service isolation and makes sender attribution less precise.
- A human mailbox — rejected because it couples service delivery to a person and increases account risk.
- Arbitrary client-provided `From` — rejected because it enables impersonation and weakens auditability.

## Consequences

- Gate C must confirm mailbox ownership, allowed sender success and out-of-policy sender denial for every production service mailbox.
- Exchange display-name behavior and Reply-To expectations require acceptance evidence for the service-specific sender model.
- MVP migration to production requires mailbox provisioning, client-to-sender mapping, independent credential rotation and updated monitoring/alert ownership.
