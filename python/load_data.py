# Imports
import pandas as pd
import json
from sqlalchemy.types import JSON
from sqlalchemy import create_engine, Integer, Text, Date, Numeric


# Constants
DB_USER = 'postgres'
DB_PASSWORD = 'admin'
DB_HOST = 'localhost'
DB_PORT = '5432'
DB_NAME = 'analytics'

# Creating engine or in general words connection string
engine = create_engine(f"postgresql+psycopg2://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}")

# function to create a table
def create_table_in_postgresql(df, table_name, data_types):
    df.to_sql(
        con=engine,
        name=table_name,
        schema="raw",
        if_exists="replace",
        index=False,
        dtype = data_types
    )
    print(f"{table_name} table is created successfully")


################## Excel ########################
# reading excel file
df_customer = pd.read_excel("../data/Customer.xls", sheet_name="atkoe-u250m", dtype=str)
#changing column names to lower case and replace blank space in underscore
df_customer.columns = df_customer.columns.str.strip().str.lower().str.replace(" ", "_")

# renaming columns
customer_rename_map = {
    "first": "first_name",
    "last": "last_name",
}
df_customer = df_customer.rename(columns=customer_rename_map)

# data_types_mapping
customer_types = {
    "customer_id": Integer(),
    "first_name": Text(),
    "last_name": Text(),
    "age": Integer(),
    "country": Text()
}

#Creatign the table
create_table_in_postgresql(df=df_customer, table_name="customers", data_types=customer_types)


########################### CSV ##############################

# reading the file
df_order = pd.read_csv("../data/Order.csv")
#changing column names to lower case and replace blank space in underscore
df_order.columns = df_order.columns.str.strip().str.lower().str.replace(" ", "_")

# data types Mapping
orders_pg_types = {
    "order_id": Integer(),
    "item": Text(),
    "amount": Numeric(10,2),
    "customer_id": Integer()
}

#Creatign the table
create_table_in_postgresql(df=df_order, table_name="orders", data_types=orders_pg_types)

############################JSON##############################
# Reading the file
with open("../data/Shipping.json") as f:
    data = json.load(f)

# Converting into data frame one row per record
df_shipping_json = pd.DataFrame(data)
df_shipping_json = pd.DataFrame({"data": df_shipping_json.to_dict(orient="records")})

#Creatign the table
create_table_in_postgresql(df=df_shipping_json, table_name="shipping_json", data_types={"data":JSON})
