-- CREATE SCHEMA alzheimer_subset;


-- Conditions (Alzheimer) 3136 rows
CREATE TABLE alzheimer_subset.conditions AS
SELECT *
FROM ctgov.conditions AS c
WHERE c.name LIKE 'Alzheimer%'
AND c.name NOT LIKE '%or&';

-- Studies (3136 rows)
CREATE TABLE alzheimer_subset.studies AS
SELECT s.*
FROM ctgov.studies AS s
JOIN alzheimer_subset.conditions as c
	ON s.nct_id = c.nct_id

-- Countries of Study Origin
CREATE TABLE alzheimer_subset.countries AS
SELECT c.*
FROM ctgov.countries AS c
JOIN alzheimer_subset.studies AS s
  ON c.nct_id = s.nct_id;

-- Study Outcome Counts of Participants
CREATE TABLE alzheimer_subset.outcome_counts AS
SELECT c.*
FROM ctgov.outcome_counts AS c
JOIN alzheimer_subset.studies AS s
  ON c.nct_id = s.nct_id;

-- Sponsors
CREATE TABLE alzheimer_subset.sponsors AS
SELECT p.*
FROM ctgov.sponsors AS p
JOIN alzheimer_subset.studies AS s
  ON p.nct_id = s.nct_id;

-- Interventions (Intervention Type)
CREATE TABLE alzheimer_subset.interventions AS
SELECT i.*
FROM ctgov.interventions AS i
JOIN alzheimer_subset.studies AS s
  ON i.nct_id = s.nct_id;

-- Facilities (City, State)
CREATE TABLE alzheimer_subset.facilities AS
SELECT f.*
FROM ctgov.facilities AS f
JOIN alzheimer_subset.studies AS s
  ON f.nct_id = s.nct_id;

-- Designs (Purpose of Study)
CREATE TABLE alzheimer_subset.designs AS
SELECT d.*
FROM ctgov.designs AS d
JOIN alzheimer_subset.studies AS s
  ON d.nct_id = s.nct_id;

