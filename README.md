# Campus Marketplace

**UE23CS351A DBMS Project, Team 21**
Ahana H Sharan (PES1UG24AM020) · Anarghyaa Kashyap (PES1UG24AM039)

Students buy and sell college items on campus.

* **MySQL**: main relational database
* **Redis**: key-value store (view counts) and vector database (semantic search)
* **Next.js**: web application

## Folder structure

```
├── docker-compose.yml     MySQL (port 3307) and Redis (port 6379)
├── database/
│   ├── init/              runs automatically on first MySQL start (schema, procedures, triggers, views, seed data, roles)
│   └── demo/              example queries to run by hand (queries, transactions, optimisation)
├── nosql/                 Redis key-value and vector commands
├── docs/                  ER diagram, schema diagram, normalization
└── web/                   Next.js app (app/, components/, lib/, scripts/)
```

## How to run

Requires **Docker Desktop** (running) and **Node.js**.

1. From the project folder, start the databases:

   ```bash
   docker compose up -d
   ```

2. First time only: wait about 30 seconds for MySQL to load the scripts, then in `web`:

   ```bash
   cp .env.example .env.local
   npm install
   npm run embed
   ```

3. Start the website from `web`:

   ```bash
   npm run dev
   ```

   Open http://localhost:3000.

**Demo logins** (password `password123`): `admin@pes.edu` (admin); `ahana@pes.edu`, `rohan@pes.edu`, `divya@pes.edu` (students).

**Reset to sample data:** `docker compose down -v`, then repeat steps 1 and 2 (skip `cp` and `npm install`).

**Run a SQL demo:**

```bash
docker exec -i cm_mysql mysql -uroot -prootpw campus_marketplace < database/demo/07_queries.sql
```

**Open the Redis shell:**

```bash
docker exec -it cm_redis redis-cli
```
