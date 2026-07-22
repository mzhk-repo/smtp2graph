# SMTP2Graph qualification test plan

**Status:** Gate B evidence in progress; this document does not approve production use.
**Candidate:** SMTP2Graph v1.1.5 pinned in [`deploy/config/gateway-version.md`](../deploy/config/gateway-version.md).

## Test boundary

The protocol harness uses an isolated Docker network, generated TLS material, synthetic `.invalid` mail addresses and a local TLS mock for Microsoft Entra discovery/token and Graph `sendMail`. It never contacts Microsoft 365 and does not use production credentials or message content.

```bash
./tests/acceptance/protocol/run.sh
./tests/acceptance/protocol/failure-injection.sh
```

`failure-injection.sh` currently exits non-zero by design because it records confirmed Gate B blockers.

## Behavior matrix

| Area | Result | Evidence and decision |
|---|---|---|
| SMTP acknowledgement boundary | Qualified with limitation | SMTP `250` is observed before the mock Graph request. Upstream source calls the SMTP callback after local temporary EML close, but before `MailQueue.add()` renames it into `queue`; no `fsync` durability proof exists. The boundary is therefore local temp-file close, not confirmed atomic queue persistence. |
| To, CC, BCC, Reply-To | Pass in local mock | Synthetic MIME preserves To, CC and Reply-To. SMTP envelope-only BCC is injected into the stored EML before Graph submission. Real Exchange presentation/delivery evidence remains required. |
| HTML, UTF-8 and attachment | Pass in local mock | UTF-8 HTML and a synthetic base64 attachment survive local SMTP-to-Graph payload processing. |
| Envelope/header sender and display name | Partial | Envelope sender and display name survive local EML processing. Exchange Online behavior for client-supplied display names is not yet qualified and remains a Gate B gap. |
| Queue survives restart | Pass | A message accepted in `receive` mode remains in the persistent queue across container stop/restart and is submitted after restart in `full` mode. |
| HTTP 429 retry | **Blocker** | Mock sends `Retry-After: 2`; observed retry gap is approximately 415 ms. Candidate does not honor the header. |
| HTTP 408 | Partial | Synthetic HTTP `408` leaves the message in the queue for later retry. TCP connect/overall timeout behavior is not yet measured; upstream code has fixed 10-second connect and 120-second overall timers. |
| HTTP 500 | Pass in isolated test | With retry limit `1` and retry interval `1` minute, the candidate retries once and moves the message to `failed`. |
| Graph `ErrorAccessDenied` | **Blocker** | The candidate stops retrying but leaves the permanent-failure message in `queue`, not `failed`, so the dead-letter lifecycle is incomplete. |

## Gate B blockers and open evidence

1. `Retry-After` is mandatory for Graph throttling but is not honored by the candidate.
2. A permanent Graph access-denied result is retained in queue instead of dead-letter state.
3. SMTP success precedes queue rename and no fsync boundary is proven.
4. Actual Microsoft 365 display-name behavior, certificate token acquisition, final delivery and denied-mailbox behavior require a controlled non-production tenant.
5. TCP timeout, queue state after abrupt host loss, disk threshold rejection and failed-payload retention remain future acceptance tests.

These blockers keep [ADR-0002](adr/ADR-0002-select-smtp2graph-as-initial-gateway.md) in `Proposed`. Task 2.5 must record a `reject` or an approved mitigation that does not carry Critical behavior into production.
