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

/*1. Non-correlated subquery exercise #1: Find flight information about flights where the origin elevation is less than 2000 feet. Requires elevation information from airports, then a select off of flights*/

SELECT * FROM flights
WHERE origin IN (
	SELECT code
	FROM airports
	WHERE elevation <2000);

/*2. Non-correlated subquery exercise #2: find flight information about flights where the Federal Aviation Administration region (faa_region) is the Southern region (ASO).*/

SELECT * 
FROM flights 
WHERE origin in (
    SELECT code 
    FROM airports 
    WHERE fac_type = 'SEAPLANE_BASE');

/*<this was an example actually> How many flights there are on average, for all Fridays in a given month from the flights table */

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

    1 .A row is processed in the outer query.
    2. Then, for that particular row in the outer query, the subquery is executed.

This means that for each row processed by the outer query, the subquery will also be processed for that row. In this example, we will find the list of all flights whose distance is above average for their carrier.*/

SELECT id, carrier, distance
FROM flights AS f
WHERE distance > 
	(
	SELECT AVG(distance)
 	FROM flights
	WHERE carrier = f.carrier
	)
ORDER BY carrier;

/*This was my own curiosity. Easy to do using Pivots in Excel. The above ^ however, that's pretty damned difficult. bravo SQL*/

SELECT carrier, AVG(distance)
FROM flights
GROUP BY carrier
ORDER BY carrier;

/*5. Correlated subqueries #2 It would also be interesting to order flights by giving them a sequence number based on time, by carrier. For instance, assuming flight_id increments with each additional flight, we could use the following query to view flights by carrier, flight id, and sequence number:*/

SELECT carrier, id,
    (
    SELECT COUNT(*)
	FROM flights f
	WHERE f.id < flights.id
	AND f.carrier=flights.carrier
	) + 1 AS flight_sequence_number
FROM flights
ORDER BY carrier, flight_sequence_number;