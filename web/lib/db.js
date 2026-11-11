import mysql from 'mysql2/promise';

// Two connection pools = two MySQL accounts (see 06_roles_rbac.sql).
// Students use mp_student_app, admins use mp_admin_app.
const pools = {};

function getPool(role) {
  const isAdmin = role === 'ADMIN';
  const key = isAdmin ? 'admin' : 'student';
  if (!pools[key]) {
    pools[key] = mysql.createPool({
      host: process.env.DB_HOST,
      port: Number(process.env.DB_PORT),
      database: process.env.DB_NAME,
      user: isAdmin ? process.env.DB_ADMIN_USER : process.env.DB_STUDENT_USER,
      password: isAdmin ? process.env.DB_ADMIN_PASSWORD : process.env.DB_STUDENT_PASSWORD,
      dateStrings: true,
      decimalNumbers: true,
    });
  }
  return pools[key];
}

// Run a query with ? placeholders (values are escaped, so no SQL injection)
export async function query(sql, params = [], role = 'STUDENT') {
  const [rows] = await getPool(role).query(sql, params);
  return rows;
}
