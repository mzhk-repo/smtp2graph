# AI_CONTEXT.md

## Project Summary

`smtp2graph` is an infrastructure project for a private SMTP-to-Microsoft Graph gateway. It enables Grafana, Moodle, DSpace, Koha, and Matomo to send mail through Microsoft 365 while Microsoft Entra Security Defaults remain enabled. The target is a secure, maintainable production minimum, not a general-purpose mail platform.

The planned initial gateway candidate is SMTP2Graph. This is not yet an accepted production component: it must pass Gate B qualification before implementation relies on it.

## Current Status

- The project is in the planning stage; no production gateway implementation is present.
- `docs/SPEC.md` defines the approved requirements baseline.
- `docs/ROADMAP.md` defines the implementation sequence, quality gates, and acceptance work.
- `docs/AI_CONTEXT.md` is the compact entry point for future agents.
- Task 1.1 inventory is complete. The Koha-derived GitHub workflow and deployment script are quarantined outside their executable paths and are not SMTP2Graph-ready. They may be replaced or selectively adapted only through a reviewed roadmap task.

## Key Decisions

- Use Microsoft Graph application-only authentication; do not enable Exchange Online SMTP AUTH, app passwords, mailbox passwords, or Security Defaults exceptions.
- Production minimum is one SMTP gateway instance on a single-node Docker Swarm host.
- Use one dedicated sender mailbox initially: `noreply@ldubgd.edu.ua`.
- Restrict application `Mail.Send` to the approved mailbox through Exchange Online RBAC for Applications.
- Prefer certificate-based Graph credentials if the pinned gateway supports safe file-based use; a runtime client secret is an explicitly documented fallback.
- Use Docker Secrets mounted at `/run/secrets/`. Encrypted static environment material uses SOPS + age; plaintext production secrets must not persist in Git, images, `.env` files, CI artifacts, logs, or container environment.
- Deploy a pinned image digest, not a mutable image tag.
- SMTP ingress is internal only. TLS is mandatory for Moodle and all routed SMTP traffic. Plain SMTP inside Swarm is allowed only after verifying an encrypted overlay network.
- The service has no admin UI, custom HTTP API, database, external message broker, Kubernetes, or active-active HA in v1.0.

## Architecture Snapshot

```text
Allowed internal SMTP clients
  -> internal firewall/network policy
  -> SMTP-to-Graph gateway (SMTP auth, IP/sender/size/rate policy)
  -> bounded persistent queue and privacy-safe operational logs
  -> Microsoft Entra token endpoint (HTTPS)
  -> Microsoft Graph sendMail (HTTPS)
  -> Exchange Online

Independent monitoring checks gateway health and synthetic delivery.
```

The target queue is durable but bounded to 1 GiB. At 80% utilization, new SMTP sessions or `MAIL FROM` submissions must receive a temporary `421` or `451` response and must not be accepted into the queue. For Graph HTTP `429`, qualification and tests must confirm handling of `Retry-After` with bounded exponential backoff.

## Tech Stack

- Gateway candidate: SMTP2Graph, exact version and digest pending Gate B.
- Runtime/orchestration: Docker Swarm, single node, one service replica.
- Secrets: Docker Secrets, SOPS + age.
- Identity and mail delivery: Microsoft Entra ID, Microsoft Graph, Exchange Online RBAC for Applications.
- Configuration/deployment: reviewed declarative Swarm manifests and idempotent shell scripts.
- CI/CD: protected branches and protected production environment; exact provider workflow must be rebuilt from the current template.
- Observability: VictoriaMetrics and Grafana, plus an independent notification channel.

## Security Constraints

- Never add secrets, tokens, private keys, SMTP passwords, decrypted SOPS content, or sensitive MIME samples to the repository, test fixtures, logs, command arguments, or CI output.
- Do not expose SMTP publicly or use host networking, privileged containers, Docker socket mounts, or mutable production tags.
- Enforce deny-by-default source IP/subnet, unique SMTP credentials, exact sender allowlist, a 25 MiB message limit, and rate/session limits.
- Graph authorization must prove allowed-mailbox success and out-of-scope mailbox denial before production.
- Run non-root where the chosen image supports it; use least privilege, `no-new-privileges`, dropped capabilities, and a read-only root filesystem when compatible.
- `/data/queue` is restricted to the service identity and operators. `/data/failed` must use mode `0700` and failed payloads are purged after at most 7 days.
- Do not log message bodies, attachments, tokens, passwords, reset URLs, or sensitive headers.
- Planned backups exclude `/data/queue` and `/data/failed`; restoring queue state can cause duplicate delivery.

## Repository Structure

```text
docs/
  SPEC.md          # requirements and source of truth
  ROADMAP.md       # implementation plan and gates
  AI_CONTEXT.md    # this compact context
scripts/
  quarantine/
    deploy-orchestrator-swarm.koha.sh.disabled  # non-executable, fail-closed legacy template
.github/quarantine/
  main.koha.yml.disabled  # outside the GitHub Actions workflow discovery path
```

Expected future paths are defined in the roadmap: `deploy/swarm/`, `deploy/config/`, `deploy/monitoring/`, `tests/`, `docs/adr/`, `docs/RUNBOOK.md`, `docs/TEST_PLAN.md`, and `docs/scripts_runbook.md`.

## Initial Template Inventory

| Asset | Decision | Rationale and reusable scope |
|---|---|---|
| `.github/quarantine/main.koha.yml.disabled` | Replace | Unsafe as an SMTP2Graph workflow: it had automatic deployment triggers, Koha/Ansible inputs, broad secret forwarding, and a reusable workflow pinned to mutable `@main`. Environment separation and the reusable-workflow concept may be reconsidered later with immutable pins and least privilege. |
| `scripts/quarantine/deploy-orchestrator-swarm.koha.sh.disabled` | Replace | Unsafe as an SMTP2Graph orchestrator: it contains Koha/MariaDB volume assumptions, missing local dependencies, and active Docker Swarm mutation paths. Repository-root resolution, strict Bash mode, cleanup traps, and staged validation are patterns to adapt only after review. |
| `docs/hello-world.md` | Remove | Ignored local prompt scratchpad, not project documentation. Removal is deferred because the working tree already contains a user change. |
| `.gitignore` | Keep | Correctly keeps the local prompt scratchpad out of future commits; extend it only as real generated or secret-bearing paths are introduced. |

The runtime-mounted `.agents/` and `.codex/` directories are empty environment artifacts, not tracked project templates. Git metadata is outside the template inventory.

## Important Documents

| Document | Purpose | Priority |
|---|---|---|
| `docs/SPEC.md` | Requirements, architecture, security baseline, production acceptance, approval gates | Highest |
| `docs/ROADMAP.md` | Ordered implementation tasks, files, checks, risks, rollback notes | High |
| `docs/adr/ADR-*.md` | Accepted long-lived architectural decisions, once created | High for covered decisions |
| `docs/RUNBOOK.md` | Operating, deploy, recovery, and incident procedures, once created | Operational source of truth |
| `docs/TEST_PLAN.md` | Detailed test cases and evidence, once created | Test source of truth |

If this file conflicts with `docs/SPEC.md`, `docs/ROADMAP.md`, or an applicable ADR, the source document takes precedence. Resolve ambiguity by updating the source document first, then this file when the change affects compact agent context.

## Implementation Rules for AI Agents

1. Read this file first, then read the smallest relevant source section before changing anything.
2. Follow the roadmap order. Do not implement production deployment before Gate B; do not use production authorization before Gate C; do not release before Gate D.
3. Make small, reviewable, idempotent changes. Validate each change with the task-specific commands from the roadmap.
4. Do not invent upstream SMTP2Graph behavior. Qualify secret-file support, non-root/read-only compatibility, SMTP acknowledgement semantics, queue durability, Graph `Retry-After`, MIME/BCC/attachment behavior, and display-name behavior with evidence.
5. Use IaC and reviewed automation for infrastructure changes. Avoid manual production configuration.
6. Classify scripts as validation, deploy-adjacent, or autonomous. Do not `source` an orchestrator environment file; use strict parsing or pass it directly to tools.
7. Keep documentation focused. Update SPEC for approved requirement changes, ADRs for durable decisions, RUNBOOK for operational changes, and this file after accepted ADRs or material milestones.
8. Preserve unrelated working-tree changes. Do not reset, overwrite, or delete user work.

## Known Assumptions

- Grafana, DSpace, Koha, and Matomo run on the same Docker Swarm host; Moodle runs on another VM under the same hypervisor.
- Normal mail volume is below 10 messages per minute. Per-client baseline limits are five concurrent sessions per IP and 30 messages per minute; Moodle needs an additional throttle decision.
- Messages may contain password-reset links and limited personal data.
- Operational logs are retained for 30 days. Failed payloads are retained for at most 7 days. Security/audit metadata is retained for 30 days.
- Availability target is 99.5% per month. RTO is 60 minutes. Configuration RPO assumption is 24 hours.
- Direct TCP/443 egress to Microsoft identity endpoints and Microsoft Graph is available; no HTTP proxy is required.
- VictoriaMetrics + Grafana is the selected monitoring stack. Entra client-secret and TLS-certificate expiry alerts must warn at 30 days and be critical at 7 days.

## Open Questions

- Which exact SMTP2Graph release and immutable digest pass Gate B?
- Does that release safely support certificate-file authentication and a tmpfs-rendered runtime configuration?
- What are its exact SMTP acknowledgement, durable queue, `Retry-After`, dead-letter, and downgrade compatibility semantics?
- What TLS certificate source and trust model will clients use?
- What non-production test tenant/mailbox and recipient allowlist are available?
- What is the final independent alert transport and who owns on-call response?
- Does Exchange Online preserve client-provided display names for the single sender mailbox?
- What approved SOPS age recipient, recovery custody, CI trust boundary, and secret naming convention will be used?

## Last Updated

2026-07-21 — Updated after Task 1.1 inventory and fail-closed quarantine of the Koha-derived deployment assets.
