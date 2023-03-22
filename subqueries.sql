USE sakila;
#1-How many copies of the film Hunchback Impossible exist in the inventory system?
#subquery
#SELECT title
#FROM film
#WHERE title = 'Hunchback Impossible'

#query
SELECT COUNT(*) num_of_copies
FROM inventory
WHERE inventory.film_id IN (SELECT film_id
from film
where title = 'Hunchback Impossible')
;

#2-List all films whose length is longer than the average of all the films.
#Subquery: Calculating the average length of all the movies:
#SELECT AVG(length) FROM film;

#subquery:average length of thi films:
SELECT AVG(length) total_avg_length
             FROM film;

#Query
SELECT film_id, title, film.length
FROM film
WHERE film.length > (SELECT AVG(length) total_avg_length
             FROM film)
                
			ORDER BY film.length ASC;


#3- Use subqueries to display all actors who appear in the film Alone Trip.
#subquer:Selecting films with the title of alone trip:
SELECT film_id, title
                FROM film
               WHERE title = 'Alone Trip';
#query:Selecting actors who appear in Alone Trip movie:
SELECT actor_id, film_id
FROM film_actor 
WHERE film_id IN (SELECT film_id
                FROM film
               WHERE title = 'Alone Trip');

#showing the actors with first_name and last_name and two subqueries:               
SELECT first_name, last_name, actor_id
FROM actor 
WHERE actor_id IN(SELECT actor_id 
FROM film_actor
WHERE film_id IN (SELECT film_id
                FROM film
               WHERE title = 'Alone Trip'));
               
#4-Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
#Identify all movies categorized as family films.
#first subquery:
SELECT category_id, category.name 
                  FROM category
                  WHERE name = 'family';

#first and second subquery:
SELECT film_id FROM film_category
          WHERE category_id IN (SELECT category_id 
                  FROM category
                  WHERE name = 'family');

#query:
SELECT title, film_id
FROM film
WHERE film_id IN (SELECT film_id FROM film_category
          WHERE category_id IN (SELECT category_id 
                  FROM category
                  WHERE name = 'family'));
                  
#5-Get name and email from customers from Canada using subqueries. Do the same with joins. Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, 
#that will help you get the relevant information.

#solution using query:

SELECT first_name, last_name, email
FROM customer
WHERE address_id IN(SELECT address_id 
            FROM address
            WHERE city_id IN (SELECT city_id
            FROM city
            WHERE country_id IN (SELECT country_id
            FROM country
            WHERE country = 'Canada')));

#solution using join:
SELECT first_name, last_name, email
FROM customer c
JOIN address a
USING(address_id)
JOIN city cc
USING(city_id)
JOIN country ccc
USING(country_id)
WHERE ccc.country = 'Canada';

#6-Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films. First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.
SELECT first_name, last_name
FROM actor
WHERE actor_id IN;
#subquery 1:finding the most prolific actor:
 SELECT MAX(num_of_films)
                  FROM (SELECT COUNT(film_id) num_of_films
                  FROM film_actor
                  GROUP BY actor_id) AS num_films;
#Query:finding the film_ids in which the prolific actor has appeared:
SELECT actor_id, film_id
FROM film_actor
WHERE actor_id IN (SELECT MAX(num_of_films)
                  FROM(SELECT
                  COUNT(film_id) num_of_films
                  FROM film_actor
                  GROUP BY actor_id) AS num_films);
                  
#find the film titles in which the prolific actor has appeared:
                  
SELECT film_id, title
FROM film
WHERE film_id IN (SELECT film_id
FROM film_actor
WHERE actor_id IN (SELECT MAX(num_of_films)
                  FROM(SELECT
                  COUNT(film_id) num_of_films
                  FROM film_actor
                  GROUP BY actor_id) AS num_films));

#7-Films rented by most profitable customer. You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments

#Subquery: Finding the largest amount of payment by cutomer_id:
SELECT MAX(amounts) max_amount
FROM (SELECT customer_id, SUM(amount) amounts
   FROM payment
   GROUP BY customer_id) AS payments
  ;

SELECT customer_id, SUM(amount) amounts
   FROM payment
   GROUP BY customer_id
   HAVING amounts = 221.55;
   
SELECT first_name, last_name FROM customer
WHERE customer_id = 526;
   
#Query: finding the customer which has made the maximum amount of payment (using join):
SELECT customer_id, first_name, last_name
FROM customer
JOIN payment
USING(customer_id)
GROUP BY customer_id
HAVING SUM(amount) =
(SELECT MAX(amounts) max_amount
FROM (SELECT customer_id, SUM(amount) amounts
   FROM payment
   GROUP BY customer_id) AS payments);

#the same solution using subquery:
SELECT customer_id, first_name, last_name
FROM customer
WHERE customer_id IN(SELECT customer_id
FROM payment
GROUP BY customer_id
HAVING SUM(amount) =
(SELECT MAX(amounts) max_amount
FROM (SELECT customer_id, SUM(amount) amounts
   FROM payment
   GROUP BY customer_id) AS payments));
                  
#8-Get the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client.
#subquery: getting the customer_ids that have spent more than the average of the total_amount spent by each client:

#Subquery1:Finding the average total amount:
SELECT AVG(total_amount) avg_total_amount
FROM(SELECT customer_id, SUM(amount) total_amount
 FROM payment
 GROUP BY customer_id) as avg_amount;
 

 #subquery2: finding the customer ids and total amount for each customer which is more than the average amount
 SELECT customer_id, SUM(amount) total_amount
 FROM payment 
 GROUP BY customer_id
 HAVING SUM(amount) > (SELECT AVG(total_amount) avg_total_amount
  FROM(SELECT customer_id, SUM(amount) total_amount
 FROM payment
 GROUP BY customer_id) as avg_amount)
 ORDER BY total_amount ASC
 ;
 
 
 #query:Finding the name of the target customers by joining the two tables of customer and payment
  SELECT a.customer_id, first_name, last_name, SUM(amount) total_amount
 FROM customer a
 JOIN payment p
 USING(customer_id)
 GROUP BY customer_id
 HAVING SUM(amount) > (SELECT AVG(total_amount) avg_total_amount
  FROM(SELECT customer_id, SUM(amount) total_amount
 FROM payment
 GROUP BY customer_id) as avg_amount)
 ORDER BY total_amount ASC
 ;