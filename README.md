# GoIT RDB Final Project — PostgreSQL

Проєкт аналізу статистики інфекційних захворювань із датасету `infectious_cases.csv`.

## Завдання
1. Створення схеми `pandemic` та імпорт CSV у `infectious_cases`.
2. Нормалізація до 3НФ: `entities` (унікальні пари Entity/Code) та `infectious_cases_normalized` (показники з `entity_id` як зовнішнім ключем).
3. AVG, MIN, MAX, SUM для `Number_rabies` за країною/кодом, сортування за середнім, TOP 10.
4. Створення дати 1 січня року спостереження та обчислення різниці років.
5. Функції `calculate_years_difference` та `calculate_average_cases`, використані в запитах.

## Як запустити
1. Створити порожню базу даних `goit_rdb_fp` у PostgreSQL.
2. У `final_project.sql` виконати блок створення схеми та вихідної таблиці.
3. Через pgAdmin → Import/Export Data імпортувати `infectious_cases.csv` у `pandemic.infectious_cases` (CSV, UTF8, Header=Yes, delimiter `,`).
4. Виконати решту SQL-коду за порядком. **INSERT у нормалізовану таблицю виконувати лише один раз**, інакше виникнуть дублікати.
5. Перевірити кількість рядків у вихідній та нормалізованій таблицях (у використаному датасеті — 10521).

## Файли
- `final_project.sql` — SQL для всіх п’яти завдань.
- `screenshots/` — знімки результатів у pgAdmin.
- `infectious_cases.csv` — вихідний датасет (додати локально, якщо його немає в архіві).

Технології: PostgreSQL 17, pgAdmin 4, SQL.
