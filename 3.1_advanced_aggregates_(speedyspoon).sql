CREATE TABLE orders (id INT PRIMARY KEY, ordered_at TEXT, delivered_at TEXT, delivered_to INT);

CREATE TABLE orders_items (id INT PRIMARY KEY, order_id INT, name TEXT, amount_paid REAL);

ALTER TABLE orders_items
RENAME TO order_items;

COPY orders (id, ordered_at, delivered_at, delivered_to) FROM '/Users/simonha/Documents/bunz docs/Code/Codecademy SQL/speedyspoon_orders.csv' DELIMITER ',' CSV HEADER;

COPY order_items (id, order_id, name, amount_paid) FROM '/Users/simonha/Documents/bunz docs/Code/Codecademy SQL/speedyspoon_order_items.csv' DELIMITER ',' CSV HEADER;

SELECT * FROM orders
ORDER BY id
LIMIT 100;

SELECT * FROM order_items
ORDER BY id
LIMIT 100;

/*Let's get a Daily Count of orders from the orders table.*/
SELECT DATE(ordered_at)
FROM orders
ORDER BY 1
LIMIT 100;

/*Use the date and count functions and group by clause to count and group the orders by the dates they were ordered_at.*/
SELECT DATE(ordered_at), COUNT(1)
FROM orders
GROUP BY 1
ORDER BY 1;

/*How much money has SpeedySpoon made from orders each day?*/
SELECT DATE(ordered_at), ROUND(SUM(amount_paid), 2)
FROM orders
JOIN order_items on
	orders.id = order_items.order_id
GROUP BY 1;

/*what about the above for kale smoothies only?*/
SELECT DATE(ordered_at), ROUND(SUM(amount_paid), 2)
FROM orders
JOIN order_items on
	orders.id = order_items.order_id
WHERE name = 'kale-smoothie'
GROUP BY 1
ORDER BY 1;
/*interesting, what's wrong with this in Postgres vs. SQL lite?*/

/*To get the percent of revenue that each item represents, we need to know the total revenue of each item. We will later divide the per-item total with the overall total revenue. 
The following query groups and sum the products by price to get the total revenue for each item.*/
SELECT name, ROUND(SUM(amount_paid), 2)
FROM order_items
GROUP BY 1
ORDER BY 2 DESC;

/*Complete the denominator in the subquery, which is the total revenue from order_items. Use the sum function to query the amount_paid from the order_items table.*/
SELECT name, ROUND(SUM(amount_paid) /
  (SELECT SUM(amount_paid) FROM order_items) * 100.0, 2) AS pct
FROM order_items
GROUP BY 1
ORDER BY 2 DESC;

/*using CASE to group items into categories*/
SELECT *,
	CASE name
	WHEN 'kale-smoothie' THEN 'smoothie'
    WHEN 'banana-smoothie' THEN 'smoothie'
    WHEN 'soda' THEN 'drink'
    WHEN 'orange-juice' THEN 'drink'
    WHEN 'blt' THEN 'sandwich'
    WHEN 'grilled-cheese' THEN 'sandwich'
    WHEN 'tikka-masala' THEN 'dinner'
    WHEN 'chicken-parm' THEN 'dinner'
    ELSE 'other'
    END AS category
FROM order_items
ORDER BY id
LIMIT 100;

SELECT 
CASE name
	WHEN 'kale-smoothie' THEN 'smoothie'
  WHEN 'banana-smoothie' THEN 'smoothie'
  WHEN 'soda' THEN 'drink'
  WHEN 'orange-juice' THEN 'drink'
  WHEN 'blt' THEN 'sandwich'
  WHEN 'grilled-cheese' THEN 'sandwich'
  WHEN 'tikka-masala' THEN 'dinner'
  WHEN 'chicken-parm' THEN 'dinner'
  ELSE 'other'
  END AS category, ROUND(1.0 * SUM(amount_paid) / SELECT SUM(amount_paid) FROM order_items) * 100,2) AS pct
FROM order_items
GROUP BY 1
ORDER BY 2 DESC;

/*While we do know that kale smoothies (and drinks overall) are not driving a lot of revenue, we don't know why. A big part of data analysis is implementing your own metrics to get information out of the piles of data in your database.

In our case, the reason could be that no one likes kale, but it could be something else entirely. To find out, we'll create a metric called reorder rate and see how that compares to the other products at SpeedySpoon.

We'll define reorder rate as the ratio of the total number of orders to the number of people making those orders. A lower ratio means most of the orders are reorders. A higher ratio means more of the orders are first purchases.
*/

/*Let's calculate the reorder ratio for all of SpeedySpoon's products and take a look at the results. Counting the total orders per product is straightforward. We count the distinct order_ids in the order_items table.*/
SELECT name, COUNT(DISTINCT order_id)
FROM order_items
GROUP BY 1
ORDER BY 1;

/*Now we need the number of people making these orders. To get that information, we need to join in the orders table and count unique values in the delivered_to field, and sort by the reorder_rate.*/
SELECT name, ROUND(1.0 * COUNT(DISTINCT order_id) / COUNT(DISTINCT orders.delivered_to), 2) AS reorder_rate
FROM order_items
JOIN orders ON
	orders.id = order_items.order_id
GROUP BY 1
ORDER BY 2 DESC;
/* wtf why is round working here and not above??*/

