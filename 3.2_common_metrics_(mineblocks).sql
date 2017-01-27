CREATE TABLE purchases (id INT PRIMARY KEY, user_id INT, price REAL, refunded_at TEXT, created_at TEXT);

CREATE TABLE gameplays (id INT PRIMARY KEY, user_id INT, created_at TEXT, platform TEXT);

COPY purchases (id, user_id, price, refunded_at, created_at) FROM '/Users/simonha/Documents/bunz docs/Code/Codecademy SQL/mineblocks_purchases.csv' DELIMITER ',' CSV HEADER;

COPY gameplays (id, user_id, created_at, platform) FROM '/Users/simonha/Documents/bunz docs/Code/Codecademy SQL/mineblocks_gameplays.csv' DELIMITER ',' CSV HEADER;

SELECT * FROM purchases 
ORDER BY id
LIMIT 10;

/*Revenue per day, when there is no refund */
SELECT DATE(created_at), ROUND(SUM(price), 2) AS daily_rev
FROM purchases
WHERE refunded_at IS NOT null
GROUP BY 1
ORDER BY 1;

/*Calculating DAU by date*/
SELECT DATE(created_at), COUNT(DISTINCT user_id) AS DAU
FROM gameplays
GROUP BY 1
ORDER BY 1;

/*Now DAU by date and platform*/
SELECT DATE(created_at), platform, COUNT(DISTINCT user_id) AS DAU
FROM gameplays
GROUP BY 1, 2
ORDER BY 1, 2;

/*Getting daily ARPPU*/
SELECT DATE(created_at), ROUND(SUM(price) / COUNT(DISTINCT user_id), 2) AS ARPPU
FROM purchases
WHERE refunded_at IS null
GROUP BY 1
ORDER BY 1;


/*Daily ARPU is defined as revenue divided by the number of players, per-day. To get that, we'll need to calculate the daily revenue and daily active users separately, and then join them on their dates.

One way to easily create and organize temporary results in a query is with CTEs, Common Table Expressions, also known as with clauses. The with clauses make it easy to define and use results in a more organized way than subqueries.*/

WITH daily_revenue AS (
	SELECT
		date(created_at) as dt,
  		round(sum(price),2) as rev
  FROM purchases
  WHERE refunded_at IS NULL
  GROUP by 1
)
SELECT * FROM daily_revenue
ORDER BY dt;

/*Building on this CTE, we can add in DAU from earlier. Complete the query by calling the DAU query we created earlier, now aliased as daily_players:*/

WITH daily_revenue AS (
	SELECT
		date(created_at) as dt,
  	round(sum(price),2) as rev
  FROM purchases
  WHERE refunded_at IS NULL
  GROUP by 1
),
daily_players AS (
	SELECT
	DATE(created_at) AS dt,
	COUNT(DISTINCT user_id) AS players
  FROM gameplays
  GROUP BY 1
)
SELECT * FROM daily_players ORDER BY dt;

/*Now that we have the revenue and DAU, join them on their dates and calculate daily ARPU. Complete the query by adding the keyword using in the join clause.*/

with daily_revenue as (
  select
    date(created_at) as dt,
    round(sum(price), 2) as rev
  from purchases
  where refunded_at is null
  group by 1
), 
daily_players as (
  select
    date(created_at) as dt,
    count(distinct user_id) as players
  from gameplays
  group by 1
)
select
  daily_revenue.dt,
  daily_revenue.rev / daily_players.players
from daily_revenue
  join daily_players USING (dt);
/*When the columns to join have the same name in both tables you can use using instead of on. Our use of the using keyword is in this case equivalent to this clause*/


/*Before we can calculate retention we need to get our data formatted in a way where we can determine if a user returned.

Currently the gameplays table is a list of when the user played, and it's not easy to see if any user came back.

By using a self-join, we can make multiple gameplays available on the same row of results. This will enable us to calculate retention.

The power of self-join comes from joining every row to every other row. This makes it possible to compare values from two different rows in the new result set. In our case, we'll compare rows that are one date apart from each user.*/


SELECT
	DATE(created_at) AS dt,
  user_id
FROM gameplays as g1
ORDER BY dt
LIMIT 100;

/*Now we'll join gameplays on itself so that we can have access to all gameplays for each player, for each of their gameplays.

This is known as a self-join and will let us connect the players on Day N to the players on Day N+1. In order to join a table to itself, it must be aliased so we can access each copy separately.

We aliased gameplays in the query above because in the next step, we need to join gameplays to itself so we can get a result selecting [date, user_id, user_id_if_retained].

Complete the query by using a join statement to join gameplays to itself on user_id using the aliases g1 and g2.

select
  date(g1.created_at) as dt,
  g1.user_id
from gameplays as g1
  /**/ gameplays as g2 on
    g1.user_id = g2.user_id
order by 1
limit 100;

We don't use the using clause here because the join is about to get more complicated.
*/

SELECT
	DATE(g1.created_at) AS dt,
  g1.user_id
FROM gameplays as g1
	JOIN gameplays as g2 ON
  	g1.user_id = g2.user_id
ORDER BY 1
LIMIT 100;


/*Now that we have our gameplays table joined to itself, we can start to calculate retention.

1 Day Retention is defined as the number of players who returned the next day divided by the number of original players, per day. Suppose 10 players played Mineblocks on Dec 10th. If 4 of them play on Dec 11th, the 1 day retention for Dec 10th is 40%.
1.

The previous query joined all rows in gameplays against all other rows for each user, making a massive result set that we don't need.

We'll need to modify this query.

select
  date(g1.created_at) as dt,
  g1.user_id,
  g2.user_id
from gameplays as g1
  join gameplays as g2 on
    g1.user_id = g2.user_id
    and /**/
order by 1
limit 100;

Complete the query above such that the join clause includes a date join:

date(g1.created_at) = date(datetime(g2.created_at, '-1 day'))

This means "only join rows where the date in g1 is one less than the date in g2", which makes it possible to see if users have returned!
*/

SELECT
	DATE(g1.created_at) AS dt,
  g1.user_id,
  g2.user_id
FROM gameplays as g1
	JOIN gameplays as g2 ON
  	g1.user_id = g2.user_id
    AND date(g1.created_at) = DATE(DATETIME(g2.created_at, '-1 day'))
ORDER BY 1
LIMIT 100;

/*The query above won't return meaningful results because we're using an inner join. This type of join requires that the condition be met for all rows, effectively limiting our selection to only the users that have returned.

Instead, we want to use a left join, this way all rows in g1 are preserved, leaving nulls in the rows from g2 where users did not return to play the next day.

Change the join clause to use left join and count the distinct number of users from g1 and g2 per date.*/

SELECT
	DATE(g1.created_at) AS dt,
  COUNT(DISTINCT g1.user_id) AS total_users,
  COUNT(DISTINCT g2.user_id) AS returned_users
FROM gameplays as g1
	LEFT JOIN gameplays as g2 ON
  	g1.user_id = g2.user_id
    AND date(g1.created_at) = DATE(DATETIME(g2.created_at, '-1 day'))
GROUP BY 1
ORDER BY 1
LIMIT 100;

/*Now that we have retained users as count(distinct g2.user_id) and total users as count(distinct g1.user_id), divide retained users by total users to calculate 1 day retention!*/

SELECT
	DATE(g1.created_at) AS dt,
  ROUND(100 * COUNT(DISTINCT g2.user_id) / COUNT(DISTINCT g1.user_id)) AS retention
FROM gameplays as g1
	LEFT JOIN gameplays as g2 ON
  	g1.user_id = g2.user_id
    AND date(g1.created_at) = DATE(DATETIME(g2.created_at, '-1 day'))
GROUP BY 1
ORDER BY 1
LIMIT 100;

