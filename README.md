# Global Analysis of Alzheimer Clinical Trials

This project involves the processing, testing, analysis and presentation of Alzheiemr clinical trial data from ClinicalTrials.gov. This project utilizes the open-source AACT database (https://aact.ctti-clinicaltrials.org/).

## Steps:

### postgreSQL
1. Download AACT database and restore a complete copy on postgreSQL using pgAdmin 4
2. Install pgTAP, a testing framework for SQL for use in unit and validation tests

## postgreSQL

1. run the AACT_subset.sql script
  - this creates a subset of the AACT database for Alzheimer-only clinical trials called alzheimer_subset, and focuses on 8/52 tables from AACT: **conditions, countries, designs, facilities, interventions, outcome_counts, sponsors and studies**.

### Unit Tests

1. run the tests/ptap_unit_tests.sql script
  - this tests the schema generation of alzheimer_subset
   
#### Test Case Summary

  - Validates the correct schemas exist in the database
alzheimer_subset test cases
  - the correct tables and number of tables exist (8 tables total)
  - all tables have the correct primary key (nct_id for studies table, id for the rest)
  - all tables have the correct foreign key (N/A for studies table, nct_id for the rest)
  - in alzheimer_subset, each table has the nct_id column to act as the foreign key
  - Primary key id/nct_id columns have no null values
  - Foreign key columns have no null values

### Validation Tests

1. Run the tests/subset_checker_function.sql script
- This creates the subset_checker function. subset_checker(subset_schema_name, set_schema_name, subset_table_name, set_table_name, col) tests whether a specific table in subset_schema_name is a subset of the table form set_schema_name, joined on col. 
3. Run the tests/ptap_validation_tests.sql script
- This tests the correct information is preserved between AACT's schema (ctgov) and alzheimer_subset
 
#### Test Case Summary

- alzheimer_subset tables has the same columnns as ctvgov tables
- using subset_checker(), all 8 tables in alzheimer_subset are subsets of the matching original ctgov tables.
- using subset_checker(), all 7 tables in alzheimer_subset have all their nct_id records as subsets of the parent studies table, i.e. every sponsor from sponsors has a corresponding study in the studies table.


