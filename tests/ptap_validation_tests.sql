-- Run subset_checker.sql first to install helper function subset_checker
CREATE EXTENSION IF NOT EXISTS pgtap;

SET search_path TO alzheimer_subset, ctgov, public;

BEGIN;

-- Number of Tests to Run
SELECT plan(9);


-- (1) Validate alzheimer_subset preserves the same 8 tables and all columns from original schema ctgov
SELECT set_eq(
	$$
	SELECT column_name
	FROM information_schema.columns
	WHERE table_schema = 'ctvgov' AND table_name IN ('conditions', 'countries', 'designs', 'facilities', 'interventions', 'outcome_counts', 'sponsors', 'studies')
	$$,
	
	$$
	SELECT column_name
	FROM information_schema.columns
	WHERE table_schema = 'alzheimer_subset' AND table_name IN ('conditions', 'countries', 'designs', 'facilities', 'interventions', 'outcome_counts', 'sponsors', 'studies')
	
	$$,
	'Table "ctgov" and Table "alzheimer_subset" do not share the same columns'
);

-- (8) Validate that alzheimer_subset is a subset of ctvgov. Takes primary key as argument
SELECT * FROM subset_checker('alzheimer_subset', 'ctgov', 'conditions');
SELECT * FROM subset_checker('alzheimer_subset', 'ctgov', 'countries');
SELECT * FROM subset_checker('alzheimer_subset', 'ctgov', 'designs');
SELECT * FROM subset_checker('alzheimer_subset', 'ctgov', 'facilities');
SELECT * FROM subset_checker('alzheimer_subset', 'ctgov', 'interventions');
SELECT * FROM subset_checker('alzheimer_subset', 'ctgov', 'outcome_counts');
SELECT * FROM subset_checker('alzheimer_subset', 'ctgov', 'sponsors');
-- SELECT * FROM subset_checker('alzheimer_subset', 'ctgov', 'studies');
-- Note: studies has no public key as it uses nct_id as per https://aact.ctti-clinicaltrials.org/schema#idInformation


-- (7) Ensure each record in each table matches an nct_id in studies table
-- SELECT is(
-- 	$$
-- 	SELECT COUNT(*) 
-- 	FROM alzheimer_subset.conditions c
-- 	LEFT JOIN alzheimer_subset.studies s ON c.nct_id = s.nct_id
-- 	WHERE s.nct_id IS NULL $$,
-- 	0::integer,
-- 	'Table "conditions" must have matching "nct_id" records to Table "studies"'
-- );


SELECT pass('All tests passed');
SELECT fail('Not all tests passed');
SELECT * FROM finish();

ROLLBACK;