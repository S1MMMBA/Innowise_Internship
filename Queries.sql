--Вывести количество фильмов в каждой категории, отсортировать по убыванию.

SELECT c.name AS Name, COUNT(fc.film_id) AS NumOfFilms
FROM  film_category fc JOIN category c
	ON fc.category_id = c.category_id
GROUP BY c.name
ORDER BY NumOfFilms DESC

--Вывести 10 актеров, чьи фильмы большего всего арендовали, отсортировать по убыванию.

SELECT a.actor_id,a.first_name,a.last_name,COUNT(r.rental_id) AS RentNum
FROM actor a 
JOIN film_actor fa
ON a.actor_id = fa.actor_id
JOIN inventory inv
ON fa.film_id = inv.film_id
JOIN rental r
ON inv.inventory_id = r.inventory_id
GROUP BY a.actor_id,a.first_name,a.last_name
ORDER BY RentNum DESC
LIMIT 10

--Вывести категорию фильмов, на которую потратили больше всего денег.

SELECT c.category_id,c.name,SUM(p.amount) AS Amount
FROM category c
JOIN film_category fc
ON c.category_id = fc.category_id
JOIN inventory inv
ON fc.film_id = inv.film_id
JOIN rental r
ON inv.inventory_id = r.inventory_id
JOIN payment p
ON r.rental_id = p.rental_id
GROUP BY c.category_id,c.name 
ORDER BY Amount DESC
LIMIT 1

--Вывести названия фильмов, которых нет в inventory. Написать запрос без использования оператора IN.

SELECT f.title
FROM film f

EXCEPT

SELECT f.title
FROM inventory inv JOIN film f
ON inv.film_id = f.film_id

--Вывести топ 3 актеров, которые больше всего появлялись в фильмах в категории “Children”. Если у нескольких актеров одинаковое кол-во фильмов, вывести всех.

SELECT first_name,last_name,Num
FROM	
	(
			SELECT a.first_name,a.last_name,COUNT(fc.film_id) AS Num,
			DENSE_RANK() OVER (ORDER BY COUNT(fc.film_id) DESC) AS rank
		FROM film_category fc 
		JOIN category c
			ON fc.category_id = c.category_id AND c.name = 'Children'
		JOIN film_actor fa
			ON fc.film_id = fa.film_id
		JOIN actor a
			ON fa.actor_id = a.actor_id
		GROUP BY a.first_name,a.last_name
	) AS sub
WHERE rank <= 3
ORDER BY Num DESC

--Вывести города с количеством активных и неактивных клиентов (активный — customer.active = 1). Отсортировать по количеству неактивных клиентов по убыванию.

SELECT c.city,
	COUNT(CASE WHEN cust.active = 1 THEN 1 ELSE NULL END) AS ActiveNum,
	COUNT(CASE WHEN cust.active = 0 THEN 1 ELSE NULL END) AS NonActiveNum
FROM customer cust 
LEFT JOIN address a
	ON cust.address_id = a.address_id
  JOIN city c
	ON a.city_id = c.city_id
GROUP BY c.city
ORDER BY NonActiveNum DESC

--Вывести категорию фильмов, у которой самое большое кол-во часов суммарной аренды в городах (customer.address_id в этом city), и которые начинаются на букву “a”. То же самое сделать для городов в которых есть символ “-”.

SELECT * FROM (
    (SELECT c.name,
        SUM(EXTRACT(EPOCH FROM ( r.return_date- r.rental_date)) / 3600) AS Num
    FROM category c
    JOIN film_category fc ON c.category_id = fc.category_id
    JOIN inventory inv ON fc.film_id = inv.film_id
    JOIN rental r ON inv.inventory_id = r.inventory_id
    JOIN customer cust ON r.customer_id = cust.customer_id
    JOIN address a ON cust.address_id = a.address_id
    JOIN city cit ON a.city_id = cit.city_id
    WHERE cit.city LIKE 'a%'
    GROUP BY c.name
    ORDER BY Num DESC
    LIMIT 1)
    UNION ALL
    (SELECT c.name,
        SUM(EXTRACT(EPOCH FROM ( r.return_date- r.rental_date)) / 3600) AS Num
    FROM category c
    JOIN film_category fc ON c.category_id = fc.category_id
    JOIN inventory inv ON fc.film_id = inv.film_id
    JOIN rental r ON inv.inventory_id = r.inventory_id
    JOIN customer cust ON r.customer_id = cust.customer_id
    JOIN address a ON cust.address_id = a.address_id
    JOIN city cit ON a.city_id = cit.city_id
    WHERE cit.city LIKE '%-%'
    GROUP BY c.name
    ORDER BY Num DESC
    LIMIT 1)
) AS result;
