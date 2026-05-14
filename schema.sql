-- ============================================================
-- J&J Health for Humanity ESG Goals Tracker
-- SQL Schema · Lunarix Technologies LLC · Yiduo Xiao
-- Compatible with: PostgreSQL, SQLite, MySQL
-- ============================================================

-- 1. ESG GOALS MASTER TABLE
CREATE TABLE esg_goals (
    goal_id         INTEGER PRIMARY KEY,
    pillar          TEXT NOT NULL,          -- 'Environmental' | 'Social' | 'Governance'
    category        TEXT NOT NULL,          -- 'Carbon' | 'Packaging' | 'Water' | 'Supplier' | 'Workforce'
    goal_name       TEXT NOT NULL,
    goal_description TEXT,
    baseline_year   INTEGER,
    baseline_value  REAL,
    target_value    REAL,
    target_year     INTEGER,
    unit            TEXT,                   -- 'metric tons CO2e' | '%' | 'MWh' | etc.
    source_doc      TEXT,                   -- 'Health for Humanity Report 2023'
    is_active       INTEGER DEFAULT 1
);

-- 2. ANNUAL PERFORMANCE DATA
CREATE TABLE esg_actuals (
    actual_id       INTEGER PRIMARY KEY,
    goal_id         INTEGER NOT NULL REFERENCES esg_goals(goal_id),
    reporting_year  INTEGER NOT NULL,
    actual_value    REAL NOT NULL,
    data_source     TEXT,                   -- 'Annual ESG Report' | 'CDP Disclosure' | 'SEC Filing'
    assurance_level TEXT,                   -- 'Third-party assured' | 'Management estimate'
    notes           TEXT,
    created_at      TEXT DEFAULT (datetime('now'))
);

-- 3. COMPETITOR BENCHMARKS
CREATE TABLE competitor_benchmarks (
    benchmark_id    INTEGER PRIMARY KEY,
    company         TEXT NOT NULL,          -- 'Johnson & Johnson' | 'Merck' | 'BMS' | 'Pfizer'
    category        TEXT NOT NULL,
    reporting_year  INTEGER NOT NULL,
    metric_name     TEXT NOT NULL,
    metric_value    REAL,
    unit            TEXT,
    source          TEXT
);

-- 4. SUPPLIER SUSTAINABILITY
CREATE TABLE supplier_sustainability (
    supplier_id         INTEGER PRIMARY KEY,
    reporting_year      INTEGER NOT NULL,
    total_suppliers     INTEGER,
    ecovadis_assessed   INTEGER,
    ecovadis_pct        REAL,
    high_risk_identified INTEGER,
    high_risk_remediated INTEGER,
    region              TEXT
);

-- 5. FACILITY-LEVEL EMISSIONS (for drill-down)
CREATE TABLE facility_emissions (
    facility_id     INTEGER PRIMARY KEY,
    facility_name   TEXT NOT NULL,
    country         TEXT,
    region          TEXT,                   -- 'Americas' | 'EMEA' | 'Asia Pacific'
    business_unit   TEXT,                   -- 'Innovative Medicine' | 'MedTech'
    reporting_year  INTEGER NOT NULL,
    scope1_mtco2e   REAL,
    scope2_mtco2e   REAL,
    renewable_pct   REAL,
    water_use_m3    REAL,
    waste_kg        REAL
);

-- ============================================================
-- SEED DATA (from J&J public ESG reports 2019-2023)
-- ============================================================

INSERT INTO esg_goals VALUES
(1,'Environmental','Carbon','Carbon Neutral Operations (Scope 1+2)','Achieve carbon neutrality across all global operations',2019,7500000,0,2030,'metric tons CO2e','Health for Humanity 2025 Goals',1),
(2,'Environmental','Carbon','Net-Zero Emissions (Full Value Chain)','Net-zero across Scope 1, 2, and 3',2019,20000000,0,2045,'metric tons CO2e','Health for Humanity 2025 Goals',1),
(3,'Environmental','Energy','Renewable Energy','100% renewable electricity for global operations',2019,40,100,2025,'%','Health for Humanity 2025 Goals',1),
(4,'Environmental','Packaging','Recyclable Packaging','100% recyclable, reusable, or compostable packaging',2020,60,100,2025,'%','Health for Humanity 2025 Goals',1),
(5,'Environmental','Water','Water Replenishment','Replenish 100% of water used in water-stressed regions',2020,75,100,2025,'%','Health for Humanity 2025 Goals',1),
(6,'Governance','Supplier','Supplier Sustainability Coverage','Suppliers assessed via EcoVadis or equivalent',2020,70,100,2025,'%','Health for Humanity 2025 Goals',1),
(7,'Social','Workforce','Employee Health Coverage','Global employees with access to health insurance',2020,95,100,2025,'%','Health for Humanity 2025 Goals',1),
(8,'Environmental','Waste','Zero Waste to Landfill','Manufacturing sites achieving zero waste to landfill',2020,55,100,2030,'%','Health for Humanity 2025 Goals',1);

INSERT INTO esg_actuals VALUES
-- Scope 1+2 Carbon (goal_id=1), millions metric tons
(1,1,2019,7500000,'Annual ESG Report','Third-party assured',NULL,NULL),
(2,1,2020,6800000,'Annual ESG Report','Third-party assured',NULL,NULL),
(3,1,2021,6200000,'Annual ESG Report','Third-party assured',NULL,NULL),
(4,1,2022,5800000,'Annual ESG Report','Third-party assured','Includes renewable energy purchases',NULL),
(5,1,2023,5200000,'Annual ESG Report','Third-party assured','Continued facility efficiency gains',NULL),
-- Renewable Energy % (goal_id=3)
(6,3,2019,40,'CDP Disclosure','Third-party assured',NULL,NULL),
(7,3,2020,54,'CDP Disclosure','Third-party assured',NULL,NULL),
(8,3,2021,66,'CDP Disclosure','Third-party assured',NULL,NULL),
(9,3,2022,68,'CDP Disclosure','Third-party assured',NULL,NULL),
(10,3,2023,70,'CDP Disclosure','Third-party assured','New solar + wind contracts signed',NULL),
-- Recyclable Packaging % (goal_id=4)
(11,4,2020,60,'Annual ESG Report','Management estimate',NULL,NULL),
(12,4,2021,72,'Annual ESG Report','Third-party assured',NULL,NULL),
(13,4,2022,78,'Annual ESG Report','Third-party assured',NULL,NULL),
(14,4,2023,82,'Annual ESG Report','Third-party assured','Strong progress in consumer segment',NULL),
-- Water Replenishment % (goal_id=5)
(15,5,2020,75,'Annual ESG Report','Third-party assured',NULL,NULL),
(16,5,2021,86,'Annual ESG Report','Third-party assured',NULL,NULL),
(17,5,2022,91,'Annual ESG Report','Third-party assured',NULL,NULL),
(18,5,2023,95,'Annual ESG Report','Third-party assured','Near target in most regions',NULL),
-- Supplier EcoVadis % (goal_id=6)
(19,6,2020,70,'Annual ESG Report','Management estimate',NULL,NULL),
(20,6,2021,82,'Annual ESG Report','Third-party assured',NULL,NULL),
(21,6,2022,88,'Annual ESG Report','Third-party assured',NULL,NULL),
(22,6,2023,93,'Annual ESG Report','Third-party assured','42,800+ suppliers in program',NULL);

INSERT INTO competitor_benchmarks VALUES
(1,'Johnson & Johnson','Carbon',2023,'Scope 1+2 mtCO2e',5200000,'metric tons','CDP 2023'),
(2,'Merck','Carbon',2023,'Scope 1+2 mtCO2e',4800000,'metric tons','CDP 2023'),
(3,'Bristol Myers Squibb','Carbon',2023,'Scope 1+2 mtCO2e',3100000,'metric tons','CDP 2023'),
(4,'Pfizer','Carbon',2023,'Scope 1+2 mtCO2e',6400000,'metric tons','CDP 2023'),
(5,'Johnson & Johnson','Energy',2023,'Renewable %',70,'%','CDP 2023'),
(6,'Merck','Energy',2023,'Renewable %',80,'%','CDP 2023'),
(7,'Bristol Myers Squibb','Energy',2023,'Renewable %',100,'%','CDP 2023'),
(8,'Pfizer','Energy',2023,'Renewable %',62,'%','CDP 2023');

-- ============================================================
-- KEY ANALYTICAL VIEWS
-- ============================================================

CREATE VIEW v_goal_progress AS
SELECT
    g.goal_id,
    g.pillar,
    g.category,
    g.goal_name,
    g.target_value,
    g.target_year,
    g.unit,
    a.reporting_year,
    a.actual_value,
    ROUND(
        CASE
            WHEN g.target_value = 0 THEN
                ROUND((g.baseline_value - a.actual_value) / g.baseline_value * 100, 1)
            ELSE
                ROUND(a.actual_value / g.target_value * 100, 1)
        END, 1
    ) AS pct_to_goal,
    ROUND(g.target_value - a.actual_value, 0) AS gap_to_goal
FROM esg_goals g
JOIN esg_actuals a ON g.goal_id = a.goal_id
WHERE g.is_active = 1;

CREATE VIEW v_latest_performance AS
SELECT *
FROM v_goal_progress
WHERE (goal_id, reporting_year) IN (
    SELECT goal_id, MAX(reporting_year)
    FROM esg_actuals
    GROUP BY goal_id
);

CREATE VIEW v_yoy_trend AS
SELECT
    g.category,
    g.goal_name,
    a.reporting_year,
    a.actual_value,
    LAG(a.actual_value) OVER (PARTITION BY g.goal_id ORDER BY a.reporting_year) AS prior_year,
    ROUND(
        (a.actual_value - LAG(a.actual_value) OVER (PARTITION BY g.goal_id ORDER BY a.reporting_year))
        / LAG(a.actual_value) OVER (PARTITION BY g.goal_id ORDER BY a.reporting_year) * 100, 1
    ) AS yoy_change_pct
FROM esg_goals g
JOIN esg_actuals a ON g.goal_id = a.goal_id
ORDER BY g.goal_id, a.reporting_year;
