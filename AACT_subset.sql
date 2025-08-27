CREATE SCHEMA IF NOT EXISTS alzheimer_subset;

DROP TABLE IF EXISTS alzheimer_subset.conditions CASCADE;
DROP TABLE IF EXISTS alzheimer_subset.countries CASCADE;
DROP TABLE IF EXISTS alzheimer_subset.designs CASCADE;
DROP TABLE IF EXISTS alzheimer_subset.facilities CASCADE;
DROP TABLE IF EXISTS alzheimer_subset.interventions CASCADE;
DROP TABLE IF EXISTS alzheimer_subset.outcome_counts CASCADE;
DROP TABLE IF EXISTS alzheimer_subset.sponsors CASCADE;
DROP TABLE IF EXISTS alzheimer_subset.studies CASCADE;

-- -- Conditions (Alzheimer) 3136 rows
CREATE TABLE IF NOT EXISTS alzheimer_subset.conditions (LIKE ctgov.conditions INCLUDING DEFAULTS INCLUDING CONSTRAINTS);

INSERT INTO alzheimer_subset.conditions
SELECT DISTINCT *
FROM ctgov.conditions AS c
WHERE c.name LIKE 'Alzheimer%'
AND c.name NOT LIKE '%or&';

 -- Studies (3136 rows)
CREATE TABLE IF NOT EXISTS alzheimer_subset.studies (LIKE ctgov.studies INCLUDING DEFAULTS INCLUDING CONSTRAINTS);

INSERT INTO alzheimer_subset.studies
SELECT DISTINCT s.*
FROM ctgov.studies AS s
JOIN alzheimer_subset.conditions as c
	ON s.nct_id = c.nct_id;



-- Countries of Study Origin
CREATE TABLE IF NOT EXISTS alzheimer_subset.countries (LIKE ctgov.countries INCLUDING DEFAULTS INCLUDING CONSTRAINTS);

INSERT INTO alzheimer_subset.countries
SELECT DISTINCT c.*
FROM ctgov.countries AS c
JOIN alzheimer_subset.studies AS s
  ON c.nct_id = s.nct_id;


-- Designs (Purpose of Study)
CREATE TABLE IF NOT EXISTS alzheimer_subset.designs (LIKE ctgov.designs INCLUDING DEFAULTS INCLUDING CONSTRAINTS);

INSERT INTO alzheimer_subset.designs
SELECT DISTINCT d.*
FROM ctgov.designs AS d
JOIN alzheimer_subset.studies AS s
  ON d.nct_id = s.nct_id;

-- Facilities (City, State)
CREATE TABLE IF NOT EXISTS alzheimer_subset.facilities (LIKE ctgov.facilities INCLUDING DEFAULTS INCLUDING CONSTRAINTS);

INSERT INTO alzheimer_subset.facilities
SELECT DISTINCT f.*
FROM ctgov.facilities AS f
JOIN alzheimer_subset.studies AS s
  ON f.nct_id = s.nct_id;

-- Interventions (Intervention Type)
CREATE TABLE IF NOT EXISTS alzheimer_subset.interventions (LIKE ctgov.interventions INCLUDING DEFAULTS INCLUDING CONSTRAINTS);

INSERT INTO alzheimer_subset.interventions
SELECT DISTINCT i.*
FROM ctgov.interventions AS i
JOIN alzheimer_subset.studies AS s
  ON i.nct_id = s.nct_id;


-- Study Outcome Counts of Participants
CREATE TABLE IF NOT EXISTS alzheimer_subset.outcome_counts (LIKE ctgov.outcome_counts INCLUDING DEFAULTS INCLUDING CONSTRAINTS);

INSERT INTO alzheimer_subset.outcome_counts
SELECT DISTINCT c.*
FROM ctgov.outcome_counts AS c
JOIN alzheimer_subset.studies AS s
  ON c.nct_id = s.nct_id;


-- Sponsors
CREATE TABLE IF NOT EXISTS alzheimer_subset.sponsors (LIKE ctgov.sponsors INCLUDING DEFAULTS INCLUDING CONSTRAINTS);

INSERT INTO alzheimer_subset.sponsors
SELECT DISTINCT p.*
FROM ctgov.sponsors AS p
JOIN alzheimer_subset.studies AS s
  ON p.nct_id = s.nct_id;




-- Creating constraints:
-- Declare primary keys: nct_id in studies table, id in the rest
ALTER TABLE alzheimer_subset.conditions ADD CONSTRAINT conditions_pkey PRIMARY KEY (id);
ALTER TABLE alzheimer_subset.countries ADD CONSTRAINT countries_pkey PRIMARY KEY (id);
ALTER TABLE alzheimer_subset.designs ADD CONSTRAINT designs_pkey PRIMARY KEY (id);
ALTER TABLE alzheimer_subset.facilities ADD CONSTRAINT facilities_pkey PRIMARY KEY (id);
ALTER TABLE alzheimer_subset.interventions ADD CONSTRAINT interventions_pkey PRIMARY KEY (id);
ALTER TABLE alzheimer_subset.outcome_counts ADD CONSTRAINT outcome_counts_pkey PRIMARY KEY (id);
ALTER TABLE alzheimer_subset.sponsors ADD CONSTRAINT sponsors_pkey PRIMARY KEY (id);
ALTER TABLE alzheimer_subset.studies ADD CONSTRAINT studies_pkey PRIMARY KEY (nct_id);


-- Declare foreign keys: nct_id in all tables to reference studies table
ALTER TABLE alzheimer_subset.conditions ADD CONSTRAINT conditions_fkey FOREIGN KEY (nct_id) REFERENCES alzheimer_subset.studies(nct_id) ON DELETE CASCADE;
ALTER TABLE alzheimer_subset.countries ADD CONSTRAINT countries_fkey FOREIGN KEY (nct_id) REFERENCES alzheimer_subset.studies(nct_id) ON DELETE CASCADE;
ALTER TABLE alzheimer_subset.designs ADD CONSTRAINT designs_fkey FOREIGN KEY (nct_id) REFERENCES alzheimer_subset.studies(nct_id) ON DELETE CASCADE;
ALTER TABLE alzheimer_subset.facilities ADD CONSTRAINT facilities_fkey FOREIGN KEY (nct_id) REFERENCES alzheimer_subset.studies(nct_id) ON DELETE CASCADE;
ALTER TABLE alzheimer_subset.interventions ADD CONSTRAINT interventions_fkey FOREIGN KEY (nct_id) REFERENCES alzheimer_subset.studies(nct_id) ON DELETE CASCADE;
ALTER TABLE alzheimer_subset.outcome_counts ADD CONSTRAINT outcome_counts_fkey FOREIGN KEY (nct_id) REFERENCES alzheimer_subset.studies(nct_id) ON DELETE CASCADE;
ALTER TABLE alzheimer_subset.sponsors ADD CONSTRAINT sponsors_fkey FOREIGN KEY (nct_id) REFERENCES alzheimer_subset.studies(nct_id) ON DELETE CASCADE;

-- Ensure nct_id is NOT NULL in all tables
ALTER TABLE alzheimer_subset.conditions ALTER COLUMN nct_id SET NOT NULL;
ALTER TABLE alzheimer_subset.countries ALTER COLUMN nct_id SET NOT NULL;
ALTER TABLE alzheimer_subset.designs ALTER COLUMN nct_id SET NOT NULL;
ALTER TABLE alzheimer_subset.facilities ALTER COLUMN nct_id SET NOT NULL;
ALTER TABLE alzheimer_subset.interventions ALTER COLUMN nct_id SET NOT NULL;
ALTER TABLE alzheimer_subset.outcome_counts ALTER COLUMN nct_id SET NOT NULL;
ALTER TABLE alzheimer_subset.sponsors ALTER COLUMN nct_id SET NOT NULL;
ALTER TABLE alzheimer_subset.studies ALTER COLUMN nct_id SET NOT NULL;





