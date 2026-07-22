# ADR-0006: Use runtime Docker Secrets with SOPS + age for encrypted static material

- **Status:** Accepted
- **Date:** 2026-07-22
- **Related:** `docs/SPEC.md` sections 8, 9, 13; Gate B and Gate C

## Context

The gateway needs Graph credentials, SMTP credentials and possibly a certificate/private key. Production plaintext secrets must not persist in Git, images, `.env` files, CI artifacts, logs or container environment. Docker Swarm provides a runtime secret boundary; SOPS + age can protect approved static environment material in Git.

## Decision

Mount production secrets as Docker Secrets under `/run/secrets/`. Store only encrypted static material with SOPS + age, subject to approved recipients and a recovery custody model. Render any application configuration that combines secret values only at runtime, preferably into tmpfs, and never commit or persist plaintext. Prefer certificate/private-key authentication when the pinned gateway supports it; otherwise use a documented runtime client-secret fallback.

## Alternatives Considered

- Plain `.env` or stack YAML secrets — rejected because they expose credentials through source, artifacts or process/environment inspection.
- Host-managed plaintext files — rejected as the default because the lifecycle and access boundary are weaker and harder to review.
- External secret manager — deferred; it may be evaluated after the production minimum.

## Consequences

- Secret names, permissions, rotation and revocation become explicit deployment contracts.
- Docker Secret immutability requires versioned names and a service update during rotation.
- Gate B must verify file-based credential compatibility and absence of secrets from inspect/env/logs.
- Gate C must verify credential expiry and revocation procedures.
