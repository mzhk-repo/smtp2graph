# ADR-0002: Select SMTP2Graph as the initial gateway candidate

- **Status:** Rejected
- **Date:** 2026-07-22
- **Related:** `docs/SPEC.md` sections 2, 4, 5, 14; Gate B; Tasks 2.2–2.5

## Context

The project needs one maintainable SMTP-to-Graph component for the production minimum. SMTP2Graph was the initial candidate because its stated feature set includes SMTP server support, Graph relay, SMTP authentication, TLS, IP and sender allowlists, rate limiting, brute-force protection and a local queue. The v1.1.5 release and image digest were recorded as a qualification candidate. A synthetic runtime spike passed certificate-file and client-secret rendering plus non-root/read-only startup, but the Gate B review found Critical delivery and durability defects.

## Decision

Reject upstream SMTP2Graph v1.1.5, pinned to the multi-platform digest recorded in [`deploy/config/gateway-version.md`](../../deploy/config/gateway-version.md), as a production gateway component. Gate B confirmed three Critical blockers: Graph `Retry-After` is ignored; permanent Graph errors can remain in the live queue rather than atomically moving to `failed`; and SMTP `250` precedes confirmed durable queue persistence.

The roadmap selects a minimal fork of the exact upstream release as a remediation path only. It is not an approved production component or a qualified candidate until it has its own immutable digest and a complete, digest-scoped Gate B review. Production implementation remains blocked.

## Alternatives Considered

- Standalone Docker Compose with host-managed secrets — rejected for the production minimum because the selected baseline requires Swarm-native secret handling and controlled deployment.
- Minimal fork of exact v1.1.5 — selected as the remediation path because the three blockers are localized; it requires a new digest-scoped qualification.
- Custom Python production minimum — fallback if the fork cannot be maintained safely; it requires a new ADR and a full Gate B.
- Exchange Online connector relay — rejected because it does not provide the required application-only Graph boundary and client policy model.
- A different upstream gateway — retained as a fallback; it requires a full Gate B.

## Consequences

- Upstream v1.1.5 is prohibited as a production component; its existing digest, scan and runtime evidence cannot be transferred automatically to a fork.
- The qualification wrapper remains a synthetic prototype and does not approve any production secret lifecycle.
- The fork must implement and test `Retry-After`, permanent-error-to-`failed`, and durable SMTP acknowledgement behavior without MIME, BCC, UTF-8, attachment or restart regressions.
- A successful fork review requires an immutable image digest, SBOM, vulnerability/provenance evidence, non-production Microsoft 365 checks and a new Gate B decision record.
- Synthetic fixtures and isolated tenant resources remain required for protocol and runtime tests.
