# Lab | Making predictions with logistic regression

# Instructions
# Create a query or queries to extract the information you think may be relevant for building the prediction model. It should include some film features and some rental features.
# What we want to predict:
# In order to optimize our inventory, we would like to know which films will be rented next month and we are asked to create a model to predict it.
# rental_id, film_id, title, rental_date, inventory to check if we have it.
# Most rented film depending on category: category
# Length
# Rental duration

select rental_date from rental order by rental_date desc limit 10;

# We need the last rental date per film_id
CREATE TABLE last_rental_date
SELECT 
	I.film_id, MAX(DATE(rental_date)) AS last_rental_date
FROM
	inventory I
    JOIN
		rental R
	ON
		I.inventory_id = R.inventory_id
GROUP BY
	film_id
HAVING
	MAX(DATE(rental_date)) < '2022-02-05';

SELECT film_id,
	CASE
	WHEN MAX(last_rental_date) > '2006-01-31' THEN True
	ELSE False
		END AS rented_last_month
FROM 
	last_rental_date
GROUP BY
	film_id;

# We want the rental count per film ID so we get this info first.
CREATE TABLE RENTAL_RATE
SELECT 
	I.film_id, COUNT(R.rental_id) AS number_of_rentals
FROM
	inventory I
    JOIN
		rental R
	ON
		I.inventory_id = R.inventory_id
GROUP BY
	I.film_id
ORDER BY
	number_of_rentals DESC;
    
SELECT 
	* 
FROM 
	rental_rate 
LIMIT 
	5;

# We join all we need in one query
SELECT
	F.film_id, F.title, F.release_year, F.rental_duration, F.rental_rate, F.length, F.replacement_cost, F.rating, C.name AS category, R.number_of_rentals, DATE(D.last_rental_date) AS last_rental_date
FROM
	film F
    JOIN
		film_category FC
	USING (film_id)
    JOIN
		category C
	USING (category_id)
    JOIN
		rental_rate R
	USING (film_id)
	JOIN
		last_rental D
	USING (film_id)
WHERE
	last_rental_date < '2022-02-05';
    
# Query to get target variable - we set the last_month to 02-2006 (2022 was added to the database by me and the line will be drop as to not have a weird outlier that exists for no reason)
select rental_date from rental order by rental_date desc limit 10;
SELECT
	F.title, 
    MAX(R.rental_date) AS most_recent,
	CASE
	WHEN MAX(R.rental_date) > '2006-01-31' THEN True
	ELSE False
		END AS rented_last_month
FROM
	film F
    LEFT JOIN
		inventory I
	USING (film_id)
    LEFT JOIN
		rental R
	USING (inventory_id)
WHERE
	R.rental_date < '2022-02-05'
GROUP BY
	F.title
ORDER BY
	most_recent DESC;