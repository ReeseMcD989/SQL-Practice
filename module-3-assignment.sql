
/*3.1CORRECT Using the table owner_spend_date , write a query that creates a temporary table
owner_year_month that has the following columns: card_no , year , month ,
spend , and items . Those last two columns should be the sum of the columns of the same
name in the original table.
For your "results" screenshot, just take a screenshot of the successful query message.*/

DROP TABLE IF EXISTS owner_year_month;
CREATE TEMPORARY TABLE owner_year_month AS
SELECT card_no, 
SUBSTR(date,1,4) AS year,
SUBSTR(date,6,2) AS month,
SUM(spend) AS spend,
SUM(items) AS items
FROM owner_spend_date
GROUP BY card_no, year, month

/*3.2INCORRECT--CORRECTED Using your temporary table, write a query that returns year, month, and total spend for the five
month-year combos with the highest spend.*/

SELECT year,
month,
SUM(spend) as total_spend
FROM owner_year_month
GROUP BY year, month
ORDER BY total_spend DESC
LIMIT 5

/*3.3CORRECT Again using your temporary table (and the owners table), write a query that returns the
average spend by month (across all years) for owners who live in the 55405 zip code. Use a
subquery to get the appropriate set of card_no values. Order the results by month and give your
average spend value a sensible column name. Round average spend to two decimal places.*/

SELECT ROUND(AVG(spend),2) AS average_spend
, month
FROM owner_year_month
WHERE card_no IN (
SELECT card_no
FROM owners
WHERE zip = 55405
GROUP BY card_no
)
GROUP BY month
ORDER BY month

/*3.4CORRECT Write a query that returns zip code and total spend for the three zip codes with the highest total
spend.*/

SELECT zip
, ROUND(SUM(spend), 2) as total_spend
FROM owner_spend_date
INNER JOIN owners
ON owner_spend_date.card_no = owners.card_no
GROUP BY zip
ORDER BY total_spend DESC
LIMIT 3

/*3.5CORRECT Repeat 3.3 but now 
-include four columns in your output. You will again include month, but now
-include one column of average sales for each of the zip codes you found from the previous
query. 
-You can begin with the query from 3.3, but now call the results avg_spend_55405 .
-Join two CTEs to append the columns holding the average sales for the two zips that are not
55405. 
-Use the avg_spend_XXXXX naming convention.*/

WITH as5 AS (
SELECT ROUND(AVG(spend),2) AS average_spend_55405
, month
FROM owner_year_month
WHERE card_no IN 
(SELECT card_no
FROM owners
WHERE zip = 55405
GROUP BY card_no)
GROUP BY month
ORDER BY month
),
as8 AS (
SELECT ROUND(AVG(spend),2) AS average_spend_55408
, month
FROM owner_year_month
WHERE card_no IN 
(SELECT card_no
FROM owners
WHERE zip = 55408
GROUP BY card_no)
GROUP BY month
ORDER BY month
),
as3 AS (
SELECT ROUND(AVG(spend),2) AS average_spend_55403
, month
FROM owner_year_month
WHERE card_no IN 
(SELECT card_no
FROM owners
WHERE zip = 55403
GROUP BY card_no)
GROUP BY month
ORDER BY month
)
SELECT as5.month 
, as5.average_spend_55405
, as8.average_spend_55408
, as3.average_spend_55403
FROM as5
INNER JOIN as8 ON as5.month = as8.month
INNER JOIN as3 ON as5.month = as3.month

/*3.6INCORRECT--CORRECTED Rewrite your query for 3.1, 
-adding a column called total_spend which holds the total
spend, across all years and months, for that owner. 
-Use a CTE to calculate the total sales and
JOIN that to your previous query. 
-Add a line at the beginning that deletes the temporary table
if it exists.
In the below code block, I have included a query of your table. If your table has the right shape,
it will return a result. Paste that result into your "results" file.
-- Run this after rebuilding your temporary table. */

DROP TABLE IF EXISTS owner_year_month;
CREATE TEMPORARY TABLE owner_year_month AS
WITH ts AS(
SELECT card_no 
, SUM(spend) AS total_spend
FROM owner_spend_date
GROUP BY card_no
)
SELECT osd.card_no, 
SUBSTR(osd.date,1,4) AS year,
SUBSTR(osd.date,6,2) AS month,
SUM(osd.spend) AS spend,
SUM(osd.items) AS items,
ts.total_spend
FROM owner_spend_date AS osd
INNER JOIN ts ON ts.card_no = osd.card_no
GROUP BY osd.card_no, year, month

SELECT *
FROM owner_year_month
WHERE card_no = 18736

SELECT COUNT(DISTINCT(card_no)) AS owners,
 COUNT(DISTINCT(year)) AS years, 
 COUNT(DISTINCT(month)) AS months, 
 ROUND(AVG(spend),2) AS avg_spend,
 ROUND(AVG(items),1) AS avg_items,
 ROUND(SUM(spend)/SUM(items),2) AS avg_item_price
FROM owner_year_month

/*3.7CORRECT If a business has up-to-date customer information accessible quickly, the business can use that
information for customer retention. In this query, we create an "owner at a glance" view that tells
us a bit about the owner overall and their recent behavior.
-Using the owner_spend_date table, 
-create a view with total amount spent by owner, 
-the average spend per transaction, 
-number of dates they have shopped, 
-the number of transactions they have, and the 
-date of their last visit. 
-Give these columns sensible names. 
-Call your view vw_owner_recent .
-After you've built your view, run the query below and paste your results into the "results" file.*/

DROP VIEW IF EXISTS vw_owner_recent;
CREATE VIEW vw_owner_recent AS 
SELECT card_no
, ROUND(SUM(spend), 2) AS total_spend_per_owner
, ROUND(SUM(spend)/SUM(trans), 2) AS avg_trans_spend
, COUNT(DISTINCT date) AS spend_days
, SUM(trans) AS total_trans
, MAX(date) AS recent_visit
FROM owner_spend_date
GROUP BY card_no;

SELECT COUNT(DISTINCT card_no) AS owners, 
 ROUND(SUM(total_spend_per_owner)/1000,1) AS spend_k
FROM vw_owner_recent
WHERE 5 < total_trans AND 
 total_trans < 25 AND
 SUBSTR(recent_visit,1,4) IN ('2016','2017')
 
/*3.8INCORRECT -- CORRECTED Hint: the spend you're getting isn't the correct last spend. 
--Take a look at a specific owner like 18736 to see this. In this query you will create a table in your database. 
-This table, called owner_recent , will
be built off your view and will add an additional column. This new column (called
last_spend ) will be the amount spent on the date of that last visit. Adding this information
uses a clever trick that is common in SQL work. You'll essentially be joining
owner_spend_date to itself, but using the view as an intermediary.

The approach is straightforward: 
-select all of the columns out of the view and the column you
need out of owner_spend_date , 
-joining two fields ( card_no and the date fields).

Once you've built your table, run the two queries below. Verify that the results look sensible.
Answer these two questions in a comment in your code file. 
1. What is the time difference between the two versions of the query?
2. Why do you think this difference exists?
-- Select a row from the table*/

DROP TABLE IF EXISTS owner_recent;
CREATE TEMPORARY TABLE owner_recent AS
SELECT vor.* 
, osd.spend AS last_spend
FROM vw_owner_recent AS vor
INNER JOIN owner_spend_date AS osd
ON osd.card_no = vor.card_no AND osd.date = vor.recent_visit

--1. time difference = (View)2063ms-(TempTable)13ms = 2050ms
--2. Views are not permantently stored whereas temp tables are. 
--Every time the view is accessed, the underlying query reruns which takes up time.
--Temporary tables are static and so the code that got us the table does not need to be rerun.

SELECT *
FROM owner_recent
WHERE card_no = "18736"; --13ms
 
-- Select a row from the view
SELECT * 
FROM vw_owner_recent
WHERE card_no = "18736"; --2063ms

SELECT * FROM owner_spend_date WHERE card_no = 18736 AND date = "2017-01-24"

/*3.9INCORRECT-CORRECTED For this query, imagine the marketing manager wants you to help identify owners who are high
value, but have lapsed. The data set runs from 2010-01-01 through 2017-01-31. This is a bit
over 360 weeks.
Write a query that retuns the columns from owner_recent for owners who meet the
following criteria:
1. Their last spend was less than half their average spend.
2. Their total spend was at least $5,000.
3. They have at least 270 shopping dates.
4. Their last visit was at least 60 days before 2017-01-31.
5. Their last spend was greater than $10
Order your results by the drop in spend (from largest drop to smalles) and total spend.*/

SELECT *
FROM owner_recent
WHERE last_spend < avg_trans_spend/2
AND total_spend_per_owner >= 5000
AND spend_days >= 270
AND (JULIANDAY('2017-01-31') - JULIANDAY(recent_visit)) >= 60
AND last_spend > 10
ORDER BY (avg_trans_spend - last_spend) DESC, total_spend_per_owner DESC

/*3.10INCORRECT--CORRECTED Repeat the above analysis, but with a slightly different set of criteria. Our goal is to identify
people who do not live in the Wedge's zip code or adjacent to the Wedge. Recall that our zip
code classificaiton is the following:
wedge : 55405
adjacent : 55442, 55416, 55408, 55404, 55403
other : any other zip codes.
Write a query that retuns the columns from owner_recent for owners who meet the
following criteria:
1. The have non-null, non-blank zips and they do not live in the Wedge or adjacent zip codes.
2. Their last spend was less than half their average spend.
3. Their total spend was at least $5,000.
4. They have at least 100 shopping dates.
5. Their last visit was at least 60 days before 2017-01-31.
6. Their last visit was over $10
Include the owner's zip code in your query results. Order your results by the drop in spend (from
largest drop to smalles) and total spend.*/

SELECT onrc.*
, owners.zip 
FROM owner_recent as onrc
INNER JOIN owners
ON owners.card_no = onrc.card_no
WHERE owners.zip IS NOT NULL
AND owners.zip != ''
AND (owners.zip != 55405
AND owners.zip != 55442
AND owners.zip != 55416
AND owners.zip != 55408
AND owners.zip != 55404
AND owners.zip != 55403)
AND onrc.last_spend < onrc.avg_trans_spend/2
AND onrc.total_spend_per_owner >= 5000
AND onrc.spend_days >= 100
AND (JULIANDAY('2017-01-31') - JULIANDAY(onrc.recent_visit)) >= 60
AND onrc.last_spend > 10
ORDER BY (onrc.avg_trans_spend - onrc.last_spend) DESC, onrc.total_spend_per_owner DESC







--Format                         

WITH common_table_expression AS(subquery), (subquery)
SELECT column_1 - LAG(column_1) OVER (ORDER BY column_1) AS column_1_delta
CASE
WHEN THEN
WHEN THEN
ELSE END
FROM
INNER JOIN
ON =
WHERE
GROUP BY
HAVING
ORDER BY
LIMIT

/*
CREATE VIEW vw_name AS 
SELECT column_1 - LAG(column_1) OVER (ORDER BY column_1) AS column_1_delta
CASE
WHEN THEN
WHEN THEN
ELSE END
FROM
INNER JOIN
ON =
WHERE
GROUP BY
HAVING
ORDER BY
LIMIT
*/

CREATE TEMPORARY TABLE tmp_name AS
SELECT column_1 - LAG(column_1) OVER (ORDER BY column_1) AS column_1_delta
CASE
WHEN THEN
WHEN THEN
ELSE END
FROM
INNER JOIN
ON =
WHERE
GROUP BY
HAVING
ORDER BY
LIMIT

/*
New Functions:
OVER() assigns every row a window
SUBSTR(date,#,#) see pop-up for argument definitions
Separate CTE's with commas
Do not use a comma before the main query 
Only one WITH
Only one main query 
DROP TABLE IF EXISTS temp_table_name
*/


















