library(testthat)

# list of all non-study tables
non_study_tables <- list(
    clean_conditions = clean_conditions,
    clean_countries = clean_countries,
    clean_designs = clean_designs,
    clean_facilities = clean_facilities,
    clean_interventions = clean_interventions,
    clean_outcome_counts = clean_outcome_counts,
    clean_sponsors = clean_sponsors
)



# 1. studies: number of known trials remains consistent (3005 Alzheimer trials)
expected_trial_count <- 3005
test_that("clean_studies: Total trial count matches expected", {
  expect_equal(nrow(clean_studies), expected_trial_count)
})


# 2a. studies: every nct_id is unique
test_that("clean_studies: all values have a unique nct_id", {
  expect_equal(nrow(clean_studies), length(unique(clean_studies$nct_id)))
})

# 2b. non_studies tables: every nct_id matches one in clean_studies
test_that("All tables have nct_id values present in clean_studies", {
  for (table in names(non_study_tables)) {
    # get df from string name
    df <- non_study_tables[[table]]

    # all non_study nct_id's should exist in clean_studies
    invalid_ids <- setdiff(df$nct_id, clean_studies$nct_id)
    expect_true(
      length(invalid_ids) == 0,
      info = paste0("Invalid nct_id that doesn't match clean_studies found in table ", tbl_name)
    )}
})


# 3. studies: no non-zero or negative enrollment values
test_that("clean_studies: enrollment values are non-negative and greater than 0" , {
  expect_true(all(clean_studies$enrollment >= 0))
})


# 4. All tables have been cleaned properly. only NA and no string values
check_invalid_unknown <- function(df, df_str) {
    for (col in colnames(df)) {
        test_that(paste0(df_str, " has only NA for unknown/null values in ", col), {

            # no unallowed unknown values in df, all standardized to NA
            expect_false(any(df[[col]] %in% c("NA", "Unknown", "")),
            info = paste0("Invalid value found in table ", df, " and column ", col))
        })
    }
}

check_invalid_unknown(clean_conditions, "clean_conditions")
check_invalid_unknown(clean_countries, "clean_countries")
check_invalid_unknown(clean_designs, "clean_designs")
check_invalid_unknown(clean_facilities, "clean_facilities")
check_invalid_unknown(clean_interventions, "clean_interventions")
check_invalid_unknown(clean_outcome_counts, "clean_outcome_counts")
check_invalid_unknown(clean_sponsors, "clean_sponsors")
check_invalid_unknown(clean_studies, "clean_studies")


# 5: studies: completion date - start_date >= 0
test_that("Completion date is after start date", {
    # take out all null date values
    clean_studies_dates <- clean_studies %>% 
    filter(start_date != as.Date("1900-01-01") & completion_date != as.Date("1900-01-01"))
  
    expect_true(all(clean_studies_dates$completion_date >= clean_studies_dates$start_date))
})