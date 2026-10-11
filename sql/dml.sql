-- ============================================================
-- Movie_DB_App - Sample DML (run AFTER ddl.sql in Supabase)
-- ============================================================

-- User groups
INSERT INTO user_groups (group_name, description) VALUES
('admin','System administrators - full access, manage users'),
('employee','Staff - manage movies, actors, directors'),
('customer','Customers - browse movies, write reviews'),
('technical_staff','Technical staff - maintain DB, reports')
ON CONFLICT (group_name) DO NOTHING;

-- Users (passwords are demo SHA256 hashes, replace in real app with bcrypt)
-- password for all demo users = '1234' hashed placeholder
INSERT INTO users (username, password_hash, email, full_name, group_id) VALUES
('admin1','demo_hash_admin','admin@movie.local','Admin One',
  (SELECT group_id FROM user_groups WHERE group_name='admin')),
('emp1','demo_hash_emp','emp@movie.local','Employee One',
  (SELECT group_id FROM user_groups WHERE group_name='employee')),
('tech1','demo_hash_tech','tech@movie.local','Tech One',
  (SELECT group_id FROM user_groups WHERE group_name='technical_staff')),
('cust1','demo_hash_c1','leyla@mail.com','Leyla Demir',
  (SELECT group_id FROM user_groups WHERE group_name='customer')),
('cust2','demo_hash_c2','ahmet@mail.com','Ahmet Yilmaz',
  (SELECT group_id FROM user_groups WHERE group_name='customer')),
('cust3','demo_hash_c3','maria@mail.com','Maria Lopez',
  (SELECT group_id FROM user_groups WHERE group_name='customer'))
ON CONFLICT (username) DO NOTHING;

INSERT INTO genres (genre_name) VALUES
('Action'),('Drama'),('Comedy'),('Sci-Fi'),('Horror')
ON CONFLICT (genre_name) DO NOTHING;

INSERT INTO directors (full_name, birth_date, nationality) VALUES
('Christopher Nolan','1970-07-30','British'),
('Greta Gerwig','1983-08-04','American'),
('Nuri Bilge Ceylan','1959-01-26','Turkish');

INSERT INTO actors (full_name, birth_date, nationality) VALUES
('Christian Bale','1974-01-30','British'),
('Margot Robbie','1990-07-02','Australian'),
('Haluk Bilginer','1954-06-05','Turkish'),
('Zendaya','1996-09-01','American');

INSERT INTO movies (title, release_year, duration_minutes, language, director_id, genre_id, created_by) VALUES
('Inception',2010,148,'English',
  (SELECT director_id FROM directors WHERE full_name='Christopher Nolan'),
  (SELECT genre_id FROM genres WHERE genre_name='Sci-Fi'),
  (SELECT user_id FROM users WHERE username='emp1')),
('Barbie',2023,114,'English',
  (SELECT director_id FROM directors WHERE full_name='Greta Gerwig'),
  (SELECT genre_id FROM genres WHERE genre_name='Comedy'),
  (SELECT user_id FROM users WHERE username='emp1')),
('Winter Sleep',2014,196,'Turkish',
  (SELECT director_id FROM directors WHERE full_name='Nuri Bilge Ceylan'),
  (SELECT genre_id FROM genres WHERE genre_name='Drama'),
  (SELECT user_id FROM users WHERE username='emp1')),
('The Dark Knight',2008,152,'English',
  (SELECT director_id FROM directors WHERE full_name='Christopher Nolan'),
  (SELECT genre_id FROM genres WHERE genre_name='Action'),
  (SELECT user_id FROM users WHERE username='admin1'));

INSERT INTO movie_actors (movie_id, actor_id, character_name) VALUES
((SELECT movie_id FROM movies WHERE title='Inception'),
 (SELECT actor_id FROM actors WHERE full_name='Christian Bale'),'Cobb (demo)'),
((SELECT movie_id FROM movies WHERE title='Barbie'),
 (SELECT actor_id FROM actors WHERE full_name='Margot Robbie'),'Barbie'),
((SELECT movie_id FROM movies WHERE title='Barbie'),
 (SELECT actor_id FROM actors WHERE full_name='Zendaya'),'Guest'),
((SELECT movie_id FROM movies WHERE title='Winter Sleep'),
 (SELECT actor_id FROM actors WHERE full_name='Haluk Bilginer'),'Aydin'),
((SELECT movie_id FROM movies WHERE title='The Dark Knight'),
 (SELECT actor_id FROM actors WHERE full_name='Christian Bale'),'Batman')
ON CONFLICT DO NOTHING;

INSERT INTO reviews (movie_id, user_id, rating, comment) VALUES
((SELECT movie_id FROM movies WHERE title='Inception'),
 (SELECT user_id FROM users WHERE username='cust1'),5,'Mind-blowing!'),
((SELECT movie_id FROM movies WHERE title='Inception'),
 (SELECT user_id FROM users WHERE username='cust2'),4,'Great visuals'),
((SELECT movie_id FROM movies WHERE title='Barbie'),
 (SELECT user_id FROM users WHERE username='cust1'),4,'Fun and colorful'),
((SELECT movie_id FROM movies WHERE title='Barbie'),
 (SELECT user_id FROM users WHERE username='cust3'),5,'Loved it'),
((SELECT movie_id FROM movies WHERE title='Winter Sleep'),
 (SELECT user_id FROM users WHERE username='cust2'),5,'Masterpiece'),
((SELECT movie_id FROM movies WHERE title='The Dark Knight'),
 (SELECT user_id FROM users WHERE username='cust3'),5,'Best superhero film')
ON CONFLICT (movie_id, user_id) DO NOTHING;

-- Example UPDATE / DELETE (required by spec: show you can do all 3)
-- UPDATE: correct a duration
-- UPDATE movies SET duration_minutes = 150 WHERE title = 'Inception';
-- DELETE: remove one review
-- DELETE FROM reviews WHERE review_id = 1;
