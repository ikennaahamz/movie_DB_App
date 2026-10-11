-- ============================================================
-- Movie_DB_App - DDL for Supabase (Postgres 15)
-- CMPE344 Term Project Spring 2025-2026
-- Run this in Supabase Dashboard > SQL Editor
-- ============================================================

-- Clean slate (safe re-run)
DROP TABLE IF EXISTS reviews CASCADE;
DROP TABLE IF EXISTS movie_actors CASCADE;
DROP TABLE IF EXISTS movies CASCADE;
DROP TABLE IF EXISTS actors CASCADE;
DROP TABLE IF EXISTS directors CASCADE;
DROP TABLE IF EXISTS genres CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS user_groups CASCADE;

-- 1. USER GROUPS (roles: admin, employee, customer, technical_staff)
CREATE TABLE user_groups (
  group_id   SERIAL PRIMARY KEY,
  group_name VARCHAR(50) UNIQUE NOT NULL
    CHECK (group_name IN ('admin','employee','customer','technical_staff')),
  description TEXT
);

-- 2. USERS (authentication table)
CREATE TABLE users (
  user_id       SERIAL PRIMARY KEY,
  username      VARCHAR(50) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL, -- store SHA256/bcrypt hash from app, never plain text
  email         VARCHAR(100) UNIQUE NOT NULL
    CHECK (email LIKE '%@%.%'),
  full_name     VARCHAR(100) NOT NULL,
  group_id      INT NOT NULL REFERENCES user_groups(group_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  is_active     BOOLEAN NOT NULL DEFAULT TRUE,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. GENRES
CREATE TABLE genres (
  genre_id   SERIAL PRIMARY KEY,
  genre_name VARCHAR(50) UNIQUE NOT NULL
);

-- 4. DIRECTORS
CREATE TABLE directors (
  director_id SERIAL PRIMARY KEY,
  full_name   VARCHAR(100) NOT NULL,
  birth_date  DATE,
  nationality VARCHAR(50)
);

-- 5. ACTORS
CREATE TABLE actors (
  actor_id    SERIAL PRIMARY KEY,
  full_name   VARCHAR(100) NOT NULL,
  birth_date  DATE,
  nationality VARCHAR(50)
);

-- 6. MOVIES
CREATE TABLE movies (
  movie_id           SERIAL PRIMARY KEY,
  title              VARCHAR(200) NOT NULL,
  release_year       INT NOT NULL
    CHECK (release_year BETWEEN 1888 AND 2030),
  duration_minutes   INT NOT NULL CHECK (duration_minutes > 0),
  language           VARCHAR(30) NOT NULL DEFAULT 'English',
  director_id        INT REFERENCES directors(director_id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  genre_id           INT REFERENCES genres(genre_id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  avg_rating         NUMERIC(3,2) NOT NULL DEFAULT 0
    CHECK (avg_rating BETWEEN 0 AND 5),
  created_by         INT REFERENCES users(user_id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  created_at         TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 7. MOVIE_ACTORS (many-to-many: movie <-> actor)
CREATE TABLE movie_actors (
  movie_id       INT NOT NULL REFERENCES movies(movie_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  actor_id       INT NOT NULL REFERENCES actors(actor_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  character_name VARCHAR(100),
  PRIMARY KEY (movie_id, actor_id)
);

-- 8. REVIEWS (customers rate movies)
CREATE TABLE reviews (
  review_id   SERIAL PRIMARY KEY,
  movie_id    INT NOT NULL REFERENCES movies(movie_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  user_id     INT NOT NULL REFERENCES users(user_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  rating      INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment     TEXT,
  review_date DATE NOT NULL DEFAULT CURRENT_DATE,
  UNIQUE (movie_id, user_id) -- one review per user per movie
);

-- Indexes for JOIN / search performance
CREATE INDEX idx_movies_director ON movies(director_id);
CREATE INDEX idx_movies_genre ON movies(genre_id);
CREATE INDEX idx_reviews_movie ON reviews(movie_id);
CREATE INDEX idx_reviews_user ON reviews(user_id);
CREATE INDEX idx_movies_title ON movies(title);

-- ------------------------------------------------------------
-- Supabase Row Level Security (simple mode for class project)
-- Enable RLS but allow all via permissive policies so HTML/JS
-- anon key can do CRUD during demo. Tighten for production.
-- ------------------------------------------------------------
ALTER TABLE user_groups  ENABLE ROW LEVEL SECURITY;
ALTER TABLE users        ENABLE ROW LEVEL SECURITY;
ALTER TABLE genres       ENABLE ROW LEVEL SECURITY;
ALTER TABLE directors    ENABLE ROW LEVEL SECURITY;
ALTER TABLE actors       ENABLE ROW LEVEL SECURITY;
ALTER TABLE movies       ENABLE ROW LEVEL SECURITY;
ALTER TABLE movie_actors ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews      ENABLE ROW LEVEL SECURITY;

-- Drop old policies if re-running
DO $$ BEGIN
  DROP POLICY IF EXISTS "open all" ON user_groups;
  DROP POLICY IF EXISTS "open all" ON users;
  DROP POLICY IF EXISTS "open all" ON genres;
  DROP POLICY IF EXISTS "open all" ON directors;
  DROP POLICY IF EXISTS "open all" ON actors;
  DROP POLICY IF EXISTS "open all" ON movies;
  DROP POLICY IF EXISTS "open all" ON movie_actors;
  DROP POLICY IF EXISTS "open all" ON reviews;
END $$;

CREATE POLICY "open all" ON user_groups  FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "open all" ON users        FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "open all" ON genres      FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "open all" ON directors   FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "open all" ON actors      FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "open all" ON movies      FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "open all" ON movie_actors FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "open all" ON reviews     FOR ALL USING (true) WITH CHECK (true);
