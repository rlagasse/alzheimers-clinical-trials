CREATE EXTENSION IF NOT EXISTS pgtap;

-- table subset checker helper function, between ctgov and alzheimer_subset
\i subset_checker.sql

SET search_path TO alzheimer_subset, ctgov, public;

BEGIN;

-- 2 tests per table +1 for schema check: table exists and it shares the same number of columns as ctgov
SELECT plan(33);

-- (1) Ensure the correct schemas are in place
SELECT schemas_are(ARRAY[ 'public', 'ctgov', 'alzheimer_subset']);
 
-- (8) Validate all 8 necessary tables exist
SELECT has_table('alzheimer_subset.conditions', 'subset must have table "conditions"');
SELECT has_table('alzheimer_subset.countries', 'subset must have table "countries"');
SELECT has_table('alzheimer_subset.designs', 'subset must have table "designs"');
SELECT has_table('alzheimer_subset.facilities', 'subset must have table "facilities"');
SELECT has_table('alzheimer_subset.interventions', 'subset must have table "interventions"');
SELECT has_table('alzheimer_subset.outcome_counts', 'subset must have table "outcome_counts"');
SELECT has_table('alzheimer_subset.sponsors', 'subset must have table "sponsors"');
SELECT has_table('alzheimer_subset.studies', 'subset must have table "studies"');

-- (8) studies table PK is nct_id, all other tables have id as PK but also have nct_id to properly link to studies
SELECT col_is_pk('alzheimer_subset.countries', 'id', '"countries" must have "id" as primary key');
SELECT col_is_pk('alzheimer_subset.designs', 'id', '"designs" must have "id" as primary key');
SELECT col_is_pk('alzheimer_subset.facilities', 'id', '"facilities" must have "id" as primary key');
SELECT col_is_pk('alzheimer_subset.interventions', 'id', '"interventions" must have "id" as primary key');
SELECT col_is_pk('alzheimer_subset.outcome_counts', 'id', '"outcome_counts" must have "id" as primary key');
SELECT col_is_pk('alzheimer_subset.sponsors', 'id', '"sponsors" must have "id" as primary key');
SELECT col_is_pk('alzheimer_subset.studies', 'nct_id', '"studies" must have "nct_id" as primary key');


-- (7) Validate nct_id column exists in all but studies table; the foreign key to link to studies table
SELECT has_column('alzheimer_subset.conditions', 'nct_id', '"conditions" must have foreign key "nct_id"');
SELECT has_column('alzheimer_subset.countries', 'nct_id',  '"countries" must have foreign key "nct_id"');
SELECT has_column('alzheimer_subset.designs', 'nct_id', '"designs" must have foreign key "nct_id"');
SELECT has_column('alzheimer_subset.facilities', 'nct_id', '"facilities" must have foreign key "nct_id"');
SELECT has_column('alzheimer_subset.interventions', 'nct_id', '"interventions" must have foreign key "nct_id"');
SELECT has_column('alzheimer_subset.outcome_counts', 'nct_id', '"outcome_counts" must have foreign key "nct_id"');
SELECT has_column('alzheimer_subset.sponsors', 'nct_id', '"sponsors" must have foreign key "nct_id"');


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

-- (8) Validate that alzheimer_subset is a subset of ctvgov
SELECT * FROM subset_checker('alzheimer_subset', 'ctgov', 'conditions');
SELECT * FROM subset_checker('alzheimer_subset', 'ctgov', 'countries');
SELECT * FROM subset_checker('alzheimer_subset', 'ctgov', 'designs');
SELECT * FROM subset_checker('alzheimer_subset', 'ctgov', 'facilities');
SELECT * FROM subset_checker('alzheimer_subset', 'ctgov', 'interventions');
SELECT * FROM subset_checker('alzheimer_subset', 'ctgov', 'outcome_counts');
SELECT * FROM subset_checker('alzheimer_subset', 'ctgov', 'sponsors');
SELECT * FROM subset_checker('alzheimer_subset', 'ctgov', 'studies');

-- SELECT is(
-- 	(SELECT COUNT(*)::integer
-- 	FROM 
-- 	(
-- 	SELECT * FROM alzheimer_subset.studies
-- 	EXCEPT
-- 	SELECT * FROM ctgov.studies )
-- 	),
-- 	0,
-- 	'Schema "alzheimer_subset" Table "studies" is not a subset of Schema "ctgov" Table "studies"'
-- );

SELECT pass('All tests passed');
SELECT fail('Not all tests passed');
SELECT * FROM finish();

ROLLBACK;







