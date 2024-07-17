create table if not exists sales(
invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
branch VARCHAR(5) NOT NULL,
city VARCHAR(30) NOT NULL,
customer_type VARCHAR(30) NOT NULL,
gender VARCHAR(10) NOT NULL,
product_line VARCHAR(100) NOT NULL,
unit_price decimal(10, 2) NOT NULL,
quantity INT NOT NULL,
VAT FLOAT(6,4) NOT NULL,
total DECIMAL(12, 4) NOT NULL,
date datetime NOT NULL,
time time NOT NULL,
payment_method VARCHAR (15) NOT NULL,
cogs DECIMAL(10,2) NOT NULL,
gross_margin_pct FLOAT(11,9),
gross_income  DECIMAL(12,4) NOT NULL,
rating FLOAT(2,1)
);

-- -----------------------------------------------------------------------------------
-- ----------------------------NEW FEATURE ADD----------------------------------------

-- Time Of Day
select  
	time,
	(CASE 
		WHEN `time`  BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time`  BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
        END
        ) AS time_of_date
from sales;

UPDATE sales
set time_of_day = (CASE 
		WHEN `time`  BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time`  BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
        END
        );
        
-- Day Name
select 
    date,
    dayname(date) AS day_name
from sales;
   
ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);

UPDATE sales
set day_name = dayname(date);

-- Month Name
select 
    date,
    monthname(date) 
from sales;
   
ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);

UPDATE sales
set month_name = monthname(date);

-- -----------------------------------------------------------------------------------
-- ----------------------------GENERIC------------------------------------------------

-- How many unique cities does the data have?
SELECT
 distinct(city)
FROM sales;

-- In which city is each branch?
SELECT
 distinct(city),
 branch
FROM sales;

-- -----------------------------------------------------------------------------------
-- ----------------------------PRODUCT---------------------------------------------

-- 1. How many unique product lines does the data have?
SELECT
    count(distinct(product_line))
FROM sales;

-- 2. What is the most common payment method?
SELECT
     payment_method,
     count(payment_method) AS cnt
FROM sales
GROUP BY payment_method
order by cnt desc;

-- 3. What is the most selling product line?
SELECT 
	distinct(product_line),
     count(quantity) AS cnt
FROM sales
GROUP BY product_line
ORDER BY cnt DESC;

-- 4. What is the total revenue by month?
SELECT
      month_name AS month,
      SUM(total) AS total_revenue
FROM sales
GROUP BY month_name;

-- 5. What month had the largest COGS?
SELECT
     month_name AS month,
     SUM(cogs) AS total_cogs
FROM sales
GROUP BY month_name
ORDER BY total_cogs DESC;

-- 6. What product line had the largest revenue?
SELECT
     DISTINCT(product_line),
     SUM(total) AS total_revenue
FROM sales
GROUP BY product_line
ORDER BY total_revenue DESC;

-- 7. What is the city with the largest revenue?
SELECT
      DISTINCT(city),
      SUM(total) AS total_revenue
FROM sales
GROUP BY city
ORDER BY total_revenue DESC;

-- 8. What product line had the largest VAT?
SELECT
     DISTINCT(product_line),
     AVG(VAT) AS avg_tax
FROM sales
GROUP BY product_line
ORDER BY avg_tax DESC;

-- 9. Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
With AvgSales AS (
SELECT
     product_line,
     ROUND(avg(total),2) as avg_sales
     
FROM sales 
GROUP BY product_line)

SELECT 
      s.product_line,
      s.total,
      CASE
          WHEN s.total > AvgSales.avg_sales THEN "GOOD"
          ELSE "BAD"
	  END AS Salesperformance
FROM sales AS s
JOIN AvgSales
ON s.product_line = AvgSales.product_line
;


-- 10. Which branch sold more products than average product sold?
SELECT
     branch,
     SUM(quantity) AS qty
FROM sales
group by branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales);

-- 11. What is the most common product line by gender?
SELECT
	  product_line,
      gender,
      COUNT(gender) AS total_cnt
FROM sales
GROUP BY product_line, gender
ORDER BY total_cnt DESC;
-- 12. What is the average rating of each product line? 
SELECT
  product_line,
  ROUND(avg(rating),1) as avg_rating
FROM sales
group by product_line
ORDER BY avg_rating;

-- -----------------------------------------------------------------------------------
-- ----------------------------SALES---------------------------------------------

-- 1. Number of sales made in each time of the day per weekday
SELECT
     time_of_day,
     COUNT(*) AS total_sales
FROM sales
WHERE day_name = "Friday"
GROUP BY time_of_day
ORDER BY total_sales DESC;

-- 2. Which of the customer types brings the most revenue?
SELECT
      customer_type,
      sum(total) AS revenue
FROM sales
GROUP BY customer_type
ORDER BY revenue DESC;

-- 3. Which city has the largest tax percent/ VAT (Value Added Tax)?
SELECT
     city,
     ROUND(AVG(VAT),2) AS avg_tax 
FROM sales
GROUP BY city
ORDER BY avg_tax DESC
;

-- 4. Which customer type pays the most in VAT?
SELECT
     customer_type,
     ROUND(AVG(VAT),2) AS avg_tax 
FROM sales
GROUP BY customer_type
ORDER BY avg_tax DESC;


-- -----------------------------------------------------------------------------------
-- ----------------------------CUSTOMER-----------------------------------------------

-- 1. How many unique customer types does the data have?
SELECT
     DISTINCT(customer_type)
FROM sales
GROUP BY customer_type;

-- 2. How many unique payment methods does the data have?
SELECT
     DISTINCT(payment_method)
FROM sales
GROUP BY payment_method;

-- 3. What is the most common customer type?
SELECT
     customer_type,
     COUNT(*) AS customer_cnt
FROM sales
GROUP BY customer_type
ORDER BY customer_type DESC;

-- 4. Which customer type buys the most?
SELECT
      customer_type,
      SUM(total) AS total_sales
FROM sales
GROUP BY customer_type;

-- 5. What is the gender of most of the customers?
SELECT
     gender,
     COUNT(*) AS gender_cnt
FROM sales
GROUP BY gender;

-- 6. What is the gender distribution per branch?
SELECT
      branch,
      gender,
      COUNT(*) AS gender_cnt
FROM sales
GROUP BY branch, gender;

-- 7. Which time of the day do customers give most ratings?
SELECT
      time_of_day,
      avg(rating) AS avg_rating
FROM sales
GROUP BY time_of_day
ORDEr BY avg_rating DESC;

-- 8. Which time of the day do customers give most ratings per branch?
SELECT
      time_of_day,
      round(avg(rating),2) AS avg_rating,
      branch
FROM sales
GROUP BY time_of_day, branch
ORDEr BY avg_rating DESC;

-- 9. Which day fo the week has the best avg ratings?
SELECT
      day_name,
      round(avg(rating),2) AS avg_rating
FROM sales
GROUP BY day_name;

-- 10. Which day of the week has the best average ratings per branch?
SELECT
      day_name,
      round(avg(rating),2) AS avg_rating
FROM sales
WHERE branch = "C"
GROUP BY day_name;

-- -----------------------------------------------------------------------------------
-- ----------------------------REVENUE AND PROFIT---------------------------------------

-- 1.What is the total profit?
SELECT
     SUM(gross_income) as total_profit
FROM sales;

-- 2.What is the average profit margin percentage?
SELECT 
    ROUND(AVG(gross_margin_pct),4) AS avg_profit_margin_percentage
FROM 
    sales;

-- 3. What is the total revenue and total profit for each product line?
SELECT
	 product_line,
     SUM(gross_income) AS total_profit,
     SUM(total) AS total_revenue
FROM sales
GROUP BY product_line 
ORDER BY total_profit , total_revenue DESC;


