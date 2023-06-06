SELECT
FROM
WHERE
GROUP BY
HAVING
ORDER BY
LIMIT

/*/ 1.1 CORRECT Using the table date_hour , write a query that returns one row and three columns called
"Total Spend", "Total Transactions", and "Total Items". This query should return the sum of
spend , trans , and items respectively.*/

SELECT SUM(spend) as "Total Spend"
, sum(trans) AS "Total Transactions"
, sum(items) AS "Total Items"
FROM date_hour

/*/ 1.2 INCORRECT--CORRECTED Using the table date_hour , write a query that returns five rows and two columns. The first
column should be date and the second should be called "Daily Spend". This query should
return dates and associated spends for the five days with the highest total spend. */

SELECT date
, SUM(spend) AS 'Daily Spend'
FROM date_hour
GROUP BY date
ORDER BY "Daily Spend" DESC
LIMIT 5

/*/ 1.3 INCORRECT--CORRECTED Using the table date_hour , write a query that returns five rows and two columns. The first
column should be date and the second should be called "Daily Spend". This query should
return dates and associated spends for the five days with the lowest total spend. */

SELECT date
, SUM(spend) AS "Daily Spend"
FROM date_hour
GROUP BY date
ORDER BY "Daily Spend"
LIMIT 5

/*/ 1.4 INCORRECT--CORRECTED Using the table date_hour , write a query that returns three rows and three columns. The
first column should be date , the second should be hour , and the third should be
spend . This query should return the three dates and hours with the highest spend. */

SELECT date
, hour
, SUM(spend) AS total_spend
FROM date_hour
GROUP BY date, hour
ORDER BY total_spend DESC
LIMIT 3

/*/ 1.5 CORRECT Using the table department_date , write a query that returns department and a column
called "Department Spend", which should be the sum of spending in the department across all
time. Sort the results from highest spend to lowest. */

SELECT department, SUM(spend) AS "Department Spend"
FROM department_date
GROUP BY department
ORDER BY "Department Spend" DESC

/*/ 1.6 CORRECT Using the table department_date , write a query that returns department and a column
called "Department Spend", which should be the sum of spending in the department in 2015.
Sort the results from highest spend to lowest. */

SELECT department, SUM(spend) AS "Department Spend"
FROM department_date
WHERE date LIKE '%2015%'
GROUP BY department
ORDER BY"Department Spend" DESC

/*/ 1.7 CORRECT Using the table department_date , write a query that returns the columns date and
spend and returns the rows with the 10 highest days of spend for the Frozen department. */

SELECT date, spend
FROM department_date
WHERE department = 6
ORDER BY spend DESC
LIMIT 10

/*/ 1.8 CORRECT Using the table department_date , write a query that returns the columns date and
spend and returns the rows with the 10 highest days of spend for the Deli department. */

SELECT date, spend
FROM department_date
WHERE department = 8
ORDER BY spend DESC
LIMIT 10

/*/ 1.9 CORRECT From the owner_spend_date table, write a query that returns the spending by month for
card_no 18736. This query should return 12 rows and two columns (a column called
month and a column called spend ) giving the total spending for this owner in this month
across all years. Return the results with the months in ascending order. */

SELECT strftime('%m', date) AS "Month", sum(spend) as spend 
FROM owner_spend_date
WHERE card_no = 18736
GROUP BY Month
ORDER BY Month ASC

/*/ 1.10 CORRECT From the owner_spend_date table, write a query that returns the spending by year and
month for card_no 18736. This query should return three columns (a column called year ,
a column called month , and a column called spend ) giving the total spending for this
owner in this month and year. Return the results in chronological order, with the first month in the
first row and the last month in the last row.*/

SELECT strftime('%Y', date) AS "Year", strftime('%m', date) AS "Month", sum(spend) as spend 
FROM owner_spend_date
WHERE card_no = 18736
GROUP BY Year, Month
ORDER BY Year, Month ASC


