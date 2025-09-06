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




DBI::dbDisconnect(con)