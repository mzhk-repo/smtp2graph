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
