-- Runtime: 51msec
CREATE EXTENSION IF NOT EXISTS pgtap;


SET search_path TO alzheimer_subset, ctgov, public;

BEGIN;

-- Number of Tests to Run
SELECT plan(47);

-- (1) Ensure the correct schemas are in place
SELECT schemas_are(ARRAY[ 'public', 'ctgov', 'alzheimer_subset']);
 
-- (9) Validate all 8 necessary tables exist
SELECT has_table('alzheimer_subset.conditions', 'subset must have table "conditions"');
SELECT has_table('alzheimer_subset.countries', 'subset must have table "countries"');
SELECT has_table('alzheimer_subset.designs', 'subset must have table "designs"');
SELECT has_table('alzheimer_subset.facilities', 'subset must have table "facilities"');
SELECT has_table('alzheimer_subset.interventions', 'subset must have table "interventions"');
SELECT has_table('alzheimer_subset.outcome_counts', 'subset must have table "outcome_counts"');
SELECT has_table('alzheimer_subset.sponsors', 'subset must have table "sponsors"');
SELECT has_table('alzheimer_subset.studies', 'subset must have table "studies"');
SELECT is((SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'alzheimer_subset' AND table_type = 'BASE TABLE')::integer, 8::integer, 'Schema "alzheimer_subset" should only have 8 tables');

-- (7) All tables (besides studies) should have a primary key to link to studies
SELECT has_pk('alzheimer_subset', 'conditions', '"conditions" must have a primary key');
SELECT has_pk('alzheimer_subset', 'countries',  '"countries" must have a primary key');
SELECT has_pk('alzheimer_subset', 'designs', '"designs" must have a primary key');
SELECT has_pk('alzheimer_subset', 'facilities', '"facilities" must have a primary key');
SELECT has_pk('alzheimer_subset', 'interventions', '"interventions" must have a primary key');
SELECT has_pk('alzheimer_subset', 'outcome_counts', '"outcome_counts" must have a primary key');
SELECT has_pk('alzheimer_subset', 'sponsors', '"sponsors" must have a primary key');

-- (7) studies table PK is nct_id, all other tables have id as PK but also have nct_id to properly link to studies
SELECT col_is_pk('alzheimer_subset.conditions', 'id', '"conditions" must have "id" as primary key');
SELECT col_is_pk('alzheimer_subset.countries', 'id', '"countries" must have "id" as primary key');
SELECT col_is_pk('alzheimer_subset.designs', 'id', '"designs" must have "id" as primary key');
SELECT col_is_pk('alzheimer_subset.facilities', 'id', '"facilities" must have "id" as primary key');
SELECT col_is_pk('alzheimer_subset.interventions', 'id', '"interventions" must have "id" as primary key');
SELECT col_is_pk('alzheimer_subset.outcome_counts', 'id', '"outcome_counts" must have "id" as primary key');
SELECT col_is_pk('alzheimer_subset.sponsors', 'id', '"sponsors" must have "id" as primary key');

-- (8) Validate nct_id column exists in all but studies table; the foreign key to link to studies table
SELECT has_column('alzheimer_subset.conditions', 'nct_id', '"conditions" must have foreign key "nct_id"');
SELECT has_column('alzheimer_subset.countries', 'nct_id',  '"countries" must have foreign key "nct_id"');
SELECT has_column('alzheimer_subset.designs', 'nct_id', '"designs" must have foreign key "nct_id"');
SELECT has_column('alzheimer_subset.facilities', 'nct_id', '"facilities" must have foreign key "nct_id"');
SELECT has_column('alzheimer_subset.interventions', 'nct_id', '"interventions" must have foreign key "nct_id"');
SELECT has_column('alzheimer_subset.outcome_counts', 'nct_id', '"outcome_counts" must have foreign key "nct_id"');
SELECT has_column('alzheimer_subset.sponsors', 'nct_id', '"sponsors" must have foreign key "nct_id"');
SELECT has_column('alzheimer_subset.studies', 'nct_id', '"studies" must have foreign key "nct_id"');


-- (8) Ensure that foreign key nct_id columns have no NULL values
SELECT is_empty('SELECT 1 FROM alzheimer_subset.conditions WHERE nct_id IS NULL', 'Table "conditions" can not have NULL values in column "nct_id"');
SELECT is_empty('SELECT 1 FROM alzheimer_subset.countries WHERE nct_id IS NULL', 'Table "countries" can not have NULL values in column "nct_id"');
SELECT is_empty('SELECT 1 FROM alzheimer_subset.designs WHERE nct_id IS NULL', 'Table "designs" can not have NULL values in column "nct_id"');
SELECT is_empty('SELECT 1 FROM alzheimer_subset.facilities WHERE nct_id IS NULL', 'Table "facilities" can not have NULL values in column "nct_id"');
SELECT is_empty('SELECT 1 FROM alzheimer_subset.interventions WHERE nct_id IS NULL', 'Table "interventions" can not have NULL values in column "nct_id"');
SELECT is_empty('SELECT 1 FROM alzheimer_subset.outcome_counts WHERE nct_id IS NULL', 'Table "outcome_counts" can not have NULL values in column "nct_id"');
SELECT is_empty('SELECT 1 FROM alzheimer_subset.sponsors WHERE nct_id IS NULL', 'Table "sponsors" can not have NULL values in column "nct_id"');
SELECT is_empty('SELECT 1 FROM alzheimer_subset.studies WHERE nct_id IS NULL', 'Table "studies" can not have NULL values in column "nct_id"');


-- (7) Ensure that primary key id columns have no NULL values; exception for studies table
SELECT is_empty('SELECT 1 FROM alzheimer_subset.conditions WHERE id IS NULL', 'Table "conditions" can not have NULL values in column "id"');
SELECT is_empty('SELECT 1 FROM alzheimer_subset.countries WHERE id IS NULL', 'Table "countries" can not have NULL values in column "id"');
SELECT is_empty('SELECT 1 FROM alzheimer_subset.designs WHERE id IS NULL', 'Table "designs" can not have NULL values in column "id"');
SELECT is_empty('SELECT 1 FROM alzheimer_subset.facilities WHERE id IS NULL', 'Table "facilities" can not have NULL values in column "id"');
SELECT is_empty('SELECT 1 FROM alzheimer_subset.interventions WHERE id IS NULL', 'Table "interventions" can not have NULL values in column "id"');
SELECT is_empty('SELECT 1 FROM alzheimer_subset.outcome_counts WHERE id IS NULL', 'Table "outcome_counts" can not have NULL values in column "id"');
SELECT is_empty('SELECT 1 FROM alzheimer_subset.sponsors WHERE id IS NULL', 'Table "sponsors" can not have NULL values in column "id"');
-- SELECT is_empty('SELECT 1 FROM alzheimer_subset.studies WHERE id IS NULL', 'Table "studies" can not have NULL values in column "id"');



SELECT pass('All tests passed');
SELECT fail('Not all tests passed');
SELECT * FROM finish();

ROLLBACK;







