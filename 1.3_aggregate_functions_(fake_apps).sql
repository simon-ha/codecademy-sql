/*1.3 Aggregate Functions (fake apps)*/

CREATE TABLE fake_apps (id INTEGER PRIMARY KEY, name TEXT, category TEXT, downloads INTEGER, price REAL);

COPY fake_apps (id, name, category, downloads, price) FROM '/Users/simonha/Documents/bunz docs/Code/Codecademy SQL/fake_apps.csv' DELIMITER ',' CSV HEADER;

SELECT * FROM fake_apps;

-- 1
SELECT COUNT(*) AS total_apps FROM fake_apps;
/* can't alias it using 'foo' <-- don't use quotation marks */

-- 2
SELECT name, category, price, MIN(downloads) FROM fake_apps;
/* whoa this totally doesn't work in Postgres. What I learned in Codecademy is "SLQ Lite". Use instead the query below */
SELECT name, category price, downloads FROM fake_apps
ORDER BY downloads
LIMIT 1;

-- 3
SELECT category, COUNT(*) FROM fake_apps
GROUP BY category; -- or GROUP BY 1

-- 4
SELECT name, category, MAX(downloads) FROM fake_apps
GROUP BY downloads;
/* Same as above, for Postgres (vs. SQLite) need to use: */
SELECT name, category, downloads FROM fake_apps
ORDER BY downloads DESC
LIMIT 1;

-- 5
SELECT name, category, MIN(downloads) FROM fake_apps;
/* Same as above, won't bother correcting this one*/

-- 6
SELECT category, AVG(price) FROM fake_apps
GROUP BY category;

-- 7
SELECT category, ROUND(AVG(Price),2) FROM fake_apps
GROUP BY category;
/* Postgres will not ROUND 'real' values. Must change to numeric like so: */
SELECT category, ROUND(AVG(price)::NUMERIC,2) FROM fake_apps
GROUP BY category;

-- 8
SELECT MAX(price) FROM fake_apps;

-- 9
SELECT name, MIN(downloads) FROM fake_apps;

-- 10
SELECT SUM(downloads) FROM fake_apps
WHERE category = 'Games';
/* To display 'Games'*/
SELECT category, SUM(downloads) FROM fake_apps
WHERE category = 'Games'
GROUP BY 1;

-- 11
SELECT COUNT(*) AS '# of free apps' FROM fake_apps
WHERE price = 0;
/* So, aliases in Postgres cannot use this quotation syntax like SQLite can. ^ must rename alias */
SELECT COUNT(*) FROM fake_apps
WHERE price = 0;

-- 12
SELECT COUNT(*) FROM fake_apps
WHERE price = 14.99;
/* dammit, why is this result 0. works when I do price > 14.98. Constant problems with 'real' data type, maybe I should use numeric going forward. UPDATE fk it works with numeric lol dumb.*/

-- 13
SELECT SUM(downloads) FROM fake_apps
WHERE category = 'Music';

-- 14
SELECT SUM(downloads) FROM fake_apps
WHERE category = 'Business';

-- 15
SELECT category, COUNT(*) FROM fake_apps
GROUP BY category;

-- 16
SELECT price, AVG(downloads) FROM fake_apps
GROUP BY price;

-- 17
SELECT price, ROUND(AVG(downloads),0) FROM fake_apps
GROUP BY 1;

-- 18
SELECT category, name, MAX(price) FROM fake_apps
GROUP BY 1,2; /* fk, problems */

/* use this solution instead */

	SELECT a.category, name, max FROM -- have to specify which 'category' bc JOIN creates 2 of them; MAX(thing) auto names column 'max'
		(
		SELECT category, MAX(price) FROM fake_apps
		GROUP BY 1
		) a
	JOIN fake_apps ON
		a.max = fake_apps.price
	ORDER BY 1;
	/*
	1. make the subquery - which is categories and their max price
	2. figure out how to add name - JOIN subquery with original table.
		JOIN on category (obvious first); the inner join with only category is not helpful as it will pull up every row
		Inner join w max to price would be even more useless; creating > 200 rows
		Must use an AND join (create that unique key) - category AND max.
	3. select the fields you want from the joined table - a.category, name, max.
	*/
	
	/* These are better because they don't use joins, which can be expensive*/
	SELECT category, name, price 
	FROM
		(
		SELECT category, name, price, rank() 
			OVER (PARTITION BY category ORDER BY price DESC) 
		FROM fake_apps
		) a
	WHERE a.rank = 1;
	
	SELECT category, name, price 
	FROM
		(
		SELECT category, name, price, dense_rank() 
			OVER (PARTITION BY category ORDER BY price DESC)
		FROM fake_apps
		) a
	WHERE a.dense_rank = 1;
	
	SELECT category, name, price
	FROM
		(
		SELECT category, name, price, row_number() -- row number doesn't work for this exercise, but just to learn it
			OVER (PARTITION BY category ORDER BY price DESC)
		FROM fake_apps
		) a
	WHERE a.row_number = 1;
	
	SELECT category, name, price, row_number()
	OVER (PARTITION BY category)
	FROM fake_apps;
	
	SELECT category, name, price, row_number()
	OVER (ORDER BY price DESC)
	FROM fake_apps;
	
	SELECT category, name, price, rank()
	OVER (ORDER BY price DESC)
	FROM fake_apps;

	/* ty strawberry */

-- 19
SELECT count(*) FROM fake_apps
WHERE name LIKE 'A%';
/* Postgres has case sensitivity */
SELECT COUNT(*) FROM fake_apps
WHERE LOWER(name) LIKE LOWER('A%');

-- 20
SELECT SUM(downloads) FROM fake_apps
WHERE category = 'Sports' OR 'Health & Fitness';
/* postgres does not allow an OR here without specifying column: */
SELECT SUM (downloads) FROM fake_apps
WHERE category = 'Sports' OR category = 'Health & Fitness';

