USE sakila;

-- Consulta 1: Determinar el número de copias de la película "Hunchback Impossible" en el sistema de inventario
SELECT COUNT(*) AS Numero_de_Copias
FROM inventory i
JOIN film f ON i.film_id = f.film_id
WHERE f.title = 'Hunchback Impossible';

USE sakila;

-- Consulta 2: Listar todas las películas cuya duración es mayor que la duración promedio de todas las películas en la base de datos
SELECT title AS Titulo
FROM film
WHERE length > (
    SELECT AVG(length)
    FROM film
);

-- Ejecutar subconsulta por separado para verificar la duración promedio
SELECT AVG(length)
FROM film;

-- Consulta 3: Usar una subconsulta para mostrar todos los actores que aparecen en la película "Alone Trip"
SELECT a.actor_id, a.first_name, a.last_name
FROM actor a
WHERE a.actor_id IN (
    SELECT fa.actor_id
    FROM film_actor fa
    JOIN film f ON fa.film_id = f.film_id
    WHERE f.title = 'Alone Trip'
);

-- Consulta 4 (Bonus): Identificar todas las películas categorizadas como películas familiares
SELECT f.title AS Titulo
FROM film f
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
WHERE c.name = 'Family';

-- Consulta 5 (Bonus): Recuperar el nombre y el correo electrónico de los clientes de Canadá usando tanto subconsultas como joins
-- Usando subconsulta
SELECT c.first_name, c.last_name, c.email
FROM customer c
WHERE c.address_id IN (
    SELECT a.address_id
    FROM address a
    JOIN city ci ON a.city_id = ci.city_id
    JOIN country co ON ci.country_id = co.country_id
    WHERE co.country = 'Canada'
);

-- Usando joins
SELECT c.first_name, c.last_name, c.email
FROM customer c
JOIN address a ON c.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id
WHERE co.country = 'Canada';

-- Consulta 6 (Bonus): Determinar qué películas fueron protagonizadas por el actor más prolífico en la base de datos Sakila
-- Encontrar el actor más prolífico
SET @most_prolific_actor_id = (
    SELECT actor_id
    FROM film_actor
    GROUP BY actor_id
    ORDER BY COUNT(film_id) DESC
    LIMIT 1
);

-- Encontrar las películas protagonizadas por ese actor
SELECT f.title AS Titulo
FROM film f
JOIN film_actor fa ON f.film_id = fa.film_id
WHERE fa.actor_id = @most_prolific_actor_id;

-- Consulta 7 (Bonus): Encontrar las películas alquiladas por el cliente más rentable en la base de datos Sakila
-- Encontrar el cliente más rentable
SET @most_profitable_customer_id = (
    SELECT customer_id
    FROM payment
    GROUP BY customer_id
    ORDER BY SUM(amount) DESC
    LIMIT 1
);

-- Encontrar las películas alquiladas por ese cliente
SELECT f.title AS Titulo
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
WHERE r.customer_id = @most_profitable_customer_id;

-- Consulta 8 (Bonus): Recuperar el client_id y el total_amount_spent de aquellos clientes que gastaron más que el promedio del total gastado por cada cliente
SELECT customer_id, total_amount_spent
FROM (
    SELECT customer_id, SUM(amount) AS total_amount_spent
    FROM payment
    GROUP BY customer_id
) AS total_spent
WHERE total_amount_spent > (
    SELECT AVG(total_amount_spent)
    FROM (
        SELECT SUM(amount) AS total_amount_spent
        FROM payment
        GROUP BY customer_id
    ) AS avg_spent
);