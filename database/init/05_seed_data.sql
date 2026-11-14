-- =====================================================================
--  CAMPUS MARKETPLACE  -  05_seed_data.sql
--  DML: sample data. The triggers run on these rows too.
--  Demo password for every seeded account: password123
-- =====================================================================
USE campus_marketplace;

-- bcrypt hash of 'password123'
SET @pwd = '$2a$10$xWCom9zmMNXGm.oqwVZqEe5tgPySiMV5kJ/DB3MlnRKuBbsadSgR.';

-- ---------------------------------------------------------------- USERS
INSERT INTO users (user_id, srn, name, email, phone, department, semester, password_hash, role, created_at) VALUES
 (1,  'ADM0001',       'Campus Admin',       'admin@pes.edu',     '9800000001', 'Administration', NULL, @pwd, 'ADMIN',   '2026-05-01 09:00:00'),
 (2,  'PES1UG24AM020', 'Ahana H Sharan',     'ahana@pes.edu',     '9800000002', 'AIML', 5, @pwd, 'STUDENT', '2026-05-20 10:00:00'),
 (3,  'PES1UG24AM039', 'Anarghyaa Kashyap',  'anarghyaa@pes.edu', '9800000003', 'AIML', 5, @pwd, 'STUDENT', '2026-05-20 10:05:00'),
 (4,  'PES1UG23CS101', 'Rohan Mehta',        'rohan@pes.edu',     '9800000004', 'CSE',  7, @pwd, 'STUDENT', '2026-05-22 11:00:00'),
 (5,  'PES1UG24EC045', 'Priya Nair',         'priya@pes.edu',     '9800000005', 'ECE',  5, @pwd, 'STUDENT', '2026-05-25 12:00:00'),
 (6,  'PES1UG25ME012', 'Karthik Rao',        'karthik@pes.edu',   '9800000006', 'ME',   3, @pwd, 'STUDENT', '2026-05-28 09:30:00'),
 (7,  'PES1UG24CS210', 'Sneha Iyer',         'sneha@pes.edu',     '9800000007', 'CSE',  5, @pwd, 'STUDENT', '2026-06-01 14:00:00'),
 (8,  'PES1UG23BT007', 'Arjun Das',          'arjun@pes.edu',     '9800000008', 'BT',   7, @pwd, 'STUDENT', '2026-06-02 15:00:00'),
 (9,  'PES1UG25AM088', 'Meera Joshi',        'meera@pes.edu',     '9800000009', 'AIML', 3, @pwd, 'STUDENT', '2026-06-03 16:00:00'),
 (10, 'PES1UG24EE033', 'Vikram Singh',       'vikram@pes.edu',    '9800000010', 'EEE',  5, @pwd, 'STUDENT', '2026-06-04 10:00:00'),
 (11, 'PES1UG25CS150', 'Divya Kulkarni',     'divya@pes.edu',     '9800000011', 'CSE',  1, @pwd, 'STUDENT', '2026-06-05 11:00:00'),
 (12, 'PES1UG23AM055', 'Farhan Ali',         'farhan@pes.edu',    NULL,         'AIML', 7, @pwd, 'STUDENT', '2026-06-06 12:00:00');

-- ------------------------------------------------------------- CATEGORY
INSERT INTO category (category_id, name, parent_category_id, description) VALUES
 (1, 'Books',                 NULL, 'All kinds of books'),
 (2, 'Textbooks',             1,    'Course textbooks'),
 (3, 'Reference & Notes',     1,    'Exam prep books and handwritten notes'),
 (4, 'Electronics',           NULL, 'Electronic items'),
 (5, 'Calculators',           4,    'Scientific calculators'),
 (6, 'Laptop Accessories',    4,    'Mice, bags, drives and more'),
 (7, 'Lab Supplies',          NULL, 'Lab coats, goggles, manuals'),
 (8, 'Stationery & Drawing',  NULL, 'Drawing kits, notebooks'),
 (9, 'Hostel Items',          NULL, 'Things for the hostel room');

-- -------------------------------------------------------------- LISTING
INSERT INTO listing (listing_id, seller_id, category_id, title, description, price, item_condition, created_at) VALUES
 (1,  2,  2, 'Database System Concepts (Korth)',     'DBMS course textbook: ER model, SQL, normalization, transactions. A few highlights.', 450, 'GOOD',     '2026-06-05 10:00:00'),
 (2,  4,  2, 'Engineering Mathematics - Grewal',     'First year maths textbook: calculus, linear algebra, differential equations.',       350, 'FAIR',     '2026-06-10 10:00:00'),
 (3,  5,  5, 'Casio fx-991EX Calculator',            'Exam-approved scientific calculator with cover. Works perfectly.',                   900, 'LIKE_NEW', '2026-06-12 10:00:00'),
 (4,  6,  7, 'White Lab Coat (Size M)',              'Cotton lab coat used for one semester of chemistry lab.',                            200, 'GOOD',     '2026-06-15 10:00:00'),
 (5,  7,  8, 'Engineering Drawing Kit',              'Mini drafter, compass set and set squares for engineering graphics.',                 400, 'GOOD',     '2026-06-20 10:00:00'),
 (6,  8,  2, 'Introduction to Algorithms (CLRS)',    'Algorithms textbook: sorting, graphs and dynamic programming.',                      650, 'GOOD',     '2026-06-22 10:00:00'),
 (7,  3,  3, 'GATE CSE Previous Year Papers',        'Solved GATE question papers with explanations.',                                     300, 'GOOD',     '2026-07-01 10:00:00'),
 (8,  9,  6, 'Laptop Backpack',                      'Padded backpack that fits a 15 inch laptop.',                                        600, 'LIKE_NEW', '2026-07-03 10:00:00'),
 (9,  10, 2, 'Signals and Systems - Oppenheim',      'ECE core textbook, some pencil notes.',                                              400, 'GOOD',     '2026-07-05 10:00:00'),
 (10, 11, 8, 'A2 Drawing Board with T-Square',       'Drafting board for engineering drawing classes.',                                    500, 'GOOD',     '2026-07-08 10:00:00'),
 (11, 2,  6, 'Wireless Mouse',                       'Compact wireless mouse with USB receiver.',                                          350, 'GOOD',     '2026-07-10 10:00:00'),
 (12, 4,  7, 'Safety Goggles',                       'Lab safety goggles for chemistry and workshop.',                                     100, 'NEW',      '2026-07-12 10:00:00'),
 (13, 5,  2, 'Operating System Concepts - Galvin',   'OS textbook: processes, scheduling, memory management.',                             450, 'GOOD',     '2026-07-15 10:00:00'),
 (14, 6,  9, 'Foldable Study Table',                 'Small wooden table that fits in a hostel room.',                                     700, 'FAIR',     '2026-07-18 10:00:00'),
 (15, 7,  3, 'Cracking the Coding Interview',        'Placement preparation book with coding questions.',                                  550, 'GOOD',     '2026-07-20 10:00:00'),
 (16, 8,  5, 'Casio fx-82MS Calculator',             'Basic scientific calculator.',                                                       300, 'FAIR',     '2026-07-22 10:00:00'),
 (17, 9,  8, 'Graph Notebooks (pack of 5)',          'Unused graph notebooks for lab records.',                                            150, 'NEW',      '2026-07-25 10:00:00'),
 (18, 10, 6, 'USB Pen Drive 64GB',                   'Pen drive for project files and presentations.',                                     300, 'LIKE_NEW', '2026-08-01 10:00:00'),
 (19, 3,  9, 'LED Desk Lamp',                        'Study lamp with 3 brightness levels.',                                               450, 'LIKE_NEW', '2026-08-03 10:00:00'),
 (20, 11, 2, 'Head First Java',                      'Learn Java and object oriented programming.',                                        350, 'LIKE_NEW', '2026-08-05 10:00:00'),
 (21, 12, 7, 'Chemistry Lab Manual',                 'First year chemistry lab manual, all experiments written.',                          150, 'GOOD',     '2026-08-08 10:00:00'),
 (22, 2,  3, 'Data Structures Handwritten Notes',    'Complete handwritten notes for the data structures course.',                         100, 'GOOD',     '2026-08-10 10:00:00'),
 (23, 4,  6, 'Laptop Cooling Pad',                   'USB cooling pad with adjustable height.',                                            500, 'LIKE_NEW', '2026-08-15 10:00:00'),
 (24, 5,  9, 'Single Bed Mattress',                  'Foam mattress for the hostel, used for one year.',                                   800, 'FAIR',     '2026-08-18 10:00:00');

-- ----------------------------------------------------- PURCHASE_REQUEST
-- Inserted while all listings are still AVAILABLE (trigger checks each row)
INSERT INTO purchase_request (request_id, listing_id, buyer_id, offered_price, message, requested_at) VALUES
 (1,  1,  7,  400, 'Need it for the DBMS course',  '2026-06-07 09:00:00'),
 (2,  1,  9,  420, 'Can I pick it up today?',      '2026-06-08 09:00:00'),
 (3,  3,  6,  850, 'Is the cover included?',       '2026-06-14 09:00:00'),
 (4,  4,  9,  200, 'Need it for chemistry lab',    '2026-06-17 09:00:00'),
 (5,  5,  11, 400, 'First year, need the kit',     '2026-06-22 09:00:00'),
 (6,  6,  3,  600, 'Would you take 600?',          '2026-06-24 09:00:00'),
 (7,  7,  4,  300, 'Preparing for GATE',           '2026-07-03 09:00:00'),
 (8,  9,  5,  400, 'For my ECE course',            '2026-07-07 09:00:00'),
 (9,  11, 10, 300, 'Interested',                   '2026-07-12 09:00:00'),
 (10, 13, 7,  420, 'OS exam next month',           '2026-07-17 09:00:00'),
 (11, 15, 2,  500, 'Placement season!',            '2026-07-22 09:00:00'),
 (12, 18, 8,  300, 'Need it for my project',       '2026-08-03 09:00:00'),
 (13, 20, 2,  350, 'Want to learn Java',           '2026-08-07 09:00:00'),
 (14, 19, 6,  400, 'For night study',              '2026-08-05 09:00:00'),
 (15, 22, 11, 100, 'Exams are coming',             '2026-08-12 09:00:00'),
 (16, 23, 5,  450, 'Can you do 450?',              '2026-10-10 09:00:00'),
 (17, 24, 3,  750, 'Is it still available?',       '2026-10-15 09:00:00'),
 (18, 24, 9,  780, 'Can pick it up tomorrow',      '2026-10-16 09:00:00'),
 (19, 14, 8,  650, 'Can you deliver to block B?',  '2026-10-18 09:00:00'),
 (20, 8,  10, 550, 'Interested in the bag',        '2026-10-19 09:00:00'),
 (21, 16, 2,  300, 'Interested',                   '2026-07-25 09:00:00'),
 (22, 3,  11, 800, 'Need a calculator',            '2026-06-15 09:00:00');

-- Seller decisions
UPDATE purchase_request SET status = 'ACCEPTED'
 WHERE request_id IN (1,3,4,5,6,7,8,9,10,11,12,13,14,15,16);
UPDATE purchase_request SET status = 'REJECTED'  WHERE request_id IN (2, 22);
UPDATE purchase_request SET status = 'CANCELLED' WHERE request_id = 21;

-- Listing status after the deals (the audit trigger logs these)
UPDATE listing SET status = 'CLOSED'
 WHERE listing_id IN (1,3,4,5,6,7,9,11,13,15,18,19,20,22);
UPDATE listing SET status = 'RESERVED' WHERE listing_id = 23;

-- --------------------------------------------------------- TRANSACTIONS
INSERT INTO transactions (transaction_id, request_id, amount, payment_mode, completed_at) VALUES
 (1,  1,  400, 'UPI',  '2026-06-09 17:00:00'),
 (2,  3,  850, 'CASH', '2026-06-16 17:00:00'),
 (3,  4,  200, 'CASH', '2026-06-18 17:00:00'),
 (4,  5,  400, 'UPI',  '2026-06-25 17:00:00'),
 (5,  6,  600, 'UPI',  '2026-06-28 17:00:00'),
 (6,  7,  300, 'CASH', '2026-07-05 17:00:00'),
 (7,  8,  400, 'UPI',  '2026-07-09 17:00:00'),
 (8,  9,  300, 'CASH', '2026-07-14 17:00:00'),
 (9,  10, 420, 'UPI',  '2026-07-20 17:00:00'),
 (10, 11, 500, 'UPI',  '2026-07-25 17:00:00'),
 (11, 12, 300, 'CASH', '2026-08-05 17:00:00'),
 (12, 13, 350, 'UPI',  '2026-08-09 17:00:00'),
 (13, 14, 400, 'CASH', '2026-08-20 17:00:00'),
 (14, 15, 100, 'UPI',  '2026-09-02 17:00:00');

-- --------------------------------------------------------------- REVIEW
INSERT INTO review (transaction_id, reviewer_id, reviewee_id, rating, comment, created_at) VALUES
 (1,  7,  2,  5, 'Book in great condition',  '2026-06-10 10:00:00'),
 (1,  2,  7,  5, 'Paid on time',             '2026-06-10 11:00:00'),
 (2,  6,  5,  4, 'Calculator works well',    '2026-06-17 10:00:00'),
 (3,  9,  6,  5, 'Clean lab coat',           '2026-06-19 10:00:00'),
 (4,  11, 7,  4, 'Kit was complete',         '2026-06-26 10:00:00'),
 (5,  3,  8,  4, 'Good book',                '2026-06-29 10:00:00'),
 (6,  4,  3,  5, 'Very helpful papers',      '2026-07-06 10:00:00'),
 (7,  5,  10, 4, 'As described',             '2026-07-10 10:00:00'),
 (8,  10, 2,  5, 'Mouse works fine',         '2026-07-15 10:00:00'),
 (9,  7,  5,  4, 'Good condition',           '2026-07-21 10:00:00'),
 (10, 2,  7,  5, 'Great for placements',     '2026-07-26 10:00:00'),
 (11, 8,  10, 3, 'Drive is a bit slow',      '2026-08-06 10:00:00'),
 (12, 2,  11, 5, 'Quick and friendly',       '2026-08-10 10:00:00'),
 (13, 6,  3,  4, 'Nice lamp',                '2026-08-21 10:00:00'),
 (14, 11, 2,  5, 'Very neat notes',          '2026-09-03 10:00:00');

-- An admin has deactivated one user
UPDATE users SET is_active = FALSE WHERE user_id = 12;
