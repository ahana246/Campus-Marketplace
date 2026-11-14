-- =====================================================================
--  CAMPUS MARKETPLACE  -  06_roles_rbac.sql
--  Role-based access control in the database.
--  The web app logs in as mp_student_app for students and as
--  mp_admin_app for admins, so each role only gets the rights it needs.
--  (local development passwords - same as web/.env.local)
-- =====================================================================

CREATE ROLE 'mp_student_role', 'mp_admin_role';

-- Students: read and add marketplace data, run the two procedures.
-- They cannot read the audit log or delete anything.
GRANT SELECT, INSERT, UPDATE ON campus_marketplace.users            TO 'mp_student_role';
GRANT SELECT                 ON campus_marketplace.category         TO 'mp_student_role';
GRANT SELECT, INSERT, UPDATE ON campus_marketplace.listing          TO 'mp_student_role';
GRANT SELECT, INSERT, UPDATE ON campus_marketplace.purchase_request TO 'mp_student_role';
GRANT SELECT                 ON campus_marketplace.transactions     TO 'mp_student_role';
GRANT SELECT, INSERT         ON campus_marketplace.review           TO 'mp_student_role';
GRANT SELECT                 ON campus_marketplace.v_listing_details TO 'mp_student_role';
GRANT EXECUTE                ON campus_marketplace.*                TO 'mp_student_role';

-- Admins: full read/write on every table, including the audit log
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON campus_marketplace.* TO 'mp_admin_role';

CREATE USER 'mp_student_app'@'%' IDENTIFIED BY 'student_app_pw';
CREATE USER 'mp_admin_app'@'%'   IDENTIFIED BY 'admin_app_pw';

GRANT 'mp_student_role' TO 'mp_student_app'@'%';
GRANT 'mp_admin_role'   TO 'mp_admin_app'@'%';
SET DEFAULT ROLE ALL TO 'mp_student_app'@'%', 'mp_admin_app'@'%';

-- Check with:  SHOW GRANTS FOR 'mp_student_app'@'%' USING 'mp_student_role';
