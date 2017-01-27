-- Includes 2.1 and 2.3 (both utilize flights tables)

CREATE TABLE airports (id BIGINT, code TEXT, site_number TEXT, fac_type TEXT, fac_use TEXT, faa_region TEXT, faa_dist TEXT, city TEXT, county TEXT, state TEXT, full_name TEXT, own_type TEXT, longitude DOUBLE PRECISION, latitude DOUBLE PRECISION, elevation INTEGER, aero_cht TEXT, cbd_dist INTEGER, cbd_dir TEXT, act_date TEXT, cert TEXT, fed_agree TEXT, cust_intl TEXT, c_ldg_rts TEXT, joint_use TEXT, mil_rts TEXT, cntl_twr TEXT, major TEXT);

COPY airports (id, code, site_number, fac_type, fac_use, faa_region, faa_dist, city, county, state, full_name, own_type, longitude, latitude, elevation, aero_cht, cbd_dist, cbd_dir, act_date, cert, fed_agree, cust_intl, c_ldg_rts, joint_use, mil_rts, cntl_twr, major)
FROM '/Users/simonha/Documents/bunz docs/code/Codecademy SQL/airports.csv' DELIMITER ',' CSV HEADER;

CREATE TABLE flights (id BIGINT, carrier TEXT, origin TEXT, destination TEXT, flight_num TEXT, flight_time INT, tail_num TEXT, dep_time TEXT, arr_time TEXT, dep_delay INT, arr_delay INT, taxi_out INT, taxi_in INT, distance INT, cancelled TEXT, diverted TEXT, dep_day_of_week VARCHAR(255), dep_month VARCHAR(255), dep_date TEXT);

COPY flights (id, carrier, origin, destination, flight_num, flight_time, tail_num, dep_time, arr_time, dep_delay, arr_delay, taxi_out, taxi_in, distance, cancelled, diverted, dep_day_of_week, dep_month, dep_date)
FROM '/Users/simonha/Documents/bunz docs/Code/Codecademy SQL/flights.csv' DELIMITER ',' CSV HEADER;

ALTER TABLE airport
RENAME TO airports;

SELECT * FROM airports;
SELECT * FROM flights;


SELECT dep_month, dep_day_of_week, AVG(distance)

FROM flights
GROUP BY 1, 2;

/* 2.1 Table Transformations (Subqueries) */

/*1. Non-correlated subquery exercise #1: Find flight information about flights where the origin elevation is less than 2000 feet. Requires elevation information from airports, then a select off of flights*/

SELECT * FROM flights
WHERE origin IN ( -- that IN ( command
	SELECT code
	FROM airports
	WHERE elevation <2000);

/*2. Non-correlated subquery exercise #2: find flight information about flights where the Federal Aviation Administration region (faa_region) is the Southern region (ASO).*/

SELECT * 
FROM flights 
WHERE origin IN (
    SELECT code 
    FROM airports 
    WHERE faa_region = 'ASO');

/*<v was an example actually> How many flights there are on average, for all Fridays in a given month from the flights table */

SELECT
	a.dep_month,
	a.dep_day_of_week,
	AVG(a.flight_count) AS average_flights
FROM (
	SELECT 
		dep_month,
		dep_day_of_week,
		dep_date,
		COUNT(*) AS flight_count
    FROM flights
    GROUP BY 1,2,3
    ) a
GROUP BY 1,2
ORDER BY 1,2;
/* the rationale behind this is that the inner SELECT does the GROUP BY and counts that you need, then the outer can do it at one level higher; just doing dep_month & dep_day_of_week doesn't provide desired results. Unnecessarily tricky, requires deeper understanding of data. Just understand the concept and move on. */

/*3. Sub-query within one table. Find the average total distance flown by day of week and month.*/

SELECT
	a.dep_month,
	a.dep_day_of_week,
	AVG(a.flight_distance) AS average_distance
FROM
	(
  SELECT
  	dep_month,
  	dep_day_of_week,
  	dep_date,
    SUM(distance) AS flight_distance
  FROM flights
  GROUP BY 1,2,3
  ) a
GROUP BY 1,2
ORDER BY 1,2;

/*4. In a correlated subquery, the subquery can not be run independently of the outer query. The order of operations is important in a correlated subquery:

    1. A row is processed in the outer query.
    2. Then, for that particular row in the outer query, the subquery is executed.

This means that for each row processed by the outer query, the subquery will also be processed for that row. In this example, we will find the list of all flights whose distance is above average for their carrier.*/

SELECT id, carrier, distance -- this is dictating the unique key per line (id); lists the 2 things we want (carrier, distance)
FROM flights f -- understand this line (needs to be used below); also, can be "flights AS f" or "flights f" <-- don't think this matters at all
WHERE distance > 
	(
	SELECT AVG(distance)
 	FROM flights
	WHERE carrier = f.carrier -- doing a line-by-line compare-o. a little tricky to comprehend. the f.carrier allows it to be a copy or second version of the same field/table
	)
ORDER BY carrier;

/*This was my own curiosity. Easy to do using Pivots in Excel. The above ^ however, that's pretty damned difficult. bravo SQL*/
SELECT carrier, AVG(distance)
FROM flights
GROUP BY carrier
ORDER BY carrier;

/*5. Correlated subqueries #2 It would also be interesting to order flights by giving them a sequence number based on time, by carrier. For instance, assuming flight_id increments with each additional flight, we could use the following query to view flights by carrier, flight id, and sequence number. Make the new sequential field "flight_sequence_number":*/

SELECT carrier, id,
    (
    SELECT COUNT(*)
	FROM flights f -- interesting, think about why the f is here. you're distinguishing this query from the outer query.
	WHERE f.id < flights.id
	AND f.carrier = flights.carrier
	) + 1 AS flight_sequence_number -- the parentheses triggers the subquery thing per line. 
FROM flights
ORDER BY carrier, flight_sequence_number; -- should be same whether it's ORDER BY 1,2 or 1,3

/*5. Actual - do the same thing as above, but using origin.*/
SELECT origin, id, 
	(
	SELECT COUNT(*)
	FROM flights f
	WHERE f.id < flights.id
	AND f.origin = flights.origin
  	) + 1 AS flight_sequence_number
FROM flights
ORDER BY 1,3;

-- rando. cardinality check for a column. pita having to convert to prevent an integer output... 
SELECT ROUND((ROUND(COUNT(DISTINCT carrier),2) / COUNT(*)),3) AS cardinality FROM flights;

SELECT COUNT(DISTINCT carrier) FROM flights;

SELECT 21/499.00;





/* 2.3 - Conditional Aggregates Lesson */

-- 1. Count the number of rows in the flights table
SELECT COUNT(*) FROM flights;

-- 2. Count the number of flights where the destination is ATL, and the arrival time is not NULL
SELECT COUNT(*) FROM flights
WHERE arr_time IS NOT NULL AND destination = 'ATL';

/*CASE WHEN example*/

SELECT
    CASE
        WHEN elevation < 500 THEN 'Low'
        WHEN elevation BETWEEN 500 AND 1999 THEN 'Medium'
        WHEN elevation >= 2000 THEN 'High'
        ELSE 'Unknown'
    END AS elevation_tier, 
    COUNT(*)
FROM airports
GROUP BY 1;

/* 3. CASE WHEN exercise; In the above statement, END is required to terminate the statement, but ELSE is optional. If ELSE is not included, the result will be NULL. Also notice the shorthand method of referencing columns to use in GROUP BY, so we don't have to rewrite the entire Case Statement. Some brainstorming here - this is like adding a nested if next to values, then doing a count of the values 

Provide a count of airports in Low, Medium, and High elevation tiers (that you make up). Low <250, Medium 250 - 1749, High >1750. Alias these tiers as elevation_tier */

SELECT
	CASE
		WHEN elevation < 250 THEN 'Low'
		WHEN elevation BETWEEN 250 AND 1749 THEN 'Medium'
		WHEN elevation >= 1750 THEN 'High'
	END AS elevation_tier,
	COUNT(*)
FROM airports
GROUP BY 1;

/* Me monkeying around */

SELECT state,
	CASE
  		WHEN elevation <250 THEN 'Low'
	    WHEN elevation BETWEEN 250 AND 1749 THEN 'Medium'
    	WHEN elevation >= 1750 THEN 'High'
	END AS elevation_tier,
	COUNT(*)
FROM airports
WHERE state IS NOT NULL
AND state IN
	(
    SELECT state
    FROM 
    	(
    	SELECT state, COUNT(*)
      	FROM airports
      	GROUP BY 1 
      	ORDER BY 2 DESC
      	LIMIT 10
    	) a -- hm, postgres did not let me process this without the alias "a". why?
	)
GROUP BY 1,2
ORDER BY 1,2;
/* on the above: "I used 'in' because I want the state to be one of several options (any of the 10 states we picked out) rather than a specific value" - thanks Hemant @ codecademy */


/* 4. COUNT(CASE WHEN); Sometimes you want to look at an entire result set, but want to implement conditions on certain aggregates. */

SELECT state,
	COUNT(CASE WHEN elevation < 1000 THEN 1 
		ELSE NULL -- must put NULL, not 0.
		END) AS count_low_elevation_airports
FROM airports
GROUP BY 1;


/* 5. SUM(CASE WHEN); find both the total flight distance and Delta flight distance by origin*/

SELECT origin,
	SUM(distance) AS total_flight_distance, 
	SUM(CASE WHEN carrier = 'DL' THEN distance 
		ELSE 0 
		END) AS total_delta_flight_distance,
FROM flights
GROUP BY 1
ORDER BY 1;
/*would be cool to figure out how to add ratios of delta / total (boom did it v)*/
SELECT origin, ROUND(ROUND(a.total_delta_flight_distance, 3) / ROUND(a.total_flight_distance, 3), 2) AS delta_ratio
FROM (
	SELECT origin,
		SUM(distance) AS total_flight_distance, 
		SUM(CASE WHEN carrier = 'DL' THEN distance 
			ELSE 0 
			END) AS total_delta_flight_distance
	FROM flights
	GROUP BY 1
	ORDER BY 1) a
ORDER BY 2 DESC;


/* 6. Combining Aggregates exercise: does exactly what I wanted ^^*/

SELECT origin, 
	100.0 * SUM(CASE 
		WHEN carrier = 'DL' THEN distance 
		ELSE 0 
		END) / SUM(distance) AS percentage_flight_distance_from_delta 
FROM flights
GROUP BY 1
ORDER BY 1;
/* wow terrible mistake above ^ misplacement of parentheses on line 170, had END) / SUM(distance)) instead, resulted in incorrect answer. be careful yo. actually don't even need the extra parentheses, got rid of it */

/* 7. Combining Aggregates II */

SELECT state,
	100.0*COUNT(CASE
		WHEN elevation >=2000 THEN 1
		ELSE NULL
		END) / COUNT(*) AS percentage_high_elevation_airports
FROM airports
GROUP BY 1
ORDER BY 1;
