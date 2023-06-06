
/*5.1 CORRECT Using owner_spend_date , calculate the total amount spent across all owners. Return this
total spend amount.*/

--done
SELECT SUM(spend) as total_spend
FROM owner_spend_date

/*5.2 INCORRECT -- CORRECTED Using the table owner_spend_date , write a query that finds some specific shopping days.
For owners who spent more than $10,000 in 2017, return the amount of their maximum spend in
that year. Return the columns card_no and spend . Order the results by spend,
descending. Exclude card number 3.*/

--done
SELECT card_no
, MAX(spend) as max_spend
FROM owner_spend_date
WHERE card_no IN (
SELECT card_no
FROM owner_spend_date
WHERE SUBSTR(date,1,4) = '2017'
AND card_no != 3
GROUP BY card_no
HAVING SUM(spend) > 10000
ORDER BY SUM(spend) DESC)
GROUP BY card_no
ORDER BY max_spend

/*5.3 CORRECT Using the table department_date , 
write a query that returns all columns for rows that meet
the following conditions:
The department number is not 1 or 2
The spend on the day for the department is between $5,000 and $7,500
The month is May, June, July, or August
Order your results by spend, decreasing.*/

--done
SELECT *
FROM department_date
WHERE (department != 1
AND department != 2)
AND (SUBSTR(date,6,2) = '05'
OR SUBSTR(date,6,2) = '06'
OR SUBSTR(date,6,2) = '07'
OR SUBSTR(date,6,2) = '08')
AND (spend > 5000 AND spend < 7500)
ORDER BY spend DESC

/*5.4 INCORRECT--CORRECTED Using the tables date_hour and department_date , write a query that returns
department spend during the busiest months. 
--Use date_hour to determine the months with the four highest spends. 
--Then use department_date to return the department spend in departments during these months. 
--Your query should return the year, the month, the total store
spend (from date_hour ), the department, and the department spend. 
--Arrange your results ascending for year and month and descending for department spend. 
--Limit your results to departments with over $200,000 spend in the month.*/

--done
WITH 
ss AS(
SELECT
  SUBSTR(date,1,4) AS year
, SUBSTR(date,6,2) AS month
, ROUND(SUM(spend), 2) AS store_spend
FROM date_hour AS dh
GROUP BY year, month
ORDER BY ROUND(SUM(spend), 2) DESC
LIMIT 4
)
, ds AS( 
SELECT
  SUBSTR(date,1,4) AS year
, SUBSTR(date,6,2) AS month
, department 
, ROUND(SUM(spend), 2) AS department_spend
FROM department_date AS dd
GROUP BY department, year, month
HAVING department_spend > 200000
ORDER BY department_spend DESC
)
SELECT ss.year
, ss.month
, ss.store_spend
, ds.department
, ds.department_spend
FROM ss
JOIN ds
ON ss.year = ds.year AND ss.month = ds.month
GROUP BY ss.year, ss.month, ds.department
ORDER BY ss.year, ss.month, ds.department_spend DESC 

/*5.5 CORRECT Write a query that answers the following question: 
for zip codes that have at least 100 owners,
what are the top five zip codes in terms of spend per transaction? 
Return the zip code, 
the number of owners in that zip code, 
the average amount spent per owner, 
and the average spend
per transaction.*/

--done
--this returns different solutions than John's code but John said it was ok, Sam
SELECT o.zip
, COUNT(DISTINCT o.card_no) AS zip_owners
, ROUND(SUM(osd.spend)/COUNT(DISTINCT o.card_no), 2) AS avg_owner_spend
, ROUND((SUM(osd.spend)/SUM(osd.trans)), 2) AS avg_trans_spend
FROM owners AS o                     
INNER JOIN owner_spend_date AS osd
ON o.card_no = osd.card_no
GROUP BY zip
HAVING COUNT(DISTINCT o.card_no) >= 100
ORDER BY avg_trans_spend DESC 
LIMIT 5

/*5.6 CORRECT Repeat 5.5 but return the zip codes with the lowest spend per transaction. It's up to you if you'd
like to exclude blank zips in the output.*/

SELECT o.zip
, COUNT(DISTINCT o.card_no) AS zip_owners
, ROUND(SUM(osd.spend)/COUNT(DISTINCT o.card_no), 2) AS avg_owner_spend
, ROUND((SUM(osd.spend)/SUM(osd.trans)), 2) AS avg_trans_spend
FROM owners AS o
INNER JOIN owner_spend_date AS osd
ON o.card_no = osd.card_no
GROUP BY zip
HAVING COUNT(DISTINCT o.card_no) >= 100
ORDER BY avg_trans_spend
LIMIT 5

/*5.7 INCORRECT--CORRECTED Write a query against the owners table that returns 
zip code, 
number of active owners,
number of inactive owners, and the 
fraction of owners who are active. 
Restrict your results to zip codes that have at least 50 owners. 
Order your results by the number of owners in the zip code.
--Note: in order to get / to give you real-number division, cast your numerator or denominator
in the "fraction active" column to a REAL .*/

WITH ai AS(
SELECT zip
, SUM(CASE WHEN UPPER(status) = "ACTIVE" THEN 1 ELSE 0 END) AS active
, SUM(CASE WHEN UPPER(status) = "INACTIVE" THEN 1 ELSE 0 END) AS inactive
, CAST(SUM(CASE WHEN UPPER(status) = "ACTIVE" THEN 1 ELSE 0 END)AS REAL)/COUNT(DISTINCT card_no) AS active_rate
, COUNT(DISTINCT card_no) as num_owners
FROM owners
WHERE UPPER(status) != 'VOID'
GROUP BY zip
HAVING COUNT(DISTINCT card_no) >= 50
ORDER BY COUNT(DISTINCT card_no)
)
SELECT zip
, active
, inactive
, ROUND(active_rate, 3) AS fraction_active
--, num_owners
FROM ai
ORDER BY num_owners DESC 

5.8 CORRECT

import sqlite3

#create connection
conn = sqlite3.connect('owner_prod.db')

#create cursor
curs = conn.cursor()

#drop table if exists for clean slate
curs.execute("DROP TABLE IF EXISTS owner_products")

#create the owner_products table
curs.execute("""CREATE TABLE owner_products(
            owner integer,
            upc integer,
            description text,
            dept_name text,
            spend numeric,
            items integer,
            trans integer
)""")

5.9 CORRECT 

#read owner_products into a list of lists
owner_prod = []

with open("owner_products.txt",'r') as infile : 
    next(infile)
 
    for line in infile :
        line = line.strip().split("\t")
        owner_prod.append(line)

	#insert owner_prod into database and commit database
curs.executemany('''INSERT INTO owner_products (owner, upc, description, dept_name, spend, items, trans) 
                   VALUES (?,?,?,?,?,?,?)''',owner_prod)
conn.commit()	
		
5.10 CORRECT 

#query against owner_products and print results
curs.execute("""SELECT description
            , dept_name
            , SUM(spend) AS total_spend
            FROM owner_products
            WHERE dept_name LIKE '%groc%'
            GROUP BY description, dept_name
            ORDER BY total_spend DESC
            LIMIT 10""")

print(curs.fetchall())

#close connection to database
conn.close()






