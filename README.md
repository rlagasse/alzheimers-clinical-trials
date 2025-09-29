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

## Microsoft Azure
1. With Azure, create a PostgreSQLFlexibleServer database

Terminal commands:
a) create pg_dump of alzheimer data
```
pg_dump -U your_postgreSQL_username -d your_postgreSQL_database -n alzheimer_subset -Fc -f alzheimer_subset.dump
```
b) restore pg_dump to Azure database
```
pg_restore -h your_azure_db.postgres.database.azure.com -U your_azure_user -d your_postgreSQL_database --no-owner --role=your_azure_role --schema=alzheimer_subset --clean -Fc alzheimer_subset.dump
```

## Using R for Preprocessing
1. Run preprocessing.r
   - Connects to Azure cloud database, extracts tables into dataframes, preprocesses into clean_tablename, then saves each dataframe as a .csv into a folder
   - Automated Regression testing with testthat library

### Preprocessing Steps
For all tables, all unknown values are replaced with standard NA. Datetime null values eg. start_date in studies table are replaced with as.Date("1900-01-01"). Clinical trial enrollment null values are replaced with 0.

#### 1. clean_conditions Table
Columns: id, nct_id, name, disease_name

Added columns: trials_per_country


#### 2 clean_countries Table
Columns: id, nct_id, name

Added columns: N/A


#### 3. clean_designs Table
Columns: id, nct_id, allocation, primary_purpose

Added columns: trials_per_primary_purpose


#### 4. clean_facilities Table
Columns: id, nct_id, name, city, state, country, latitude, longitude

Added columns: facilities_per_country, facilities_per_city, trials_per_facility


#### 5. clean_interventions Table
Columns: id, nct_id, intervention_type, name

Added columns: trials_per_intervention_type


#### 6. clean_outcome_counts Table
Columns: id, nct_id, units, count


#### 7. clean_sponsors Table
Columns: id, nct_id, name, agency_class

Added columns: trials_per_agency_class, sponsors_per_trial, trials_per_sponsor


#### 8. clean_studies Table
Columns: id, nct_id, phase, start_date, completion_date, overall_status, enrollment, study_type, source

Added columns: duration_days (numeric), duration_months (numeric), start_year (%Y formatting), start_month (%m formatting), completion_year(%Y), completion_month (%m), enrollment_category (groupings of enrollment by # range), trial_is_complete (bool based on COMPLETED (1) or TERMINATED (0)), trials_per_phase, avg_enrollment_per_phase, trials_per_year, enrollment_per_study_type



### Automated Regression Tests
- The testing script tests/test_preprocessing.r automatically runs when preprocessing.r is run using the testthat library

## Test Summary
- studies has the same number of consistent columns (3000)
- in studies, every nct_id is unique
- in all tables besides studies, each nct_id matches a nct_id in study
- all clinical trial enrollment values are >=0
- all various unknown/empty/null values are all replaced with NA

## Power BI

- all 8 csv files are uploaded to Power BI to create visualizations













