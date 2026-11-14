-- =====================================================================
--  CAMPUS MARKETPLACE  -  01_schema.sql
--  DDL: database, tables, keys, constraints and indexes  (MySQL 8)
-- =====================================================================

DROP DATABASE IF EXISTS campus_marketplace;
CREATE DATABASE campus_marketplace;
USE campus_marketplace;

-- USERS: every student / admin of the marketplace
CREATE TABLE users (
  user_id        INT AUTO_INCREMENT PRIMARY KEY,
  srn            VARCHAR(15)  NOT NULL UNIQUE,
  name           VARCHAR(100) NOT NULL,
  email          VARCHAR(120) NOT NULL UNIQUE,
  phone          VARCHAR(15),
  department     VARCHAR(50),
  semester       TINYINT CHECK (semester BETWEEN 1 AND 8),
  password_hash  VARCHAR(100) NOT NULL,
  role           ENUM('STUDENT','ADMIN') NOT NULL DEFAULT 'STUDENT',
  is_active      BOOLEAN NOT NULL DEFAULT TRUE,
  created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- CATEGORY: parent_category_id is a self reference (Books > Textbooks)
CREATE TABLE category (
  category_id         INT AUTO_INCREMENT PRIMARY KEY,
  name                VARCHAR(60) NOT NULL UNIQUE,
  parent_category_id  INT NULL,
  description         VARCHAR(255),
  FOREIGN KEY (parent_category_id) REFERENCES category(category_id)
);

-- LISTING: an item a student puts up for sale
CREATE TABLE listing (
  listing_id      INT AUTO_INCREMENT PRIMARY KEY,
  seller_id       INT NOT NULL,
  category_id     INT NOT NULL,
  title           VARCHAR(150) NOT NULL,
  description     TEXT,
  price           DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (price >= 0),
  item_condition  ENUM('NEW','LIKE_NEW','GOOD','FAIR') NOT NULL DEFAULT 'GOOD',
  status          ENUM('AVAILABLE','RESERVED','CLOSED') NOT NULL DEFAULT 'AVAILABLE',
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (seller_id)   REFERENCES users(user_id),
  FOREIGN KEY (category_id) REFERENCES category(category_id)
);

-- index for the most common filter + full-text index for keyword search
CREATE INDEX idx_listing_status ON listing (status, category_id);
CREATE FULLTEXT INDEX ftx_listing ON listing (title, description);

-- PURCHASE_REQUEST: a buyer asks to buy a listing at an offered price
CREATE TABLE purchase_request (
  request_id     INT AUTO_INCREMENT PRIMARY KEY,
  listing_id     INT NOT NULL,
  buyer_id       INT NOT NULL,
  offered_price  DECIMAL(10,2) NOT NULL CHECK (offered_price >= 0),
  message        VARCHAR(255),
  status         ENUM('PENDING','ACCEPTED','REJECTED','CANCELLED') NOT NULL DEFAULT 'PENDING',
  requested_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (listing_id) REFERENCES listing(listing_id),
  FOREIGN KEY (buyer_id)   REFERENCES users(user_id)
);

-- TRANSACTIONS: one completed deal per accepted request (1 : 0..1)
CREATE TABLE transactions (
  transaction_id  INT AUTO_INCREMENT PRIMARY KEY,
  request_id      INT NOT NULL UNIQUE,
  amount          DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (amount >= 0),
  payment_mode    ENUM('CASH','UPI') NOT NULL DEFAULT 'CASH',
  status          ENUM('COMPLETED','FAILED','REFUNDED') NOT NULL DEFAULT 'COMPLETED',
  completed_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (request_id) REFERENCES purchase_request(request_id)
);

-- REVIEW: buyer and seller can rate each other once per transaction
CREATE TABLE review (
  review_id       INT AUTO_INCREMENT PRIMARY KEY,
  transaction_id  INT NOT NULL,
  reviewer_id     INT NOT NULL,
  reviewee_id     INT NOT NULL,
  rating          TINYINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment         VARCHAR(255),
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE (transaction_id, reviewer_id),
  FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id),
  FOREIGN KEY (reviewer_id)    REFERENCES users(user_id),
  FOREIGN KEY (reviewee_id)    REFERENCES users(user_id)
);

-- AUDIT_LOG: not an ER entity, filled automatically by a trigger
CREATE TABLE audit_log (
  log_id      INT AUTO_INCREMENT PRIMARY KEY,
  listing_id  INT NOT NULL,
  old_status  VARCHAR(20),
  new_status  VARCHAR(20),
  changed_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);
