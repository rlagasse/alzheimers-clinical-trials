install.packages("DBI")
install.packages("RPostgres")
install.packages("dplyr")

library(DBI)
library(RPostgres)
library(dplyr)


con <- dbConnect(
  RPostgres::Postgres(),
  dbname = Sys.getenv("DB_NAME"),
  port = 5432,
  host = Sys.getenv("DB_HOST"),
  user = Sys.getenv("DB_USERNAME"),
  password = Sys.getenv("DB_PASSWORD"),
  sslmode = "require"
)

# Schema alzheimer_subset alias
subset_query <- function(table) {
  dbGetQuery(con, paste0("SELECT * FROM alzheimer_subset.", table))
}



# Process all tables into dataframes
df_conditions <- subset_query("conditions")
df_countries <- subset_query("countries")
df_designs <- subset_query("designs")
df_facilities <- subset_query("facilities")
df_interventions <- subset_query("interventions")
df_outcome_counts <- subset_query("outcome_counts")
df_sponsors <- subset_query("sponsors")
df_studies <- subset_query("studies")

# Columns to keep & analyze for each dataframe
conditions_cols <- c("id", "nct_id", "name")
countries_cols <- c("id", "nct_id", "name")
designs_cols <- c("id", "nct_id", "allocation", "primary_purpose")
facilities_cols <- c("id", "nct_id", "name", "city", "state", "country", "latitude", "longitude")
interventions_cols <- c("id", "nct_id", "intervention_type", "name")
outcome_counts_cols <- c("nct_id", "outcome_id", "units", "count")
sponsors_cols <- c("id", "nct_id", "name", "agency_class")
studies_cols <- c("nct_id", "phase", "start_date", "completion_date", "overall_status", "enrollment", "study_type", "source")


clean_conditions <- df_conditions %>% 
  select(all_of(conditions_cols)) %>% 
  distinct(nct_id, name, .keep_all=TRUE) %>%
  mutate(
    name = ifelse(is.na(name) | name %in% c("NA", "Unknown", ""), NA, name),
    disease_name = "Alzheimer's Disease"
  )



# Countries
clean_countries <- df_countries %>%
  select(all_of(countries_cols)) %>%
  distinct(nct_id, name, .keep_all=TRUE) %>%
  mutate(
    name = case_when(is.na(name) | name %in% c("NA", "Unknown", "") ~ NA, name == "Korea, Republic of" ~ "South Korea", TRUE ~ name)) %>%
    ungroup() %>%
  group_by(name) %>%
  mutate(trials_per_country = n()) %>%
  ungroup()


# Designs
clean_designs <- df_designs %>% 
  select(all_of(designs_cols)) %>%
  distinct(nct_id, allocation, primary_purpose, .keep_all=TRUE) %>%
  mutate(
    allocation = ifelse(is.na(allocation) | allocation %in% c("NA", "Unknown", ""), NA, allocation),
    primary_purpose = ifelse(is.na(primary_purpose) | primary_purpose %in% c("NA", "Unknown", ""), NA, primary_purpose)
  ) %>%
    ungroup() %>%

  group_by(primary_purpose) %>%
  mutate(trials_per_primary_purpose = n()) %>%
  ungroup()


# Facilities
clean_facilities <- df_facilities %>%
  select(all_of(facilities_cols)) %>%
  distinct() %>%
  mutate(
    name = ifelse(is.na(name) | name %in% c("NA", "Unknown", ""), NA, name),
    city = ifelse(is.na(city) | city %in% c("NA", "Unknown", ""), NA, city),
    state = ifelse(is.na(state) | state %in% c("NA", "Unknown", ""), NA, state),
    country = ifelse(is.na(country) | country %in% c("NA", "Unknown", ""), NA, country),
    latitude = ifelse(is.na(latitude), NA, latitude),
    longitude = ifelse(is.na(country), NA, longitude)
  ) %>%
    ungroup() %>%

  group_by(country) %>%
  mutate(facilities_per_country = n()) %>%
  ungroup()%>%

  group_by(city) %>%
  mutate(facilities_per_city = n()) %>%
  ungroup() %>%

  group_by(name) %>%
  mutate(trials_per_facility = n()) %>%
  ungroup()


# Interventions
clean_interventions <- df_interventions %>% 
  select(all_of(interventions_cols)) %>%
  distinct(nct_id, name, .keep_all=TRUE) %>%
  mutate(
    name = ifelse(is.na(name) | name %in% c("NA", "Unknown", ""), NA, name),
    intervention_type = ifelse(is.na(intervention_type) | intervention_type %in% c("NA", "Unknown", ""), NA, intervention_type)
  ) %>%

  group_by(intervention_type) %>%
  mutate(trials_per_intervention_type = n()) %>%
  ungroup()


# Outcome Counts
clean_outcome_counts <- df_outcome_counts %>% 
  select(all_of(outcome_counts_cols)) %>%
  distinct() %>%
  mutate(
    units = ifelse(is.na(units) | units %in% c("NA", "Unknown", ""), NA, units),
    count = ifelse(is.na(count), 0, count)
  )


# Sponsors
clean_sponsors <- df_sponsors %>% 
  select(all_of(sponsors_cols)) %>%
  distinct(nct_id, name, .keep_all=TRUE) %>%
  mutate(
    name = ifelse(is.na(name) | name %in% c("NA", "Unknown", ""), NA, name),
    agency_class = ifelse(is.na(agency_class) | agency_class %in% c("NA", "Unknown", ""), NA, agency_class)
  ) %>%

  group_by(agency_class) %>%
  mutate(trials_per_agency_class = n()) %>%
  ungroup()%>%

  group_by(nct_id) %>%
  mutate(sponsors_per_trial = n()) %>%
  ungroup() %>%

  group_by(name) %>%
  mutate(trials_per_sponsor = n()) %>%
  ungroup()


# Studies: all studies are distinct
clean_studies <- df_studies %>% 
  select(all_of(studies_cols)) %>%
  mutate(
    phase = ifelse(is.na(phase) | phase %in% c("NA", "Unknown", ""), NA, phase),
    start_date = coalesce(as.Date(start_date), as.Date("1900-01-01")),
    completion_date = coalesce(as.Date(completion_date), as.Date("1900-01-01")),
    overall_status = ifelse(is.na(overall_status) | overall_status %in% c("NA", "Unknown", ""), NA, overall_status),
    enrollment = ifelse(is.na(enrollment), 0, as.numeric(enrollment)),
    study_type = ifelse(is.na(study_type) | study_type %in% c("NA", "Unknown", ""), NA, study_type),
    source = ifelse(is.na(source) | source %in% c("NA", "Unknown", ""), NA, source),
    
    # Adding additional columns and dates, months, years for studies
    duration_days = as.numeric(completion_date - start_date),
    duration_months = (duration_days / 30),
    start_year = as.numeric(format(start_date, "%Y")),
    start_month = as.numeric(format(start_date, "%m")),
    completion_year = as.numeric(format(completion_date, "%Y")),
    completion_month = as.numeric(format(completion_date, "%m")),

    # string identifier for trial enrollments 
    enrollment_category = case_when(
      enrollment < 10 ~ "<10",
      enrollment >= 10 & enrollment < 20 ~ "10-19",
      enrollment >= 20 & enrollment < 30 ~ "20-29", 
      enrollment >= 30 & enrollment < 40 ~ "30-39",
      enrollment >= 40 & enrollment < 50 ~ "40-49",
      enrollment >= 50 & enrollment < 60 ~ "50-59",
      enrollment >= 60 & enrollment < 70 ~ "60-69", 
      enrollment >= 70 & enrollment < 80 ~ "70-79",
      enrollment >= 80 & enrollment < 90 ~ "80-89",
      enrollment >= 90 & enrollment < 100 ~ "90-99",
      enrollment >= 100 & enrollment < 200 ~ "100-199",
      enrollment >= 200 & enrollment < 500 ~ "200-499",
      enrollment >= 500 & enrollment < 1000 ~ "599-999",
      enrollment >= 1000 & enrollment < 2000 ~ "1000-1999",
      enrollment >= 2000 & enrollment < 3000 ~ "2000-2999",
      enrollment >= 3000 & enrollment < 5000 ~ "3000-4999",
      enrollment >= 5000 & enrollment < 10000 ~ "5000-9999",
      enrollment >= 10000 ~ ">=10000", 
      ),

    # add flag for ongoing and finished trials. 1 for trial finished, 0 for trial ongoing
    trial_is_complete = ifelse(overall_status %in% c("COMPLETED", "TERMINATED"), 1, 0)
  ) %>%

    # aggregates with other tables. trials per phase, enrollment per phrase, trials per year
    group_by(phase) %>%
    mutate(
      trials_per_phase = n(),
      avg_enrollment_per_phase = mean(enrollment),
    ) %>%

    ungroup() %>%

    group_by(start_year) %>%
    mutate(trials_per_year = n()) %>%
    ungroup() %>%

    group_by(study_type) %>%
    mutate(enrollment_per_study_type = n()) %>%
    ungroup()

# write all dataframes to .csv files
write.csv(clean_conditions, "../clinical_trial_data/conditions.csv", row.names = FALSE)
write.csv(clean_countries, "../clinical_trial_data/countries.csv", row.names = FALSE)
write.csv(clean_designs, "../clinical_trial_data/designs.csv", row.names = FALSE)
write.csv(clean_facilities, "../clinical_trial_data/facilities.csv", row.names = FALSE)
write.csv(clean_interventions, "../clinical_trial_data/interventions.csv", row.names = FALSE)
write.csv(clean_outcome_counts, "../clinical_trial_data/outcome_counts.csv", row.names = FALSE)
write.csv(clean_sponsors, "../clinical_trial_data/sponsors.csv", row.names = FALSE)
write.csv(clean_studies, "../clinical_trial_data/studies.csv", row.names = FALSE)

library(testthat)
test_dir("tests")

dbDisconnect(con)