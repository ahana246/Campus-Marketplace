-- =====================================================================
--  CAMPUS MARKETPLACE  -  08_transactions_concurrency.sql
--  Unit 4: transactions, concurrency control and locking
-- =====================================================================
USE campus_marketplace;

-- ---------------------------------------------------------------------
-- 1. COMMIT / ROLLBACK / SAVEPOINT (one session)
-- ---------------------------------------------------------------------
START TRANSACTION;
  UPDATE listing SET price = price + 100 WHERE listing_id = 1;
  SAVEPOINT after_price;
  UPDATE listing SET status = 'CLOSED' WHERE listing_id = 1;
  ROLLBACK TO SAVEPOINT after_price;      -- undo only the status change
  SELECT price, status FROM listing WHERE listing_id = 1;
ROLLBACK;                                 -- undo everything
SELECT price, status FROM listing WHERE listing_id = 1;

-- ---------------------------------------------------------------------
-- 2. Locking with SELECT ... FOR UPDATE (needs TWO terminals)
--    Two buyers racing for the same mattress (listing 24)
-- ---------------------------------------------------------------------
-- Terminal A:  START TRANSACTION;
--              SELECT status FROM listing WHERE listing_id = 24 FOR UPDATE;
-- Terminal B:  START TRANSACTION;
--              SELECT status FROM listing WHERE listing_id = 24 FOR UPDATE;   -- waits
-- Terminal A:  UPDATE listing SET status = 'RESERVED' WHERE listing_id = 24;
--              COMMIT;                                                       -- B continues
-- Terminal B:  sees RESERVED, so it must not sell the item again;  ROLLBACK;
--
-- The procedure sp_accept_request does exactly this. Requests 17 and 18
-- are both for listing 24 (seller 5):
-- Terminal A:  CALL sp_accept_request(17, 5);   -- succeeds
-- Terminal B:  CALL sp_accept_request(18, 5);   -- ERROR: You cannot accept this request

-- ---------------------------------------------------------------------
-- 3. Isolation levels
-- ---------------------------------------------------------------------
SELECT @@transaction_isolation;      -- MySQL default: REPEATABLE-READ

-- Terminal A:  START TRANSACTION;
--              SELECT price FROM listing WHERE listing_id = 14;   -- 700
-- Terminal B:  UPDATE listing SET price = 999 WHERE listing_id = 14;
-- Terminal A:  SELECT price FROM listing WHERE listing_id = 14;   -- still 700 (repeatable read)
--              COMMIT;
--              SELECT price FROM listing WHERE listing_id = 14;   -- now 999
--
-- Repeat with  SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
-- in Terminal A: the second SELECT already shows 999.
