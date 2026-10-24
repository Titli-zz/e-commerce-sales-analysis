# E-Commerce Sales Analysis

## Project Overview
An end-to-end data analytics project exploring e-commerce sales, customer purchasing behavior, and product performance.

## Objectives
- Clean and prepare customer, product, and sales datasets.
- Load structured data into PostgreSQL.
- Analyze sales and customer behavior using SQL.
- Build an interactive Power BI dashboard to communicate business insights.

## Tools & Technologies
- Python: Pandas
- Jupyter Notebook
- PostgreSQL and SQL
- Microsoft Power BI

## Project Workflow
1. Data cleaning and preparation
2. Loading cleaned datasets into PostgreSQL
3. SQL-based analysis
4. Power BI dashboard development
5. Business insights and recommendations


## Key Findings
Revenue Performance: Total revenue from delivered orders decreased from 194.71M in January 2025 to 172.13M in February 2025, an 11.6% month-over-month decline. This highlights the importance of monitoring monthly revenue trends and identifying opportunities to improve sales performance.

Order Volume: Total orders declined from 10,243 in January to 9,211 in February 2025, a decrease of approximately 10.1%. The decline in order volume appears to be the primary contributor to the revenue reduction, making customer acquisition and order generation important areas for improvement.

Average Order Value (AOV): Average order value decreased slightly from 23,699.04 in January to 23,329.82 in February 2025, a reduction of approximately 1.6%. This suggests that the revenue decline was more closely associated with fewer orders than with a substantial decrease in average spending per delivered order.

Order Status Analysis: Delivered orders decreased from 8,216 in January to 7,378 in February, while cancelled orders increased slightly from 470 to 476. Monitoring cancellations, returns, and processing delays can help identify operational issues and improve the overall customer experience.

Business Implication: The January–February comparison indicates that improving order volume and maintaining delivery performance should be key priorities. Further analysis by product category, customer segment, and geographic region can help identify specific opportunities for revenue growth.


## Power BI Dashboard

### 1. Sales Overview
![Sales Overview](sales%20review.png)

### 2. February 2025 Deep Dive
![February 2025 Deep Dive](february%202025.png)

### 3. Customer & Product Analysis
![Customer and Product Analysis](customer%20%26%20product%20analysis.png)



## Repository Structure

```text
e-commerce-sales-analysis/
│
├── cleaned_data.ipynb              # Data cleaning and preparation using Pandas
├── customer_clean.csv              # Cleaned customer dataset
├── product_clean.csv               # Cleaned product dataset
├── sales_compressed.csv.gz         # Compressed sales dataset
├── e_com.sql                       # SQL queries for sales analysis
├── e_com.pbix                      # Interactive Power BI report
│
├── sales review.png                # Sales Overview dashboard
├── february 2025.png               # February 2025 Deep Dive dashboard
└── customer & product analysis.png # Customer and Product Analysis dashboard
```


