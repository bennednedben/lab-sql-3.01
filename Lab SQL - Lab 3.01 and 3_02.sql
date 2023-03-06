-- Lab | SQL - Lab 3.01
-- Activity 1
-- 1 Drop column picture from staff.
Use sakila;
ALTER TABLE staff DROP COLUMN picture;
SELECT * FROM sakila.staff;


-- 2 A new person is hired to help Jon. Her name is TAMMY SANDERS, and she is a customer. Update the database accordingly.
INSERT INTO staff (staff_id,first_name,last_name,address_id,email,store_id,active,username,password,last_update)
VALUES (3,'Tammy','Sanders',79,'TAMMY.SANDERS@sakilastaff.com',2,1,'Tammy',NULL,'2006-02-15 04:57:21');


-- 3 Add rental for movie "Academy Dinosaur" by Charlotte Hunter from Mike Hillyer at Store 1. 
--   You can use current date for the rental_date column in the rental table. Hint: Check the columns in the table rental and see what information you would need to add there. 
--   You can query those pieces of information. For eg., you would notice that you need customer_id information as well. To get that you can use the following query:
-- "Academy Dinosaur" film_id=1 / inventory_id=1
-- Charlotte Hunter costumer_id=130
-- Mike Hillyer stuff_id=1
-- store 1 store_id=1
INSERT INTO `sakila`.`rental` (`rental_id`, `rental_date`, `inventory_id`, `customer_id`, `return_date`, `staff_id`, `last_update`) 
VALUES ('16050', '2023-03-06 16:14:12', '1', '130', '2023-03-07 16:14:12', '1', '2023-03-07 16:14:12');


-- Activity 2
-- Use dbdiagram.io or draw.io to propose a new structure for the Sakila database.
-- Define primary keys and foreign keys for the new database.
Create Database IF NOT EXISTS new_sakila;
CREATE TABLE `new_sakila`.`customer` (
  `idcustomer` INT NOT NULL,
  `first_name` VARCHAR(45) NULL,
  `last_name` VARCHAR(45) NULL,
  `email` VARCHAR(45) NULL,
  `film_id` INT NULL,
  PRIMARY KEY (`idcustomer`),
  INDEX `film_id2_idx` (`film_id` ASC) VISIBLE,
  CONSTRAINT `film_id2`
    FOREIGN KEY (`film_id`)
    REFERENCES `new_sakila`.`film` (`idfilm`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);
  
CREATE TABLE `new_sakila`.`film` (
  `idfilm` INT NOT NULL,
  `title` VARCHAR(45) NULL,
  `length` VARCHAR(45) NULL,
  PRIMARY KEY (`idfilm`),
  UNIQUE INDEX `title_UNIQUE` (`title` ASC) VISIBLE);
  
CREATE TABLE `new_sakila`.`inventory` (
  `idinventory` INT NOT NULL,
  `film_id` VARCHAR(45) NULL,
  PRIMARY KEY (`idinventory`),
  INDEX `film_id_idx` (`film_id` ASC) VISIBLE,
  CONSTRAINT `film_id`
    FOREIGN KEY (`film_id`)
    REFERENCES `new_sakila`.`film` (`title`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);
    
CREATE TABLE `new_sakila`.`rental` (
  `idrental` INT NOT NULL,
  `rental_date` DATE NOT NULL,
  `inventory_id` INT NULL,
  PRIMARY KEY (`idrental`),
  INDEX `inventory_id_idx` (`inventory_id` ASC) VISIBLE,
  CONSTRAINT `inventory_id`
    FOREIGN KEY (`inventory_id`)
    REFERENCES `new_sakila`.`inventory` (`idinventory`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);

CREATE TABLE `new_sakila`.`owner` (
  `idowner` INT NOT NULL,
  `first_name` VARCHAR(45) NULL,
  `last_name` VARCHAR(45) NULL,
  PRIMARY KEY (`idowner`));
  
CREATE TABLE `new_sakila`.`store` (
  `idstore` INT NOT NULL,
  `adress` VARCHAR(45) NULL,
  `owner_id` INT NULL,
  PRIMARY KEY (`idstore`),
  INDEX `owner_id_idx` (`owner_id` ASC) VISIBLE,
  CONSTRAINT `owner_id`
    FOREIGN KEY (`owner_id`)
    REFERENCES `new_sakila`.`owner` (`idowner`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);
-- look in repository for ER_Model.jpg

-- -----------------------------------------------------------------------------------------------------------------

-- Lab | SQL Subqueries 3.02
-- In this lab, you will be using the Sakila database of movie rentals. Create appropriate joins wherever necessary.

-- 1 How many copies of the film Hunchback Impossible exist in the inventory system?
-- Hunchback Impossible FILM_ID=439
SELECT COUNT(*) AS copies
FROM sakila.inventory
INNER JOIN sakila.film
USING (film_id)
WHERE film.title = 'Hunchback Impossible';


-- 2 List all films whose length is longer than the average of all the films.
SELECT title, length
FROM sakila.film
WHERE length > (SELECT AVG(length)
                FROM sakila.film);


-- 3 Use subqueries to display all actors who appear in the film Alone Trip.
SELECT CONCAT(actor.first_name," ", actor.last_name) AS name
FROM sakila.actor 
JOIN film_actor USING (actor_id)
WHERE film_actor.film_id IN (
 SELECT film_id
    FROM sakila.film
    WHERE title = 'ALONE TRIP');


-- 4 Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.
SELECT film_id, title FROM sakila.film
JOIN sakila.film_category 
USING (film_id)
JOIN sakila.category 
USING (category_id)
WHERE name = 'Family';


-- 5 Get name and email from customers from Canada using subqueries. Do the same with joins. Note that to create a join, 
-- you will have to identify the correct tables with their primary keys and foreign keys, that will help you get the relevant information.
SELECT CONCAT(first_name," ", last_name) AS name , email
FROM sakila.customer
WHERE address_id IN (
	SELECT address_id
	FROM sakila.address
	WHERE city_id IN (
		SELECT city_id 
		FROM sakila.city 
		JOIN country 
		USING (country_id)
		WHERE country='Canada'
    )
);


SELECT CONCAT(first_name," ", last_name) AS name , email
FROM customer 
JOIN address 
USING (address_id)
	JOIN city 
	USING (city_id)
		JOIN country 
		USING (country_id)
		WHERE country = 'Canada';


-- 6 Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films. 
-- First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.
-- find the most prolific actor:
SELECT actor_id, count(film_id) as film 
FROM sakila.film_actor
GROUP BY actor_id
ORDER BY film DESC;
-- >actor_id=107 (42 films)

-- Which are films
SELECT title 
FROM sakila.film
WHERE film_id IN (
	SELECT film_id 
    FROM sakila.film 
	JOIN film_actor 
    USING (film_id) 
	WHERE film_actor.actor_id=107);


-- 7 Films rented by most profitable customer. You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments
-- Customers who spent more than the average payments.
-- get customer_id
SELECT customer_id , SUM(amount) 
FROM payment
GROUP BY customer_id
ORDER BY sum(amount) DESC
LIMIT 1;
-- customer_id=526

-- Films rented by most profitable customer
SELECT title
FROM sakila.film
WHERE film_id IN (
 SELECT film_id
 FROM sakila.inventory
 WHERE inventory_id IN (
  SELECT inventory_id
  FROM sakila.rental
  WHERE customer_id = 526)
);

-- Customers who spent more than the average payments.
SELECT CONCAT(first_name," ", last_name) AS name
FROM sakila.customer
WHERE customer.customer_id IN (
	SELECT payment.customer_id
	FROM payment
	GROUP BY payment.customer_id
	HAVING AVG(payment.amount) > (
		SELECT AVG(amount)
		FROM payment)
);
