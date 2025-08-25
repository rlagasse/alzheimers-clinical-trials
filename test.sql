CREATE EXTENSION IF NOT EXISTS pgtap;

select plan(2);

SELECT has_table('conditions');
-- , 'Table "conditions" should exist');
-- SELECT has_column('conditions', 'nct_id', 'Table "conditions" should have column "nct_id"');

SELECT * FROM finish();