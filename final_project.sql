-- GoIT RDB Final Project | PostgreSQL 17
-- Запускайте на новій базі goit_rdb_fp. CSV імпортуйте через pgAdmin
-- у pandemic.infectious_cases після створення таблиці нижче.
-- Якщо таблиці вже створені та заповнені, НЕ запускайте повторно INSERT.

-- Завдання 1. Схема і вихідна таблиця
CREATE SCHEMA IF NOT EXISTS pandemic;
SET search_path TO pandemic, public;
CREATE TABLE IF NOT EXISTS pandemic.infectious_cases (
    "Entity" VARCHAR(255), "Code" VARCHAR(20), "Year" INTEGER,
    "Number_yaws" TEXT, "polio_cases" TEXT, "cases_guinea_worm" TEXT,
    "Number_rabies" TEXT, "Number_malaria" TEXT, "Number_hiv" TEXT,
    "Number_tuberculosis" TEXT, "Number_smallpox" TEXT,
    "Number_cholera_cases" TEXT
);
-- Імпорт infectious_cases.csv: pgAdmin > Import/Export Data > Import,
-- CSV, UTF8, Header=Yes, Delimiter=comma.
SELECT * FROM pandemic.infectious_cases LIMIT 10;
SELECT COUNT(*) AS original_count FROM pandemic.infectious_cases;

-- Завдання 2. Нормалізація до 3НФ
CREATE TABLE IF NOT EXISTS pandemic.entities (
    id SERIAL PRIMARY KEY,
    "Entity" VARCHAR(255),
    "Code" VARCHAR(20),
    UNIQUE ("Entity", "Code")
);
INSERT INTO pandemic.entities ("Entity", "Code")
SELECT DISTINCT "Entity", "Code"
FROM pandemic.infectious_cases
ON CONFLICT ("Entity", "Code") DO NOTHING;

CREATE TABLE IF NOT EXISTS pandemic.infectious_cases_normalized (
    id SERIAL PRIMARY KEY,
    entity_id INTEGER REFERENCES pandemic.entities(id),
    "Year" INTEGER, "Number_yaws" TEXT, "polio_cases" TEXT,
    "cases_guinea_worm" TEXT, "Number_rabies" TEXT,
    "Number_malaria" TEXT, "Number_hiv" TEXT,
    "Number_tuberculosis" TEXT, "Number_smallpox" TEXT,
    "Number_cholera_cases" TEXT
);
-- Виконати лише один раз після імпорту CSV:
INSERT INTO pandemic.infectious_cases_normalized (
    entity_id, "Year", "Number_yaws", "polio_cases", "cases_guinea_worm",
    "Number_rabies", "Number_malaria", "Number_hiv",
    "Number_tuberculosis", "Number_smallpox", "Number_cholera_cases"
)
SELECT e.id, i."Year", i."Number_yaws", i."polio_cases",
       i."cases_guinea_worm", i."Number_rabies", i."Number_malaria",
       i."Number_hiv", i."Number_tuberculosis", i."Number_smallpox",
       i."Number_cholera_cases"
FROM pandemic.infectious_cases i
JOIN pandemic.entities e
  ON i."Entity" IS NOT DISTINCT FROM e."Entity"
 AND i."Code" IS NOT DISTINCT FROM e."Code";

SELECT * FROM pandemic.entities LIMIT 10;
SELECT (SELECT COUNT(*) FROM pandemic.infectious_cases) AS original_count,
       (SELECT COUNT(*) FROM pandemic.infectious_cases_normalized) AS normalized_count;
SELECT e.id AS entity_id, e."Entity", e."Code", i."Year",
       i."Number_rabies", i."Number_malaria"
FROM pandemic.infectious_cases_normalized i
JOIN pandemic.entities e ON i.entity_id = e.id
LIMIT 10;

-- Завдання 3. Агрегування Number_rabies за унікальною парою Entity/Code
SELECT e."Entity", e."Code",
       ROUND(AVG(NULLIF(TRIM(i."Number_rabies"), '')::NUMERIC), 2) AS avg_rabies,
       MIN(NULLIF(TRIM(i."Number_rabies"), '')::NUMERIC) AS min_rabies,
       MAX(NULLIF(TRIM(i."Number_rabies"), '')::NUMERIC) AS max_rabies,
       SUM(NULLIF(TRIM(i."Number_rabies"), '')::NUMERIC) AS sum_rabies
FROM pandemic.infectious_cases_normalized i
JOIN pandemic.entities e ON i.entity_id = e.id
WHERE TRIM(i."Number_rabies") ~ '^[+-]?[0-9]+(\.[0-9]+)?$'
GROUP BY e.id, e."Entity", e."Code"
ORDER BY avg_rabies DESC
LIMIT 10;

-- Завдання 4. Різниця повних років
SELECT "Year", MAKE_DATE("Year", 1, 1) AS start_date,
       CURRENT_DATE AS current_date,
       EXTRACT(YEAR FROM AGE(CURRENT_DATE, MAKE_DATE("Year", 1, 1)))::INTEGER
         AS years_difference
FROM pandemic.infectious_cases_normalized
WHERE "Year" IS NOT NULL
LIMIT 10;

-- Завдання 5. Дві користувацькі SQL-функції
CREATE OR REPLACE FUNCTION pandemic.calculate_years_difference(input_year INTEGER)
RETURNS INTEGER LANGUAGE SQL STABLE AS $$
    SELECT EXTRACT(YEAR FROM AGE(CURRENT_DATE, MAKE_DATE(input_year, 1, 1)))::INTEGER;
$$;

CREATE OR REPLACE FUNCTION pandemic.calculate_average_cases(
    cases_count NUMERIC, divisor NUMERIC
)
RETURNS NUMERIC LANGUAGE SQL IMMUTABLE AS $$
    SELECT ROUND(cases_count / NULLIF(divisor, 0), 2);
$$;

SELECT "Year", pandemic.calculate_years_difference("Year") AS years_difference
FROM pandemic.infectious_cases_normalized
WHERE "Year" IS NOT NULL
LIMIT 10;

SELECT e."Entity", i."Year", i."Number_rabies"::NUMERIC AS yearly_cases,
       pandemic.calculate_average_cases(i."Number_rabies"::NUMERIC, 12) AS monthly_average,
       pandemic.calculate_average_cases(i."Number_rabies"::NUMERIC, 4) AS quarterly_average,
       pandemic.calculate_average_cases(i."Number_rabies"::NUMERIC, 2) AS half_year_average
FROM pandemic.infectious_cases_normalized i
JOIN pandemic.entities e ON i.entity_id = e.id
WHERE NULLIF(TRIM(i."Number_rabies"), '') IS NOT NULL
  AND TRIM(i."Number_rabies") ~ '^[0-9]+(\.[0-9]+)?$'
LIMIT 10;
