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
