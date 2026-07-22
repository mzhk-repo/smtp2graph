# smtp2graph

Приватний SMTP-to-Microsoft Graph gateway для внутрішніх сервісів. Проєкт перебуває на етапі створення repository baseline; production runtime ще не реалізований, а Gate B для SMTP2Graph ще не пройдений.

## Документація

- [`docs/SPEC.md`](docs/SPEC.md) — погоджені вимоги та security baseline.
- [`docs/ROADMAP.md`](docs/ROADMAP.md) — порядок реалізації та quality gates.
- [`docs/AI_CONTEXT.md`](docs/AI_CONTEXT.md) — компактний актуальний контекст.
- [`CHANGELOG.md`](CHANGELOG.md) — індекс томів changelog.

## Локальні prerequisites

- GNU Make 4.3 або новіший;
- Git;
- Python 3.12 із модулем `venv`;
- мережевий доступ лише під час першого завантаження pinned development hooks.

## Безпечні локальні команди

Підготувати ізольований toolchain у `.venv/` і `.cache/pre-commit/`:

```bash
make bootstrap
```

Запустити non-mutating перевірки Markdown, YAML, shell formatting і whitespace:

```bash
make validate
```

`make validate` не читає `.env` файли, не отримує secrets і не звертається до Docker або production. `gitleaks` і `ShellCheck` виконуються на CI-рівні з конфігураціями `.gitleaks.toml` та `.shellcheckrc`.

## Deployment safety

Активного deployment workflow або SMTP2Graph orchestrator у repository ще немає. Koha-derived assets ізольовані в quarantine й не повинні виконуватися. Production deployment дозволений лише після відповідних roadmap gates і reviewed IaC.
