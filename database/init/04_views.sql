-- =====================================================================
--  CAMPUS MARKETPLACE  -  04_views.sql
-- =====================================================================
USE campus_marketplace;

-- Listing with its category name, seller name and seller rating
CREATE VIEW v_listing_details AS
SELECT l.*,
       c.name                    AS category_name,
       u.name                    AS seller_name,
       fn_user_rating(u.user_id) AS seller_rating
FROM listing l
JOIN category c ON c.category_id = l.category_id
JOIN users u    ON u.user_id     = l.seller_id;

-- Number of deals and money earned by every student seller
CREATE VIEW v_seller_stats AS
SELECT u.user_id,
       u.name,
       COUNT(t.transaction_id)    AS deals,
       COALESCE(SUM(t.amount), 0) AS revenue,
       fn_user_rating(u.user_id)  AS rating
FROM users u
LEFT JOIN listing l          ON l.seller_id  = u.user_id
LEFT JOIN purchase_request r ON r.listing_id = l.listing_id
LEFT JOIN transactions t     ON t.request_id = r.request_id
WHERE u.role = 'STUDENT'
GROUP BY u.user_id, u.name;
