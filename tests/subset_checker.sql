-- Subset checker help function. Used on all tables but studies as id column should be the primary key in all.
CREATE OR REPLACE FUNCTION subset_checker (
    alzheimer_subset text,
    ctgov text,
    table_of_interest text
)

-- Return as test message for pass/fail
RETURNS SETOF TEXT AS 
$$

DECLARE
    key_count integer;
	
BEGIN
    -- Count how many primary keys that are in alzheimer_subset that aren't in ctgov; should eqal 0
    EXECUTE format(
        'SELECT COUNT(*) FROM %I.%I AS keys
         WHERE keys.id NOT IN (SELECT id FROM %I.%I)',
        alzheimer_subset, table_of_interest,
        ctgov, table_of_interest
    ) INTO key_count;

    -- Return a single pTAP test result
    RETURN QUERY
    SELECT is(
        key_count,
        0::integer,
        format('All records (checked by primary keys) in Schema %I Table %I exist in Schema %I Table %I', alzheimer_subset, table_of_interest, ctgov, table_of_interest)
    );

END;
$$ LANGUAGE plpgsql;

