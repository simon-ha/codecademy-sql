CREATE TABLE bakeries (id INTEGER PRIMARY KEY, distance INTEGER, first_name VARCHAR(255), last_name VARCHAR(255), city VARCHAR(255), state VARCHAR(255));

ALTER TABLE bakeries
ALTER distance TYPE FLOAT;

CREATE TABLE baked_goods (id BIGINT PRIMARY KEY, cost DOUBLE PRECISION, manufacture_time TEXT, delivery_time TEXT, cook_time TEXT, cool_down_time TEXT, ingredients_cost DOUBLE PRECISION, packaging_cost DOUBLE PRECISION, ingredients VARCHAR(255));

COPY bakeries (id, distance, first_name, last_name, city, state) FROM '/Users/simonha/Documents/bunz docs/Code/Codecademy SQL/bakeries.csv' DELIMITER ',' CSV HEADER;

COPY baked_goods (id, cost, manufacture_time, delivery_time, cook_time, cool_down_time, ingredients_cost, packaging_cost, ingredients) FROM '/Users/simonha/Documents/bunz docs/Code/Codecademy SQL/baked_goods.csv' DELIMITER ',' CSV HEADER;

SELECT * FROM bakeries;
SELECT * FROM baked_goods;

/* It is important to note that date, number, and string functions are highly database dependent. The below is from SQLite. */

-- 2. Dates
SELECT DATETIME(delivery_time)
FROM baked_goods;
/*hm, DATETIME doesn't work in postgres*/

-- 3. Dates II
SELECT DATE(delivery_time), COUNT(*) AS count_baked_goods
FROM baked_goods
GROUP BY 1;

SELECT TIME(delivery_time), COUNT(*) AS count_baked_goods
FROM baked_goods
GROUP BY 1;
/*TIME( also doesn't work. Is this because no times were imported? */

-- 4. Dates III
SELECT DATETIME(manufacture_time, '+2 hours', '30 minutes', '1 day') AS inspection_time
FROM baked_goods;

SELECT DATETIME(delivery_time, '+5 hours', '20 minutes', '2 days') AS package_time
FROM baked_goods;
/*the above 2 also don't work*/

-- 5. Numbers
SELECT ROUND(distance, 2) AS distance_from_market
FROM bakeries;
/* sigh this one didn't work either... had to change distance datatype to NUMERIC */

-- 6. Numbers II
SELECT id, MAX(cook_time, cool_down_time) -- can't do a max of two things in Postgres so simply; figured out the wonky one below
FROM baked_goods;

	SELECT a.id, MAX(a.max)
	FROM (
		SELECT id, MAX(cook_time)
		FROM baked_goods
		GROUP BY 1
		UNION
		SELECT id, MAX(cool_down_time)
		FROM baked_goods
		GROUP BY 1) a -- don't forget, must have an alias
	GROUP BY 1
	ORDER BY 1;

SELECT id, MIN(cook_time, cool_down_time)
FROM baked_goods;
/*^2 above don't work*/

-- 7. Strings (Concatenation)
SELECT first_name || ' ' || last_name AS full_name
FROM bakeries;
/* YAY this is the same! */

-- 8. Strings II
SELECT id, REPLACE(ingredients,'enriched_flour','flour') as item_ingredients
FROM baked_goods
WHERE ingredients IS NOT NULL
AND ingredients LIKE '%flour%';