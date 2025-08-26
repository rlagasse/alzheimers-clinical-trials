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

-- (8) Validate that each table in alzheimer_subset is a subset of the table in ctvgov, based on primary key id.
SELECT * FROM subset_checker('alzheimer_subset', 'ctgov', 'conditions', 'conditions', 'id');
SELECT * FROM subset_checker('alzheimer_subset', 'ctgov', 'countries', 'countries', 'id');
SELECT * FROM subset_checker('alzheimer_subset', 'ctgov', 'designs', 'designs', 'id');
SELECT * FROM subset_checker('alzheimer_subset', 'ctgov', 'facilities', 'facilities', 'id');
SELECT * FROM subset_checker('alzheimer_subset', 'ctgov', 'interventions', 'interventions', 'id');
SELECT * FROM subset_checker('alzheimer_subset', 'ctgov', 'outcome_counts', 'outcome_counts', 'id');
SELECT * FROM subset_checker('alzheimer_subset', 'ctgov', 'sponsors', 'sponsors', 'id');
-- SELECT * FROM subset_checker('alzheimer_subset', 'ctgov', 'studies', 'studies', 'id');
-- Note: studies has no public key as it uses nct_id as per https://aact.ctti-clinicaltrials.org/schema#idInformation


-- (7) Check each record in each table in alzheimer_subset matches an nct_id in alzheimer_subset's studies table
SELECT * FROM subset_checker('alzheimer_subset', 'alzheimer_subset', 'conditions', 'studies', 'nct_id');
SELECT * FROM subset_checker('alzheimer_subset', 'alzheimer_subset', 'countries', 'studies', 'nct_id');
SELECT * FROM subset_checker('alzheimer_subset', 'alzheimer_subset', 'designs', 'studies', 'nct_id');
SELECT * FROM subset_checker('alzheimer_subset', 'alzheimer_subset', 'facilities', 'studies', 'nct_id');
SELECT * FROM subset_checker('alzheimer_subset', 'alzheimer_subset', 'interventions', 'studies', 'nct_id');
SELECT * FROM subset_checker('alzheimer_subset', 'alzheimer_subset', 'outcome_counts', 'studies', 'nct_id');
SELECT * FROM subset_checker('alzheimer_subset', 'alzheimer_subset', 'sponsors', 'studies', 'nct_id');

SELECT pass('All tests passed');
SELECT fail('Not all tests passed');
SELECT * FROM finish();

ROLLBACK;