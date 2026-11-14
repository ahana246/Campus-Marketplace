-- =====================================================================
--  CAMPUS MARKETPLACE  -  07_queries.sql
--  Example queries for Unit 1 and Unit 2
--  docker exec -i cm_mysql mysql -uroot -prootpw campus_marketplace < database/demo/07_queries.sql
-- =====================================================================
USE campus_marketplace;

-- ---------------------------------------------------------------------
-- 1. Selection and projection
-- ---------------------------------------------------------------------
-- all items in NEW condition
SELECT * FROM listing WHERE item_condition = 'NEW';

-- title and price of available items under Rs 500
SELECT title, price FROM listing
WHERE status = 'AVAILABLE' AND price < 500;

-- ---------------------------------------------------------------------
-- 2. Joins
-- ---------------------------------------------------------------------
-- INNER JOIN: available listings with category and seller name
SELECT l.title, c.name AS category, u.name AS seller, l.price
FROM listing l
JOIN category c ON c.category_id = l.category_id
JOIN users u    ON u.user_id     = l.seller_id
WHERE l.status = 'AVAILABLE';

-- LEFT JOIN: every user and how many listings they posted (0 included)
SELECT u.name, COUNT(l.listing_id) AS listings
FROM users u
LEFT JOIN listing l ON l.seller_id = u.user_id
GROUP BY u.user_id, u.name;

-- SELF JOIN: sub-categories with their parent category
SELECT child.name AS sub_category, parent.name AS parent_category
FROM category child
JOIN category parent ON parent.category_id = child.parent_category_id;

-- ---------------------------------------------------------------------
-- 3. Set operations
-- ---------------------------------------------------------------------
-- UNION: users who have sold OR requested something
SELECT seller_id AS user_id FROM listing
UNION
SELECT buyer_id FROM purchase_request;

-- INTERSECT: users who have both sold and requested
SELECT seller_id FROM listing
INTERSECT
SELECT buyer_id FROM purchase_request;

-- EXCEPT: users who have listed items but never requested anything
SELECT seller_id FROM listing
EXCEPT
SELECT buyer_id FROM purchase_request;

-- ---------------------------------------------------------------------
-- 4. Aggregate functions, GROUP BY, HAVING
-- ---------------------------------------------------------------------
SELECT COUNT(*) AS total, AVG(price) AS avg_price, MAX(price) AS max_price
FROM listing;

-- number of listings in each status
SELECT status, COUNT(*) AS n
FROM listing
GROUP BY status;

-- categories with more than 2 listings
SELECT c.name, COUNT(*) AS listings
FROM listing l JOIN category c ON c.category_id = l.category_id
GROUP BY c.name
HAVING COUNT(*) > 2;

-- ---------------------------------------------------------------------
-- 5. NULL values
-- ---------------------------------------------------------------------
SELECT name, email FROM users WHERE phone IS NULL;

SELECT request_id, COALESCE(offered_price, 0) AS offered
FROM purchase_request;

-- ---------------------------------------------------------------------
-- 6. Nested subqueries
-- ---------------------------------------------------------------------
-- listings priced above the average price
SELECT title, price FROM listing
WHERE price > (SELECT AVG(price) FROM listing);

-- users who never placed a request
SELECT name FROM users
WHERE user_id NOT IN (SELECT buyer_id FROM purchase_request);

-- ---------------------------------------------------------------------
-- 7. Correlated subqueries
-- ---------------------------------------------------------------------
-- listings priced above the average of their own category
SELECT l.title, l.price
FROM listing l
WHERE l.price > (SELECT AVG(l2.price) FROM listing l2
                 WHERE l2.category_id = l.category_id);

-- available listings nobody has requested yet
SELECT l.title
FROM listing l
WHERE l.status = 'AVAILABLE'
  AND NOT EXISTS (SELECT 1 FROM purchase_request r WHERE r.listing_id = l.listing_id);

-- ---------------------------------------------------------------------
-- 8. CTE and recursive CTE
-- ---------------------------------------------------------------------
-- CTE: total earned by each seller
WITH seller_revenue AS (
  SELECT l.seller_id, SUM(t.amount) AS revenue
  FROM transactions t
  JOIN purchase_request r ON r.request_id = t.request_id
  JOIN listing l          ON l.listing_id = r.listing_id
  GROUP BY l.seller_id
)
SELECT u.name, s.revenue
FROM seller_revenue s JOIN users u ON u.user_id = s.seller_id
ORDER BY s.revenue DESC;

-- RECURSIVE CTE: the whole category tree with its depth
WITH RECURSIVE tree AS (
  SELECT category_id, name, 0 AS depth
  FROM category WHERE parent_category_id IS NULL
  UNION ALL
  SELECT c.category_id, c.name, t.depth + 1
  FROM category c JOIN tree t ON c.parent_category_id = t.category_id
)
SELECT * FROM tree ORDER BY depth, name;

-- ---------------------------------------------------------------------
-- 9. Window functions
-- ---------------------------------------------------------------------
-- rank listings by price inside each category
SELECT category_id, title, price,
       RANK() OVER (PARTITION BY category_id ORDER BY price DESC) AS price_rank
FROM listing;

-- running total of money exchanged over time
SELECT transaction_id, completed_at, amount,
       SUM(amount) OVER (ORDER BY completed_at) AS running_total
FROM transactions;

-- ---------------------------------------------------------------------
-- 10. Full-text search
-- ---------------------------------------------------------------------
SELECT title, MATCH(title, description) AGAINST ('programming book') AS score
FROM listing
WHERE MATCH(title, description) AGAINST ('programming book');

SELECT title FROM listing
WHERE MATCH(title, description) AGAINST ('+calculator -basic' IN BOOLEAN MODE);

-- ---------------------------------------------------------------------
-- 11. Views and function
-- ---------------------------------------------------------------------
SELECT title, category_name, seller_name, seller_rating
FROM v_listing_details WHERE status = 'AVAILABLE';

SELECT * FROM v_seller_stats ORDER BY revenue DESC;

SELECT name, fn_user_rating(user_id) AS rating FROM users;

-- ---------------------------------------------------------------------
-- 12. Database modification (INSERT / UPDATE / DELETE)
-- ---------------------------------------------------------------------
INSERT INTO listing (seller_id, category_id, title, price)
VALUES (3, 5, 'Casio fx-570ES Plus', 600);
SELECT title, price FROM listing WHERE listing_id = LAST_INSERT_ID();

UPDATE listing SET price = price - 50
WHERE status = 'AVAILABLE' AND price > 600;

DELETE FROM listing WHERE title = 'Casio fx-570ES Plus';

-- trigger error: you cannot request your own listing
-- INSERT INTO purchase_request (listing_id, buyer_id) VALUES (1, 2);
