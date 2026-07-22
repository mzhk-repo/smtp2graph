# ADR-0003: Select single-node Docker Swarm for the production minimum

- **Status:** Accepted
- **Date:** 2026-07-22
- **Related:** `docs/SPEC.md` sections 2, 4, 8, 13; Gate D

## Context

The initial service has one bounded SMTP gateway, one persistent queue and a low expected volume. Kubernetes, an external broker, a database and active-active HA add operational scope without being required for v1.0. The deployment still needs declarative configuration, native secrets, restart behavior and a reproducible rollback path.

## Decision

Deploy one gateway service with one replica on a single Linux host running Docker Swarm. Bind SMTP only to an internal address, attach a persistent queue volume, use Swarm secrets and pin the image by digest. Encrypted overlay networking is required when plaintext SMTP traverses Swarm hosts.

## Alternatives Considered

- Kubernetes — deferred as unnecessary operational complexity for the production minimum.
- Standalone Docker Compose — not selected because the baseline requires Swarm deployment and native secret handling.
- Active-active or multi-node Swarm — deferred until measured availability or capacity needs justify it.

## Consequences

- Deployment and secret rotation use reviewed declarative automation and service updates.
- The gateway remains a single point of service failure; restart and cold recovery must be tested.
- Queue placement and filesystem permissions are operationally critical.
- Scaling out is explicitly deferred and would require a new decision covering queue and duplicate-delivery semantics.
