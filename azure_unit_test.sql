
-- Validate all 8 tables of interest were made
SELECT *
FROM information_schema.tables
WHERE table_schema = 'alzheimer_subset'
AND table_name in ('conditions', 'countries', 'designs', 'facilities', 'interventions', 'outcome_counts', 'sponsors', 'studies');
