-- Subset checker help function
CREATE OR REPLACE FUNCTION subset_checker (
    alzheimer_subset text,
    ctgov text,
    table_of_interest text
)

RETURNS SETOF TEXT AS $$

DECLARE
    total_count integer;
	
BEGIN

    EXECUTE format(
        'SELECT COUNT(*) FROM %I.%I EXCEPT SELECT * FROM %I.%I',
        alzheimer_subset, table_of_interest, ctgov, table_of_interest
    ) INTO total_count;

    RETURN QUERY

	-- pTAP function
    SELECT is(
        total_count::integer,
        0::integer,
        format(
            'Table "%s.%s" is a subset of "%s.%s"',
            schema1, tablename, schema2, tablename
        )
    );
END;
$$ LANGUAGE plpgsql;

