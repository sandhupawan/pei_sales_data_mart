# 📊 PEI | Data Analyst Task

This repository contains all files related to the PEI Data Analyst assessment task.

---

## 🔗 Reference Links

- **Assessment Document**: [Click Here](https://docs.google.com/document/d/1zWXz9SViWSJbMN7EmXCYqqFIXzPk-s98IZd45tu3V3o/edit?tab=t.0)
- **Technical User Story for Data Engineer**: [Click Here](https://docs.google.com/document/d/1nJzi3Ml7ei8riEAh2EC3Cjx6it2DJsgR21XBuQ4vsN8/edit?tab=t.0)
- **Approach Document**: [Click Here](https://docs.google.com/document/d/10jN_V9kiZ92f_acuKEHllZIJFkHfodHqnjyUJlTfsN0/edit?tab=t.0)

---

## 🧠 Assumptions Made

1. **Customers Table**
   - `age` must be greater than 0 and less than 120.
   - `first_name` and `last_name` should not contain numbers or special characters.
   - `customer_id` is unique and cannot have duplicates.
   - A person with the same `first_name`, `last_name`, and `age` can exist in the same country as long as the `customer_id` is unique.

2. **Orders Table**
   - `amount` should always be greater than 0.
   - `order_id` must be unique.
   - A customer can order the same item for the same amount more than once; hence uniqueness is enforced only on `order_id`.
   - Not all customers have order data.

3. **Shipping Table**
   - There’s no direct link between `shipping` and `orders`; `shipping_status` is treated as a dimension.
   - A customer can only have either **Delivered** or **Pending** status. More than one entry per customer with either status will be considered a duplicate.
   - Not all customers have shipping data.

---

## 📁 Repository Structure

##data: Contains all three raw data files
##python: Python scripts to load data into PostgreSQL for data exploration
##sql: SQL scripts for data quality checks and business reporting
##documents: 
   - Sales Data Mart_Technical Stories — User story for Data Engineer
   - PEI Assessment_Approach Document — Steps taken to solve the business problem
   - Data Flow Mapping — Mapping from source system to final data mart
