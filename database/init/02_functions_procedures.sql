-- =====================================================================
--  CAMPUS MARKETPLACE  -  02_functions_procedures.sql
--  1 function + 2 procedures (both procedures use a TRANSACTION)
-- =====================================================================
USE campus_marketplace;

DELIMITER $$

-- Average rating a user has received (NULL if no reviews yet)
CREATE FUNCTION fn_user_rating(p_user_id INT)
RETURNS DECIMAL(3,2)
READS SQL DATA
BEGIN
  DECLARE v_avg DECIMAL(3,2);
  SELECT ROUND(AVG(rating), 2) INTO v_avg
  FROM review
  WHERE reviewee_id = p_user_id;
  RETURN v_avg;
END$$

-- Seller accepts one request.
-- In ONE transaction: lock the listing row, accept this request,
-- reject every other pending request, and reserve the listing.
-- FOR UPDATE stops two requests being accepted at the same time.
CREATE PROCEDURE sp_accept_request(IN p_request_id INT, IN p_seller_id INT)
BEGIN
  DECLARE v_listing_id INT;
  DECLARE v_seller_id  INT;
  DECLARE v_status     VARCHAR(20);

  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  START TRANSACTION;

  SELECT listing_id INTO v_listing_id
  FROM purchase_request
  WHERE request_id = p_request_id AND status = 'PENDING';

  SELECT seller_id, status INTO v_seller_id, v_status
  FROM listing
  WHERE listing_id = v_listing_id
  FOR UPDATE;

  IF v_listing_id IS NULL OR v_seller_id <> p_seller_id THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You cannot accept this request';
  END IF;
  IF v_status <> 'AVAILABLE' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Listing is no longer available';
  END IF;

  UPDATE purchase_request SET status = 'ACCEPTED' WHERE request_id = p_request_id;
  UPDATE purchase_request SET status = 'REJECTED'
   WHERE listing_id = v_listing_id AND status = 'PENDING';
  UPDATE listing SET status = 'RESERVED' WHERE listing_id = v_listing_id;

  COMMIT;
END$$

-- Seller confirms the buyer has paid for an ACCEPTED request.
-- In ONE transaction: insert the transaction row and close the listing.
CREATE PROCEDURE sp_complete_transaction(IN p_request_id INT, IN p_seller_id INT, IN p_payment_mode VARCHAR(5))
BEGIN
  DECLARE v_listing_id INT;
  DECLARE v_amount     DECIMAL(10,2);
  DECLARE v_seller_id  INT;

  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  START TRANSACTION;

  SELECT r.listing_id, r.offered_price, l.seller_id
    INTO v_listing_id, v_amount, v_seller_id
  FROM purchase_request r
  JOIN listing l ON l.listing_id = r.listing_id
  WHERE r.request_id = p_request_id AND r.status = 'ACCEPTED'
  FOR UPDATE;

  IF v_listing_id IS NULL OR v_seller_id <> p_seller_id THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You cannot complete this request';
  END IF;

  INSERT INTO transactions (request_id, amount, payment_mode)
  VALUES (p_request_id, v_amount, p_payment_mode);

  UPDATE listing SET status = 'CLOSED' WHERE listing_id = v_listing_id;

  COMMIT;
END$$

DELIMITER ;
