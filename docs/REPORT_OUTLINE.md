# Report Outline - copy into Word/Google Docs

## 1. Introduction
- Domain: Movie catalog system for a cinema/streaming company. Stores movies, directors, actors, genres, customers, reviews.
- Assumptions:
  - One director per movie (simplified), many actors per movie via movie_actors
  - One review per customer per movie (UNIQUE constraint)
  - Roles: admin=full incl user mgmt, employee=manage catalog, customer=browse+review, technical_staff=maintenance/reports
  - Passwords stored as hashes (demo hashes in DML, bcrypt in production)
- Members: [Name - Student No], [Name - Student No], ...

## 2. Database
### 2.1 ER Diagram
Paste PNG exported from docs/ERD.md mermaid (dbdiagram.io / Mermaid Live). Mention 8 tables > 6 minimum, FK network.

### 2.2 DDL
Paste full sql/ddl.sql. Highlight: PK (SERIAL + composite), FK with CASCADE/SET NULL/RESTRICT, UNIQUE, NOT NULL, CHECK (email, year 1888-2030, duration>0, rating 1-5), DEFAULT (TRUE, NOW(), CURRENT_DATE, 'English', 0). Indexes.

### 2.3 DML
Paste sql/dml.sql excerpts + state INSERT/UPDATE/DELETE all demonstrated (update duration, delete review examples at bottom).

### 2.4 SQL Queries (5-7) + Outputs
For each Q1-Q7 in sql/queries.sql: purpose (management question), SQL code, screenshot of Supabase output table.
E.g. Q2 answers "which genres need more movies?", Q7 gives totals for dashboard.

### 2.5 PL/SQL blocks (5)
B1 get_avg_rating function, B2 count_movies_by_genre, B3 add_review procedure with validation, B4 trg_refresh_avg auto-update, B5 trg_no_last_admin protection. For each: code + `SELECT/CALL` test + output screenshot.

## 3. Software
### 3.1 DB Connection
Paste app/supabaseClient.js (3 lines). Explain anon key + RLS open-all policy for demo.

### 3.2 Screens (5 required, we have 5)
For each screen paste 1 dev screenshot + 1 running screenshot + 2-3 lines what it does + which tables:
1. Login - users+user_groups auth, role display
2. Movies - movies CRUD + movie_actors link
3. People&Genres - directors/actors/genres CRUD
4. Users&Roles - admin-only users CRUD
5. Reviews&Reports - reviews CRUD + 3 report buttons mapping to Q2/Q1/Q7

Include code snippet ref: app/app.js function names (login, addMovie, updateMovie, deleteMovie, addReview, reportX).

## 4. GitHub
- Public link: https://github.com/<user>/Movie_DB_App
- Collaborators invited, folders listed, live demo URL (Vercel/Render).
- Note commit history as collaboration proof.

## Presentation (18-22 May) - 8 min plan
1. Demo login as admin vs customer (1 min)
2. Insert movie + review, show avg_rating trigger auto-update (2 min)
3. Show 2 queries + 1 function output (2 min)
4. Show Supabase tables + GitHub + live URL (1 min) + questions
