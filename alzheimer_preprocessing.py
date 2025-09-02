from sqlalchemy import create_engine
import pandas as pd

engine = create_engine(
    "postgresql+psycopg2://aactadmin:Superpowerman787!@aact-postgresql-db.postgres.database.azure.com:5432/alzheimers",
    connect_args={"sslmode":"require"}
)

df = pd.read_sql("SELECT * FROM alzheimer_subset.conditions", engine)

print(df)