# Tests

Тестові каталоги створюються разом із першими реальними test cases відповідної roadmap-задачі. Fixtures не повинні містити production secrets, реальні MIME bodies або sensitive headers.

Єдина локальна точка входу для поточних статичних перевірок:

```bash
make validate
```
