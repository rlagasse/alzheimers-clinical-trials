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
countries_cols <- c("id,", "nct_id", "name")
designs_cols <- c("id", "nct_id", "allocation", "primary_purpose")
facilities_cols <- c("id", "nct_id", "name", "city", "state", "country", "latitude", "longitude")
interventions_cols <- c("id", "nct_id", "intervention_type", "name")
outcome_counts_cols <- c("nct_id", "outcome_id", "units", "count")
sponsors_cols <- c("id", "nct_id", "name", "agency_class")
studies_cols <- c("nct_id", "phase", "start_date", "completion_date", "overall_status", "enrollment", "study_type", "source")

clean_conditions <- df_conditions %>% 
  distinct(nct_id, name, .keep_all=TRUE) %>%
  mutate(
    name = ifelse(is.na(name) | name %in% c("NA", "Unknown", ""), NA, name)
  )

# Countries
clean_countries <- df_countries %>%
  distinct(nct_id, name, .keep_all=TRUE) %>%
  mutate(
    name = ifelse(is.na(name) | name %in% c("NA", "Unknown", ""), NA, name)
  )

# Designs
clean_designs <- df_designs %>% 
  distinct(nct_id, allocation, primary_purpose, .keep_all=TRUE) %>%
  mutate(
    allocation = ifelse(is.na(allocation) | allocation %in% c("NA", "Unknown", ""), NA, allocation),
    primary_purpose = ifelse(is.na(primary_purpose) | primary_purpose %in% c("NA", "Unknown", ""), NA, primary_purpose)
  )


# Facilities
clean_facilities <- df_facilities %>% 
  distinct(nct_id, name, city, country, .keep_all=TRUE) %>%
  mutate(
    name = ifelse(is.na(name) | name %in% c("NA", "Unknown", ""), NA, name),
    city = ifelse(is.na(city) | city %in% c("NA", "Unknown", ""), NA, city),
    state = ifelse(is.na(state) | state %in% c("NA", "Unknown", ""), NA, state),
    country = ifelse(is.na(country) | country %in% c("NA", "Unknown", ""), NA, country),
    latitude = ifelse(is.na(latitude), NA, latitude),
    longitude = ifelse(is.na(country), NA, longitude)
  )


# Interventions
clean_interventions <- df_interventions %>% 
  distinct(nct_id, name, .keep_all=TRUE) %>%
  mutate(
    name = ifelse(is.na(name) | name %in% c("NA", "Unknown", ""), NA, name),
    intervention_type = ifelse(is.na(intervention_type) | intervention_type %in% c("NA", "Unknown", ""), NA, intervention_type)
  )

# Outcome Counts
clean_outcome_counts <- df_outcome_counts %>% 
  distinct(nct_id, outcome_id, .keep_all=TRUE) %>%
  mutate(
    units = ifelse(is.na(units) | units %in% c("NA", "Unknown", ""), NA, units),
    count = ifelse(is.na(count), 0, count)
  )

# Sponsors
clean_sponsors <- df_sponsors %>% 
  distinct(nct_id, name, .keep_all=TRUE) %>%
  mutate(
    name = ifelse(is.na(name) | name %in% c("NA", "Unknown", ""), NA, name),
    agency_class = ifelse(is.na(agency_class) | agency_class %in% c("NA", "Unknown", ""), NA, agency_class)
  )


# Studies: all studies are distinct
clean_studies <- df_studies %>% 
  mutate(
    phase = ifelse(is.na(phase) | phase %in% c("NA", "Unknown", ""), NA, phase),
    start_date = ifelse(is.na(start_date), as.Date("1900-01-01"), start_date),
    completion_date = ifelse(is.na(completion_date), as.Date("1900-01-01"), completion_date),
    duration = completion_date - start_date
    overall_status = ifelse(is.na(overall_status) | overall_status %in% c("NA", "Unknown", ""), NA, overall_status),
    enrollment = ifelse(is.na(enrollment), 0, enrollment),
    study_type = ifelse(is.na(study_type) | study_type %in% c("NA", "Unknown", ""), NA, study_type),
    source = ifelse(is.na(source) | source %in% c("NA", "Unknown", ""), NA, source)
  )



DBI::dbDisconnect(con)