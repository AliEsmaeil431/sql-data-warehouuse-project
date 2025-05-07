/*
=======================================================================
DDL Script: Create Gold Views
=======================================================================
Sript Purpose:
	This script creates views for the gold layer in the data warehouse.
	The Gold layer represents the final dimension and fact tables (Star Schema)

	each view performs transformations and combines data from the Silver layer
	to produce a clean, enriched, and business-ready dataset.

Usage:
	- These viewa can be queried directly for analytics and reporting.
=======================================================================
*/

--=====================================================================
-- Create Dimention: gold.dim_customers
--=====================================================================
If object_id('gold.dim_customers','U')not null
drop view gold.dim_customers
go

create view gold.dim_customers as
SELECT
		row_number() over(order by cst_id) as customer_key,
		a.cst_id as customer_id,
		a.cst_key as customer_number,
		a.cst_firstname first_name,
		a.cst_lastname as last_name,
		c.cntry as country,
		a.cst_marital_status as marital_status,
		case when cst_gndr != 'n\a' then cst_gndr
			when cst_gndr = 'n\a' and gen is not null then gen 
			else cst_gndr end as gender,
		b.bdate as birthdate,
		a.cst_create_date as create_date
FROM [DWH].[silver].[crm_cust_info] a
left join [silver].[erp_cust_az12] b
on a.cst_key = b.cid
left join [silver].[erp_loc_a101] c 
on a.cst_key = c.cid;


--=====================================================================
-- Create Dimention: gold.dim_products
--=====================================================================
If object_id('gold.dim_products','U')not null
drop view gold.dim_products
go 

create view gold.dim_products as
select 
	row_number() over (order by a.prd_start_dt, a.prd_key) as product_key,
	a.prd_id as product_id ,
	a.prd_key as product_number,
	a.prd_nm as product_name,
	a.cat_id as category_id,
	b.cat as category,
	b.subcat as subgategory,
	a.prd_line as product_line,
	b.maintenance,
	a.prd_cost as cost,
	a.prd_start_dt as start_date
from [silver].[crm_prd_info] a
left join [silver].[erp_px_cat_g1v2] b
on a.cat_id = b.id
where prd_end_dt is null;

--=====================================================================
-- Create Fact: gold.fact_sales
--=====================================================================
If object_id('gold.fact_sales','U')not null
drop view gold.fact_sales
go 

create view gold.fact_sales as
select
	a.sls_ord_num as order_number,
	b.customer_key,
	c.product_key,
	a.sls_order_dt as order_date,
	a.sls_ship_dt as ship_date,
	a.sls_due_dt as due_date,
	a.sls_sales as sales_amount,
	a.sls_quantity as quantity,
	a.sls_price as price
from [silver].[crm_sales_details] a
left join gold.dim_customers b
on a.sls_cust_id = b.customer_id
left join gold.dim_products c
on a.sls_prd_key = c.product_number; 
