# ADR-0002: Select SMTP2Graph as the initial gateway candidate

- **Status:** Proposed
- **Date:** 2026-07-22
- **Related:** `docs/SPEC.md` sections 2, 4, 5, 14; Gate B; Tasks 2.2–2.5

## Context

The project needs one maintainable SMTP-to-Graph component for the production minimum. SMTP2Graph is the initial candidate because its stated feature set includes SMTP server support, Graph relay, SMTP authentication, TLS, IP and sender allowlists, rate limiting, brute-force protection and a local queue. The v1.1.5 release and image digest are now recorded as a qualification candidate, but runtime and security evidence is incomplete.

## Decision

Use SMTP2Graph v1.1.5 as the initial gateway candidate for qualification only, pinned to the multi-platform image digest recorded in [`deploy/config/gateway-version.md`](../../deploy/config/gateway-version.md). Keep this ADR Proposed until Gate B verifies provenance, license compatibility, signature/vulnerability/SBOM posture, secret-file compatibility, non-root/read-only behavior, queue durability, SMTP acknowledgement semantics, retry behavior, MIME handling and display-name behavior.

Production implementation must not depend on SMTP2Graph until Gate B is `pass` or `conditional pass` without a Critical blocker. A failed qualification returns the component decision to review; it does not trigger production migration.

## Alternatives Considered

- Standalone Docker Compose with host-managed secrets — rejected for the production minimum because the selected baseline requires Swarm-native secret handling and controlled deployment.
- Custom gateway — deferred due to unnecessary implementation and maintenance scope.
- Exchange Online connector relay — rejected because it does not provide the required application-only Graph boundary and client policy model.
- A different upstream gateway — retained as a fallback if SMTP2Graph fails Gate B.

## Consequences

- Qualification work is explicit and evidence-driven rather than an implicit component approval.
- The candidate image reference is immutable, but it is not yet an approved production artifact; mutable tags remain prohibited for deployment.
- Gate B may reject or conditionally accept the candidate, requiring the ADR status and AI context to be updated with evidence.
- Synthetic fixtures and isolated tenant resources are required for protocol and runtime tests.
