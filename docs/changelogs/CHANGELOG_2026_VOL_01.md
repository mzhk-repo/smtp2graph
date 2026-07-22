2026-07-08 — Update System Specification
    Context:
    Change:
    Verification:
    Risks:
Rollback:





2026-07-21 — Task 1.1: inventory та quarantine початкових шаблонів
    Context: Koha-derived workflow і deploy-скрипт могли бути помилково сприйняті як готова SMTP2Graph automation.
    Change: Legacy workflow переміщено поза GitHub Actions discovery path; deploy-скрипт переміщено до quarantine, позбавлено executable bit і заблоковано fail-closed guard. Inventory keep/adapt/replace/remove додано до AI_CONTEXT.
    Verification: Перевірено відсутність активних workflow-файлів, syntax quarantined Bash-скрипта, гарантовану відмову його виконання, Koha-marker inventory та Git diff.
    Risks: Корисні orchestration patterns залишаються лише reference-кодом і потребують повторного security review перед адаптацією.
    Rollback: Повернути quarantined файли до початкових шляхів можна окремою reviewed зміною; deploy guard не знімати до реалізації Task 5.2/5.3.

2026-07-21 — Task 1.2: repository structure та local quality tooling
    Context: Repository не мав єдиної локальної команди статичної перевірки або зафіксованої структури для наступних roadmap-задач.
    Change: Додано мінімальні repository policy-файли, README, змістовні початкові файли для deploy/tests/scripts/lib/docs/adr та `make validate` з pinned Markdown, YAML і shfmt hooks. Gitleaks і ShellCheck залишено в CI без локального дублювання.
    Verification: `make validate`, `bash -n scripts/validate.sh` і `git diff --check` виконано успішно.
    Risks: Перший `make bootstrap` потребує мережевого доступу до pinned upstream repositories; generated `.venv` і cache виключені з Git.
    Rollback: Видалити додані tooling/policy files та каталоги окремою reviewed зміною; production/runtime state відсутній.

2026-07-22 — Task 1.3: configuration contract і безпечний `.env.example`
    Context: Потрібен був перевірний контракт public inputs і secret references без фіксації непідтвердженої SMTP2Graph schema або production values.
    Change: Додано experimental `.env.example`, machine-checkable список ключів, strict example-only validator і negative shell test. `.env` та `.env.*` ігноруються Git, окрім tracked `.env.example`.
    Verification: `./scripts/verify-env.sh --example-only`, `./tests/shell/test-verify-env.sh`, `make validate` і `git diff --check` виконано успішно.
    Risks: Contract не є upstream runtime schema та може змінитися після Gate B; production SOPS/age і Docker Secrets lifecycle визначаються лише в наступних security tasks.
    Rollback: Видалити contract, validator і test окремою reviewed зміною; production secrets або runtime state не створювалися.

2026-07-22 — Task 1.4: AI context, changelog policy та documentation map
    Context: Документаційні артефакти вже існували, але roadmap не мав компактної phase map з явними умовами переходу.
    Change: На початку `docs/ROADMAP.md` додано список Phase 1–8, результати фаз, entry/exit conditions і переходи через Phase Quality Gates та Gate B/C/D. AI_CONTEXT синхронізовано з documentation baseline.
    Verification: Перевірено внутрішні phase links, наявність README/AI_CONTEXT/changelog/documentation map і `git diff --check`.
    Risks: Phase map є навігаційним summary; детальні acceptance criteria залишаються у відповідних phase/task sections.
    Rollback: Видалити додану Phase Map section і Task 1.4 changelog entry окремою reviewed зміною; source requirements не змінювалися.

2026-07-22 — Task 2.1: ADR baseline та component decision
    Context: Архітектурні та security-рішення були погоджені в SPEC, але ще не мали окремих довготривалих decision records.
    Change: Створено ADR-0001…ADR-0007 та індекс ADR. Зафіксовано SMTP-to-Graph boundary, single-node Swarm, sender mailbox, mailbox-scoped Graph authorization, runtime secrets, single-instance topology і cold recovery; ADR-0002 залишено Proposed до Gate B.
    Verification: Перевірено обов’язкові ADR sections, статуси, roadmap/SPEC links, Markdown lint, `git diff --check` і secret scan.
    Risks: ADR-0002 не є підтвердженням upstream component readiness; production implementation залишається заблокованою до Gate B.
    Rollback: Proposed ADR можна уточнити за результатами qualification; Accepted decisions змінюються лише новим superseding ADR.

2026-07-22 — Уточнення ADR-0004: sender mailbox policy
    Context: Початковий MVP використовує одного відправника, але production-вимога потребує ізоляції поштових ідентичностей між сервісами.
    Change: ADR-0004 уточнено: `noreply@ldubgd.edu.ua` використовується лише для MVP, а перед production кожен сервіс отримує окрему dedicated mailbox і sender allowlist.
    Verification: Перевірено ADR sections, синхронізацію з AI_CONTEXT, Markdown lint і `git diff --check`.
    Risks: Production onboarding потребуватиме створення та окремого lifecycle для кількох mailbox identities.
    Rollback: MVP policy залишається доступною як тимчасовий режим; production mailbox model змінюється лише окремим superseding ADR.

2026-07-22 — Task 2.2: pinned SMTP2Graph qualification candidate
    Context: Gate B потребував exact release, immutable image digest і supply-chain evidence до runtime qualification.
    Change: Зафіксовано SMTP2Graph v1.1.5 та multi-platform digest у `deploy/config/gateway-version.md`; додано registry/release metadata, license note, platform manifests і qualification status. ADR-0002 залишається Proposed.
    Verification: Registry manifest inspection, digest-pinned pull, image metadata review, upstream release/Dockerfile review і repository validation виконані; Trivy/Syft/Cosign evidence ще не отримано.
    Risks: Відсутність vulnerability scan, SBOM/signature verification і non-root evidence блокує Gate B та production use.
    Rollback: Видалити candidate artifact і повернути ADR-0002 до стану без pinned candidate; production runtime не змінювався.

2026-07-22 — Roadmap: Syft SBOM перед production
    Context: Фінальний release pipeline потребує відтворюваного software inventory перед Production Deployment Gate.
    Change: У Task 6.3, Release Candidate Gate і Production Deployment Gate додано обов’язкову генерацію CycloneDX SBOM через Syft з exact image digest, hash/immutable artifact retention та pre-deploy verification.
    Verification: Перевірено структуру roadmap і Markdown validation; runtime pipeline не змінювався.
    Risks: Release блокується, якщо Syft artifact відсутній, не відповідає digest або не має immutable retention.
    Rollback: Вилучення candidate/release artifact не повинно обходити SBOM gate; pipeline changes відкочуються окремим reviewed commit.

2026-07-22 — Task 2.3: runtime, secrets і container compatibility spike
    Context: SMTP2Graph v1.1.5 потребував evidence для secret-file rendering, non-root/read-only execution і lifecycle signals до protocol qualification.
    Change: Додано tmpfs-only runtime wrapper і isolated Docker acceptance probe з synthetic certificate та client-secret fallback. Probe перевіряє UID/GID 65532, read-only rootfs, dropped capabilities, no-new-privileges, listener, graceful stop/restart і відсутність synthetic secret у inspect/logs.
    Verification: `./tests/acceptance/runtime/run.sh`, shell syntax checks, `make validate`, `git diff --check` і Gitleaks виконано успішно.
    Risks: Probe працює з `network=none` і synthetic inputs; він не доводить Graph token acquisition, actual delivery, Swarm Secret ownership або queue semantics.
    Rollback: Видалити prototype wrapper і acceptance probe окремою reviewed зміною; production runtime та production secrets не створювалися.

2026-07-22 — Task 2.4: protocol, MIME, queue та acknowledgement qualification
    Context: Gate B потребував фактичних evidence для MIME preservation, SMTP acknowledgement, queue restart і Graph failure behavior без production tenant.
    Change: Додано isolated TLS token/Graph mock, synthetic MIME fixture та protocol/failure-injection harness. Створено `docs/TEST_PLAN.md` із behavior matrix і Gate B gaps.
    Verification: MIME, BCC injection, UTF-8, attachment, SMTP acknowledgement ordering і queue restart пройшли; failure injection підтвердив bounded HTTP 500 retry та виявив два blocker-и.
    Risks: SMTP2Graph v1.1.5 ігнорує Graph `Retry-After` та залишає `ErrorAccessDenied` payload у queue, а не у failed state; actual Microsoft 365 evidence ще відсутній.
    Rollback: Видалити synthetic harness/fixtures окремою reviewed зміною; ADR-0002 не переводити в Accepted і production runtime не створювати.
