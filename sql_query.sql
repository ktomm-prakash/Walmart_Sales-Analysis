create database walmart;
use walmart;

select * from walmart;


--
select count(*) from walmart;

SELECT DISTINCT
    payment_method
FROM
    walmart;

SELECT 
    payment_method, COUNT(*)
FROM
    walmart
GROUP BY payment_method;

select count(distinct Branch) from walmart;

select max(quantity) from walmart;
select min(quantity) from walmart;

--
-- Business Problems
-- Q1
-- Find different payment method and number of transactions, number of qty sold
SELECT 
    payment_method,
    COUNT(*) AS no_payments,
    SUM(quantity) AS no_qty_sold
FROM
    walmart
GROUP BY payment_method;

-- Q2
-- Identify the highest-rated category in each branch, displaying the branch, category avg rating
SELECT * 
FROM (
    SELECT branch, category,
           AVG(rating) AS avg_rating,
           RANK() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) AS rank_
    FROM walmart
    GROUP BY branch, category
) AS subquery_alias
WHERE rank_ = 1;

-- Q3
-- Identify the busiest day for each branch based on the number of transactions
SELECT *  
FROM (
    SELECT
        branch,
        DAYNAME(STR_TO_DATE(`date`, '%y-%m-%d')) AS day_name,
        COUNT(*) AS no_transactions,
        RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank_
    FROM
        walmart
    GROUP BY
        branch, day_name
) AS ranked_transactions
WHERE rank_ = 1;

-- Q4
-- Calculate the total quantity of items sold per payment method. list payment_method and total_quantity.
select
payment_method,
sum(quantity)as no_qty_sold
from walmart
group by payment_method;

-- Q5
-- Determine the average, minimum, and maximum rating of category for each city.
-- list the city, average_rating, min_rating, and max_rating.
select * from walmart;

select
city,
category,
min(rating)as min_rating,
max(rating)as max_rating,
avg(rating)as avg_rating
from walmart
group by city, category;

-- Q6
-- calculate the total profit for each category by considering total_profit as 
-- (unit_price * quantity * profit_margin). list category and total_profit, ordered from highest to lowest profit.
select
category,
sum(total)as total_revenue,
sum(total * profit_margin)as profit_margin
from walmart
group by category;

-- Q7
-- Determine the most common payment method for each branch. display branch and the preferred_payment_method.
with cte
as
(select 
branch,
payment_method,
count(*)as total_trans,
rank() over(partition by branch order by count(*) desc)as rank_
from walmart
group by branch, payment_method
)
select * from cte
where rank_=1;

-- Q8
-- Categorize sales into 3 group Morning, Afternoon, Evening find out which of the shift and number of invoices
SELECT
branch,
    CASE 
        WHEN HOUR(TIME(`time`)) < 12 THEN 'Morning'
        WHEN HOUR(TIME(`time`)) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS time_of_day,
    COUNT(*) AS transaction_count
FROM
    walmart
GROUP BY
    time_of_day,branch
order by time_of_day,transaction_count desc;


-- Q9
-- Identify 5 branch with highest decrese ratio in revenue compare to last year(current year 2023 and last year 2022)
-- rdr==last_rev - cr_rev/ls_rev*100

select * from walmart;

select date from walmart;

SELECT 
    date,
    YEAR(STR_TO_DATE(date, '%d-%m-%Y')) AS year_extract
FROM 
    walmart;

WITH revenue_2022 AS (
  SELECT branch,
         SUM(total) AS revenue
  FROM walmart
  WHERE YEAR(STR_TO_DATE(date, '%d-%m-%Y')) = 2022
  GROUP BY branch
),

revenue_2023 AS (
  SELECT branch,
         SUM(total) AS revenue
  FROM walmart
  WHERE YEAR(STR_TO_DATE(date, '%d-%m-%Y')) = 2023
  GROUP BY branch
)

SELECT
  ls.branch,
  ls.revenue AS last_year_revenue,
  cs.revenue AS cr_year_revenue,
  ROUND((ls.revenue - cs.revenue) / ls.revenue * 100, 2) AS revenue_decrease_ratio
FROM
  revenue_2022 AS ls
JOIN
  revenue_2023 AS cs
ON
  ls.branch = cs.branch
WHERE
  ls.revenue > cs.revenue
  order by revenue_decrease_ratio desc
  limit 5;
