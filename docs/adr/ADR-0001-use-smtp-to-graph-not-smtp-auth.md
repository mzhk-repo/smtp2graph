# ADR-0001: Use SMTP-to-Graph, not Exchange Online SMTP AUTH

- **Status:** Accepted
- **Date:** 2026-07-22
- **Related:** `docs/SPEC.md` sections 1, 3, 4, 8; Gate C

## Context

Internal applications need a conventional SMTP endpoint, while Microsoft Entra Security Defaults must remain enabled. Exchange Online SMTP AUTH, app passwords, mailbox passwords and Security Defaults exceptions would weaken the identity boundary. The gateway must therefore terminate SMTP internally and deliver through Microsoft Graph.

## Decision

Use an internal SMTP-to-Microsoft Graph gateway with Microsoft Entra application-only OAuth 2.0 client credentials. The gateway is the only component translating SMTP submission into Graph `sendMail` requests. Human or mailbox interactive authentication is not part of the delivery path.

## Alternatives Considered

- Exchange Online SMTP AUTH with mailbox credentials — rejected because it depends on a weaker mailbox-password model and conflicts with the security baseline.
- Direct Graph integration in every client — rejected because it increases client complexity and multiplies identity/configuration boundaries.
- Custom SMTP-to-Graph implementation — deferred; it is unnecessary if the selected candidate passes qualification.

## Consequences

- Existing SMTP clients can use a local SMTP contract without implementing OAuth.
- Graph permissions, mailbox restriction, TLS, queue and SMTP policy become gateway responsibilities.
- Gate C must prove successful allowed-mailbox delivery and denial for an out-of-scope mailbox.
- SMTP2Graph behavior must not be assumed before Gate B evidence is complete.
