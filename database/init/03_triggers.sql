-- =====================================================================
--  CAMPUS MARKETPLACE  -  03_triggers.sql
--  3 triggers: 2 check business rules, 1 writes an audit log
-- =====================================================================
USE campus_marketplace;

DELIMITER $$

-- 1. A request is only allowed on an AVAILABLE listing that is not your own
CREATE TRIGGER trg_request_before_insert
BEFORE INSERT ON purchase_request
FOR EACH ROW
BEGIN
  DECLARE v_seller INT;
  DECLARE v_status VARCHAR(20);

  SELECT seller_id, status INTO v_seller, v_status
  FROM listing WHERE listing_id = NEW.listing_id;

  IF v_seller = NEW.buyer_id THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You cannot request your own listing';
  END IF;
  IF v_status <> 'AVAILABLE' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Listing is not available';
  END IF;
END$$

-- 2. Only the buyer or the seller of a transaction can review it
CREATE TRIGGER trg_review_before_insert
BEFORE INSERT ON review
FOR EACH ROW
BEGIN
  DECLARE v_buyer  INT;
  DECLARE v_seller INT;

  SELECT r.buyer_id, l.seller_id INTO v_buyer, v_seller
  FROM transactions t
  JOIN purchase_request r ON r.request_id = t.request_id
  JOIN listing l          ON l.listing_id = r.listing_id
  WHERE t.transaction_id = NEW.transaction_id;

  IF NOT ((NEW.reviewer_id = v_buyer  AND NEW.reviewee_id = v_seller) OR
          (NEW.reviewer_id = v_seller AND NEW.reviewee_id = v_buyer)) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Only the buyer and seller of this deal can review it';
  END IF;
END$$

-- 3. Log every status change of a listing
CREATE TRIGGER trg_listing_after_update
AFTER UPDATE ON listing
FOR EACH ROW
BEGIN
  IF OLD.status <> NEW.status THEN
    INSERT INTO audit_log (listing_id, old_status, new_status)
    VALUES (NEW.listing_id, OLD.status, NEW.status);
  END IF;
END$$

DELIMITER ;
