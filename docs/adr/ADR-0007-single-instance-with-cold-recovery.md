# ADR-0007: Operate one gateway instance with tested cold recovery

- **Status:** Accepted
- **Date:** 2026-07-22
- **Related:** `docs/SPEC.md` sections 4, 6, 13, 14; Gate D

## Context

The production minimum targets 99.5% monthly availability, a 60-minute RTO and a 24-hour configuration RPO, but does not require active-active delivery. Queue state may contain complete MIME messages and restoring it can create duplicate delivery. Recovery therefore needs an explicit cold-recovery boundary rather than an implicit live queue backup.

## Decision

Run one gateway replica with a durable, bounded queue and a documented cold-recovery procedure. Back up declarative configuration, encrypted secret source/recovery material, deployment manifests and required certificate recovery material; do not include the live queue or `/data/failed` in routine backups. Recovery must include queue assessment, duplicate-delivery handling, service health verification and an independent synthetic delivery test.

## Alternatives Considered

- Active-active gateway — deferred because it introduces shared-state, split-brain and duplicate-delivery complexity outside v1.0.
- Routine live-queue backup/restore — rejected because it creates a mail archive and increases replay/duplicate risk.
- No recovery procedure — rejected because a single instance without tested recovery cannot meet the operational baseline.

## Consequences

- Single-instance failure remains an accepted availability risk for the production minimum.
- Gate D must demonstrate cold recovery within the 60-minute RTO and document the configuration RPO.
- Operators need explicit rollback, queue assessment and credential-revocation procedures.
- A future HA or queue-replication design requires a new ADR based on measured need.
