--Question 1:--
'Create a query that lists each movie, the film category it is classified in,'
'and the number of times it has been rented out.'

SELECT film.title,
			 category.name,
			 COUNT(rental.inventory_id)

FROM category
	JOIN film_category
	ON category.category_id = film_category.category_id
	JOIN film
	ON film_category.film_id = film.film_id
	JOIN inventory
	ON film.film_id = inventory.film_id
	JOIN rental
	ON inventory.inventory_id = rental.inventory_id

WHERE category.name = 'Animation'
	 OR category.name = 'Children'
	 OR category.name = 'Classics'
	 OR category.name = 'Comedy'
	 OR category.name = 'Family'
	 OR category.name = 'Music'

GROUP BY 1,2
ORDER BY 2,1


--Question 2:--
'Provide a table with the movie titles and divide them into 4 levels (first_quarter, '
'second_quarter, third_quarter, and final_quarter) based on the quartiles (25%, 50%, 75%)'
'of the rental duration for movies across all categories?'

SELECT film.title AS title,
			 category.name AS category_name,
			 film.rental_duration AS rental_duration,
			 NTILE(4) OVER (ORDER BY film.rental_duration) AS quartile_overview

FROM category
	JOIN film_category
	ON category.category_id = film_category.category_id
	JOIN film
	ON film_category.film_id = film.film_id

WHERE category.name = 'Animation'
	 OR category.name = 'Children'
	 OR category.name = 'Classics'
	 OR category.name = 'Comedy'
	 OR category.name = 'Family'
	 OR category.name = 'Music'

ORDER BY 3


--Question 3:--
'Finally, provide a table with the family-friendly film category, each of the quartiles,'
'and the corresponding count of movies within each combination of film category for each'
'corresponding rental duration category.'

'The resulting table should have three columns:'
'1.Category, 2.Rental length category, 3.Count'

WITH table_1 AS (
								 SELECT film.title AS title,
											  category.name AS category_name,
											  film.rental_duration AS rental_duration,
											  NTILE(4) OVER (ORDER BY film.rental_duration) AS quartile_overview

								FROM category
									JOIN film_category
									ON category.category_id = film_category.category_id
									JOIN film
									ON film_category.film_id = film.film_id

								WHERE category.name = 'Animation'
									 OR category.name = 'Children'
									 OR category.name = 'Classics'
									 OR category.name = 'Comedy'
									 OR category.name = 'Family'
									 OR category.name = 'Music')

SELECT category_name,
			 quartile_overview,
			 COUNT(category_name)

FROM table_1
GROUP BY 1,2
ORDER BY 1,2,3 DESC


--Question 4:--
'We would like to know who were our top 10 paying customers, how many payments they made'
'on a monthly basis during 2007, and what was the amount of the monthly payments.'
'Can you write a query to capture the customer name, month and year of payment,'
'and total payment amount for each month by these top 10 paying customers?'


WITH t1 AS (SELECT customer.first_name || ' ' || customer.last_name full_name,
            SUM(payment.amount) total_pmt
            FROM customer
            JOIN payment
            ON payment.customer_id = customer.customer_id
            GROUP BY 1
            ORDER BY 2 DESC
            LIMIT 10)


SELECT  DATE_TRUNC('month', payment.payment_date) pmt_month,
        customer.first_name ||' '|| customer.last_name full_name,
        SUM(payment.amount) total_pmt,
        COUNT(payment.amount) count_pmt

FROM    customer
JOIN    payment
ON      payment.customer_id = customer.customer_id

      WHERE payment.payment_date BETWEEN '2007-01-01' AND '2008-01-01'
      AND customer.first_name || ' ' || customer.last_name IN (SELECT full_name FROM t1)
GROUP BY 1,2
ORDER BY 2,1
