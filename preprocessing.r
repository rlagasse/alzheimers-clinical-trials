install.packages("DBI")
install.packages("RPostgres")
install.packages("dplyr")

library(DBI)
library(RPostgres)


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
  DBI::dbGetQuery(con, paste0("SELECT * FROM alzheimer_subset.", table))
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

# Conditions: distinct not needed as there are database constraints for id/nct_id
clean_conditions <- df_conditions %>% 
  mutate(
    name = replace(is.na(name), "Unknown"),
  )


# Countries
clean_countries <- df_countries %>% 
  mutate(
  )

# Designs
clean_designs <- df_designs %>% 
  mutate(
  )

# Facilities
clean_facilities <- df_facilities %>% 
  mutate(
  )

# Interventions
clean_interventions <- df_interventions %>% 
  mutate(
  )

# Outcome Counts
clean_outcome_counts <- df_outcome_counts %>% 
  mutate(
  )

# Sponsors
clean_sponsors <- df_sponsors %>% 
  mutate(
  )


# Studies: all studies are distinct
clean_studies <- df_studies %>% 
  distinct(nct_id, name, .keep_all = TRUE) %>%
  mutate(
    phase = replace(is.na(phase), "NA"),
    start_date = replace(is.na(start_date), .asDate("1900-01-01")),
    end_date = replace(is.na(end_date), .asDate("1900-01-01")),
    overall_status = replace(is.na(overall_status), "UNKNOWN"),
    enrollment = replace(is.na(enrollment), 0),
    study_type = replace(is.na(study_type), "Unknown"),
    source = replace(is.na(source), "Unknown"),
  )






DBI::dbDisconnect(con)