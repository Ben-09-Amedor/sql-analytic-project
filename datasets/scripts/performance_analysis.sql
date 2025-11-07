
/*
===============================================================================
Performance Analysis (Year-over-Year, Month-over-Month)
===============================================================================
Purpose:
    - To measure the performance of products, customers, or regions over time.
    - For benchmarking and identifying high-performing entities.
    - To track yearly trends and growth.

SQL Functions Used:
    - LAG(): Accesses data from previous rows.
    - AVG() OVER(): Computes average values within partitions.
    - CASE: Defines conditional logic for trend analysis.
===============================================================================
*/
	/* Analyze the yearly Performance of product by comparing their sales
	to both the average performance of the product the previous years sales */


	WITH yearly_product_sales AS (
	  SELECT
	    YEAR(f.order_date) AS order_year,
	    p.product_name,
	    SUM(f.sales_amount) AS Current_sales
	  FROM gold.fact_sales f 
	  LEFT JOIN gold.dim_products p
	  ON f.product_key = p.product_key
	  WHERE order_date IS NOT NULL
	  GROUP BY YEAR(f.order_date), 
	  p.product_name
	)
	SELECT 
	  order_year,
	  product_name,
	  current_sales,
	  AVG(current_sales) OVER (PARTITION BY product_name) avg_sales,
	  current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS sales_diff,
	CASE WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above_avg'
		   WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below_avg'
		   ELSE 'Avg'
	END avg_change,
	-- Year on Year sales Analysis
	LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) py_sales,
	current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS py_sales_diff,
	CASE WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Above'
		 WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Below'
		 ELSE 'No change'
	END py_change
	FROM yearly_product_sales
	ORDER BY product_name, order_year
