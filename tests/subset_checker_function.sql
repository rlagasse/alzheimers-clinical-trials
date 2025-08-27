-- Subset checker help function. Used on all tables but studies as id column should be the primary key in all.
DROP FUNCTION IF EXISTS subset_checker(text, text, text, text, text);

CREATE OR REPLACE FUNCTION subset_checker (
	subset text, 
    entireset text,
	subset_table text,
    entireset_table text,
	col text
)

-- Return as test message for pass/fail
RETURNS SETOF TEXT AS 
$$

DECLARE
    key_count integer;
	
BEGIN
    -- Count how many primary keys that are in alzheimer_subset (subset) that aren't in ctgov (full set); should equal 0
    EXECUTE format(
		 'SELECT COUNT(*) FROM %I.%I AS keys
		 WHERE NOT EXISTS 
		 (SELECT 1 FROM %I.%I AS all_keys WHERE all_keys.%I = keys.%I)'
		 ,
        subset, subset_table,
        entireset, entireset_table, col, col) 
		INTO key_count;

    -- Return a single pTAP test result for each table
    RETURN QUERY
    SELECT is(
        key_count,
        0::integer,
        format('All records checked by column %I in Schema %I Table %I exists in Schema %I Table %I', col, subset, subset_table, entireset, entireset_table)
    );

END;
$$ LANGUAGE plpgsql;

