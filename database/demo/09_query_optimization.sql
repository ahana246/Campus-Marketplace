-- =====================================================================
--  CAMPUS MARKETPLACE  -  09_query_optimization.sql
--  Unit 3: query processing and optimisation with EXPLAIN
-- =====================================================================
USE campus_marketplace;

-- Uses the index idx_listing_status (type = ref)
EXPLAIN SELECT title, price FROM listing
WHERE status = 'AVAILABLE' AND category_id = 2;

-- Same query without the index: full table scan (type = ALL)
EXPLAIN SELECT title, price FROM listing IGNORE INDEX (idx_listing_status)
WHERE status = 'AVAILABLE' AND category_id = 2;

-- LIKE '%word%' cannot use an index, the full-text index can
EXPLAIN SELECT title FROM listing WHERE description LIKE '%calculator%';
EXPLAIN SELECT title FROM listing WHERE MATCH(title, description) AGAINST ('calculator');

-- Join plan chosen by the optimiser
EXPLAIN FORMAT = TREE
SELECT u.name, COUNT(*) AS deals
FROM transactions t
JOIN purchase_request r ON r.request_id = t.request_id
JOIN listing l          ON l.listing_id = r.listing_id
JOIN users u            ON u.user_id    = l.seller_id
GROUP BY u.name;

SHOW INDEX FROM listing;
