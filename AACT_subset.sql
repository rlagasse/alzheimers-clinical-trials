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
CREATE TABLE alzheimer_subset.conditions AS
SELECT DISTINCT *
FROM ctgov.conditions
WHERE name LIKE 'Alzheimer%'
  AND name NOT LIKE '%or&';


 -- Studies (3136 rows)
CREATE TABLE alzheimer_subset.studies AS
SELECT DISTINCT s.*
FROM ctgov.studies s
JOIN alzheimer_subset.conditions c
  ON s.nct_id = c.nct_id;


-- Countries of Study Origin
CREATE TABLE alzheimer_subset.countries AS
SELECT DISTINCT c.*
FROM ctgov.countries c
JOIN alzheimer_subset.studies s
  ON c.nct_id = s.nct_id;


-- Designs (Purpose of Study)
CREATE TABLE alzheimer_subset.designs AS
SELECT DISTINCT d.*
FROM ctgov.designs d
JOIN alzheimer_subset.studies s
  ON d.nct_id = s.nct_id;


-- Facilities (City, State)
CREATE TABLE alzheimer_subset.facilities AS
SELECT DISTINCT f.*
FROM ctgov.facilities f
JOIN alzheimer_subset.studies s
  ON f.nct_id = s.nct_id;
  

-- Interventions (Intervention Type)
CREATE TABLE alzheimer_subset.interventions AS
SELECT DISTINCT i.*
FROM ctgov.interventions i
JOIN alzheimer_subset.studies s
  ON i.nct_id = s.nct_id;

-- Study Outcome Counts of Participants
CREATE TABLE alzheimer_subset.outcome_counts AS
SELECT DISTINCT oc.*
FROM ctgov.outcome_counts oc
JOIN alzheimer_subset.studies s
  ON oc.nct_id = s.nct_id;


-- Sponsors
CREATE TABLE alzheimer_subset.sponsors AS
SELECT DISTINCT sp.*
FROM ctgov.sponsors sp
JOIN alzheimer_subset.studies s
  ON sp.nct_id = s.nct_id;


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





