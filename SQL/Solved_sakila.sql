-- Use Sakila db
USE sakila;

-- * 1a. Display the first and last names of all actors from the table `actor`.
-- 
SELECT 
    first_name, last_name
FROM
    actor;

-- * 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
-- 
SELECT 
    UPPER(CONCAT(first_name, ' ', last_name)) AS 'Actor Name'
FROM
    actor;

-- * 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe."
-- What is one query would you use to obtain this information?
-- 
SELECT 
    actor_id, first_name, last_name
FROM
    actor
WHERE
    UPPER(first_name) = 'JOE';

-- * 2b. Find all actors whose last name contain the letters `GEN`:
-- 
SELECT 
    first_name, last_name
FROM
    actor
WHERE
    UPPER(last_name) LIKE '%GEN%';

-- * 2c. Find all actors whose last names contain the letters `LI`. 
-- This time, order the rows by last name and first name, in that order:
-- 
SELECT 
    first_name, last_name
FROM
    actor
WHERE
    UPPER(last_name) LIKE '%LI%'
ORDER BY last_name , first_name;

-- * 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: 
-- Afghanistan, Bangladesh, and China:
-- 
SELECT 
    country_id, country
FROM
    country
WHERE
    country IN ('Afghanistan' , 'Bangladesh', 'China');

-- * 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description,
-- so create a column in the table `actor` named `description` and use the data type `BLOB`
-- (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
-- 
ALTER TABLE actor
ADD description BLOB;

-- * 3b. Very quickly you realize that entering descriptions for each actor is too much effort. 
-- Delete the `description` column.
-- 
ALTER TABLE actor
DROP description;

-- * 4a. List the last names of actors, as well as how many actors have that last name.
-- 
SELECT 
    last_name, COUNT(last_name) AS count
FROM
    actor
GROUP BY last_name;

-- * 4b. List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors
-- 
SELECT 
    last_name, COUNT(last_name) AS count
FROM
    actor
GROUP BY last_name
HAVING COUNT(last_name) > 1;

-- * 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. 
-- Write a query to fix the record.
-- 
UPDATE actor 
SET 
    first_name = 'HARPO'
WHERE
    first_name = 'GROUCHO'
        AND last_name = 'WILLIAMS';

-- * 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name
-- after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
-- 
UPDATE actor 
SET 
    first_name = 'GROUCHO'
WHERE
    first_name = 'HARPO';

-- * 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
-- * Hint: [https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html](https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html)
-- 
SHOW CREATE TABLE address;

-- * 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member.
-- Use the tables `staff` and `address`:
-- 
SELECT 
    s.first_name, s.last_name, a.address
FROM
    address a
        JOIN
    staff s ON (a.address_id = s.address_id);

-- * 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005.
-- Use tables `staff` and `payment`.
-- 
SELECT 
    s.first_name, s.last_name, SUM(p.amount) as total_amount
FROM
    payment p
        JOIN
    staff s ON (p.staff_id = s.staff_id)
GROUP BY p.staff_id;

-- * 6c. List each film and the number of actors who are listed for that film.
-- Use tables `film_actor` and `film`. Use inner join.
--
SELECT 
    f.title, COUNT(a.actor_id) as num_actors
FROM
    film_actor a
        JOIN
    film f ON (a.film_id = f.film_id)
GROUP BY f.film_id;

-- * 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
-- 
SELECT 
    f.title, COUNT(i.inventory_id) AS inventory_copies
FROM
    inventory i
        JOIN
    film f ON (i.film_id = f.film_id)
GROUP BY f.film_id
HAVING (LOWER(f.title) = 'hunchback impossible');

-- * 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer.
-- List the customers alphabetically by last name: 
--   ![Total amount paid](Images/total_payment.png)
-- 
SELECT 
    c.first_name, c.last_name, SUM(p.amount) AS total_paid
FROM
    payment p
        JOIN
    customer c ON (p.customer_id = c.customer_id)
GROUP BY p.customer_id
ORDER BY c.last_name;

-- * 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence.
-- As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity.
-- Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
-- 
SELECT 
    title
FROM
    film
WHERE
    ((UPPER(title) LIKE 'K%')
        OR (UPPER(title) LIKE 'Q%'))
        AND language_id IN (SELECT 
            language_id
        FROM
            language
        WHERE
            LOWER(name) = 'english');
-- same using joins
SELECT 
    f.title
FROM
    film f
        JOIN
    language l ON (f.language_id = l.language_id)
WHERE
    (LOWER(l.name) = 'english')
        AND ((UPPER(f.title) LIKE 'K%')
        OR (UPPER(f.title) LIKE 'Q%'));

-- * 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
-- 
SELECT 
    first_name, last_name
FROM
    actor
WHERE
    actor_id IN (SELECT 
            actor_id
        FROM
            film_actor
        WHERE
            film_id IN (SELECT 
                    film_id
                FROM
                    film
                WHERE
                    (LOWER(title) = 'alone trip')));
-- same using joins
SELECT 
    a.first_name, a.last_name
FROM
    actor a
        JOIN
    film_actor fa
        JOIN
    film f ON ((fa.film_id = f.film_id)
        AND (fa.actor_id = a.actor_id))
WHERE
    (LOWER(f.title) = 'alone trip');

-- * 7c. You want to run an email marketing campaign in Canada,
-- for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
-- 
SELECT 
    c.first_name, c.last_name, c.email
FROM
    customer c
        JOIN
    address a
        JOIN
    city ct
        JOIN
    country cy ON ((c.address_id = a.address_id)
        AND (a.city_id = ct.city_id)
        AND (ct.country_id = cy.country_id))
WHERE
    (LOWER(cy.country) = 'canada');

-- * 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion.
-- Identify all movies categorized as _family_ films.
-- 
SELECT 
    f.title
FROM
    film f
        JOIN
    film_category fc
        JOIN
    category c ON ((f.film_id = fc.film_id)
        AND (fc.category_id = c.category_id))
WHERE
    (LOWER(c.name) = 'family');

-- * 7e. Display the most frequently rented movies in descending order.
-- 
SELECT 
    f.title, COUNT(r.rental_id) AS rental_count
FROM
    rental r
        JOIN
    inventory i
        JOIN
    film f ON ((r.inventory_id = i.inventory_id)
        AND (i.film_id = f.film_id))
GROUP BY f.film_id
ORDER BY rental_count DESC;

-- * 7f. Write a query to display how much business, in dollars, each store brought in.
-- 
SELECT 
    s.store_id, SUM(p.amount) AS total_business
FROM
    store s
        JOIN
    inventory i
        JOIN
    rental r
        JOIN
    payment p ON ((s.store_id = i.store_id)
        AND (i.inventory_id = r.inventory_id)
        AND (r.rental_id = p.rental_id))
GROUP BY s.store_id;

-- * 7g. Write a query to display for each store its store ID, city, and country.
-- 
SELECT 
    s.store_id, ct.city, cy.country
FROM
    store s
        JOIN
    address a
        JOIN
    city ct
        JOIN
    country cy ON ((s.address_id = a.address_id)
        AND (a.city_id = ct.city_id)
        AND (ct.country_id = cy.country_id));

-- * 7h. List the top five genres in gross revenue in descending order.
-- (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
-- 
SELECT 
    c.name, SUM(p.amount) AS gross_revenue
FROM
    category c
        JOIN
    film_category fc
        JOIN
    inventory i
        JOIN
    rental r
        JOIN
    payment p ON ((c.category_id = fc.category_id)
        AND (fc.film_id = i.film_id)
        AND (i.inventory_id = r.inventory_id)
        AND (r.rental_id = p.rental_id))
GROUP BY c.category_id
ORDER BY gross_revenue DESC;

-- * 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue.
-- Use the solution from the problem above to create a view.
-- If you haven't solved 7h, you can substitute another query to create a view.
-- 
CREATE VIEW top_five_genres AS
    SELECT 
        c.name, SUM(p.amount) AS gross_revenue
    FROM
        category c
            JOIN
        film_category fc
            JOIN
        inventory i
            JOIN
        rental r
            JOIN
        payment p ON ((c.category_id = fc.category_id)
            AND (fc.film_id = i.film_id)
            AND (i.inventory_id = r.inventory_id)
            AND (r.rental_id = p.rental_id))
    GROUP BY c.category_id
    ORDER BY gross_revenue DESC
    LIMIT 5;

-- * 8b. How would you display the view that you created in 8a?
-- 
SELECT 
    *
FROM
    top_five_genres;

-- * 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW top_five_genres;


