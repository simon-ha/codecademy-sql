CREATE TABLE new_products (id INTEGER PRIMARY KEY, category VARCHAR(255), item_name VARCHAR(255), brand VARCHAR(255), retail_price DOUBLE PRECISION, department VARCHAR(255), rank INTEGER, sku VARCHAR(255));

CREATE TABLE legacy_products(id INTEGER PRIMARY KEY, category VARCHAR(255), item_name VARCHAR(255), brand VARCHAR(255), retail_price DOUBLE PRECISION, department VARCHAR(255), rank INTEGER, sku VARCHAR(255));

CREATE TABLE order_items (id INTEGER PRIMARY KEY, order_id INTEGER, sale_price DOUBLE PRECISION, inventory_item_id INTEGER, returned_at TEXT);

CREATE TABLE order_items_historic (id INTEGER, order_id INTEGER, sale_price DOUBLE PRECISION, inventory_item_id INTEGER, returned_at TEXT);

COPY new_products (id, category, item_name, brand, retail_price, department, rank, sku) FROM '/Users/simonha/Documents/bunz docs/Code/Codecademy SQL/new_products.csv' DELIMITER ',' CSV HEADER;

COPY legacy_products (id, category, item_name, brand, retail_price, department, rank, sku) FROM '/Users/simonha/Documents/bunz docs/Code/Codecademy SQL/legacy_products.csv' DELIMITER ',' CSV HEADER;

COPY order_items (id, order_id, sale_price, inventory_item_id, returned_at) FROM '/Users/simonha/Documents/bunz docs/Code/Codecademy SQL/order_items.csv' DELIMITER ',' CSV HEADER;

COPY order_items_historic (id, order_id, sale_price, inventory_item_id, returned_at) FROM '/Users/simonha/Documents/bunz docs/Code/Codecademy SQL/order_items_historic.csv' DELIMITER ',' CSV HEADER;

SELECT * FROM new_products;
SELECT * FROM legacy_products;
SELECT * FROM order_items;
SELECT * FROM order_items_historic;

SELECT ROUND(COUNT(DISTINCT department),2) / COUNT(*) FROM legacy_products;

/*UNION exercise - merge rows by JOIN, merge columns by UNION*/

SELECT brand FROM legacy_products
UNION
SELECT brand FROM new_products;


/*UNION ALL exercise - utilize a subquery to find the average sale price over both order_items and order_items_historic tables.*/

SELECT AVG(sale_price) FROM
	(SELECT id, sale_price FROM order_items
	UNION ALL
	SELECT id, sale_price FROM order_items_historic) AS a;
	
/* Not sure why I did this this way earlier v =/ */	
SELECT id, AVG(a.sale_price) FROM (
	SELECT id, sale_price FROM order_items
	UNION ALL
	SELECT id, sale_price FROM order_items_historic) AS a
GROUP BY 1;


/*INTERSECT exercise - INTERSECT is used to combine two SELECT statements, but returns rows only from the first SELECT statement that are identical to a row in the second SELECT statement. This means that it returns only common rows returned by the two SELECT statements*/

SELECT category FROM new_products
INTERSECT
SELECT category FROM legacy_products;


/* EXCEPT - constructed in the same way, but returns distinct rows from the first SELECT statement that aren’t output by the second SELECT statement.

Select the items in the category column that are in the legacy_products table and not in the new_products table */

SELECT category FROM legacy_products
EXCEPT
SELECT category FROM new_products;
/* in case you're curious, there are NO categories in new_products that aren't in legacy_products */
