-- ============================================================
-- Movie_DB_App - 5 PL/pgSQL blocks (Supabase = Postgres plpgsql)
-- Equivalent of Oracle PL/SQL procedures/functions/triggers.
-- Run in Supabase SQL Editor one block at a time.
-- ============================================================

-- BLOCK 1: FUNCTION get_avg_rating(movie_id) -> NUMERIC
CREATE OR REPLACE FUNCTION get_avg_rating(p_movie_id INT)
RETURNS NUMERIC AS $$
DECLARE v_avg NUMERIC;
BEGIN
  SELECT COALESCE(AVG(rating),0) INTO v_avg
  FROM reviews WHERE movie_id = p_movie_id;
  RETURN ROUND(v_avg,2);
END;
$$ LANGUAGE plpgsql;
-- Test: SELECT get_avg_rating(1);

-- BLOCK 2: FUNCTION count_movies_by_genre(genre_name) -> INT
CREATE OR REPLACE FUNCTION count_movies_by_genre(p_genre VARCHAR)
RETURNS INT AS $$
DECLARE v_cnt INT;
BEGIN
  SELECT COUNT(*) INTO v_cnt
  FROM movies m JOIN genres g ON g.genre_id = m.genre_id
  WHERE g.genre_name = p_genre;
  RETURN v_cnt;
END;
$$ LANGUAGE plpgsql;
-- Test: SELECT count_movies_by_genre('Action');

-- BLOCK 3: PROCEDURE add_review with validation
CREATE OR REPLACE PROCEDURE add_review(p_movie INT, p_user INT, p_rating INT, p_comment TEXT)
AS $$
BEGIN
  IF p_rating NOT BETWEEN 1 AND 5 THEN
    RAISE EXCEPTION 'Rating must be 1-5, got %', p_rating;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM movies WHERE movie_id = p_movie) THEN
    RAISE EXCEPTION 'Movie % not found', p_movie;
  END IF;
  INSERT INTO reviews(movie_id, user_id, rating, comment)
  VALUES (p_movie, p_user, p_rating, p_comment)
  ON CONFLICT (movie_id, user_id)
  DO UPDATE SET rating = EXCLUDED.rating, comment = EXCLUDED.comment;
END;
$$ LANGUAGE plpgsql;
-- Test: CALL add_review(1, 4, 5, 'Amazing!');

-- BLOCK 4: TRIGGER auto-update movies.avg_rating after review change
CREATE OR REPLACE FUNCTION fn_refresh_avg_rating()
RETURNS TRIGGER AS $$
DECLARE v_mid INT;
BEGIN
  IF TG_OP = 'DELETE' THEN
    v_mid := OLD.movie_id;
  ELSE
    v_mid := NEW.movie_id;
  END IF;
  UPDATE movies
  SET avg_rating = (SELECT COALESCE(ROUND(AVG(rating),2),0)
                    FROM reviews WHERE movie_id = v_mid)
  WHERE movie_id = v_mid;
  IF TG_OP = 'DELETE' THEN
    RETURN OLD;
  ELSE
    RETURN NEW;
  END IF;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_refresh_avg ON reviews;
CREATE TRIGGER trg_refresh_avg
AFTER INSERT OR UPDATE OR DELETE ON reviews
FOR EACH ROW EXECUTE FUNCTION fn_refresh_avg_rating();

-- BLOCK 5: TRIGGER prevent deleting last admin
CREATE OR REPLACE FUNCTION fn_prevent_last_admin_delete()
RETURNS TRIGGER AS $$
DECLARE admin_count INT;
BEGIN
  SELECT COUNT(*) INTO admin_count
  FROM users u JOIN user_groups g ON g.group_id = u.group_id
  WHERE g.group_name = 'admin' AND u.user_id <> OLD.user_id;
  IF EXISTS (SELECT 1 FROM user_groups WHERE group_id = OLD.group_id AND group_name = 'admin')
     AND admin_count = 0 THEN
    RAISE EXCEPTION 'Cannot delete the last admin user (%)', OLD.username;
  END IF;
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_no_last_admin ON users;
CREATE TRIGGER trg_no_last_admin
BEFORE DELETE ON users
FOR EACH ROW EXECUTE FUNCTION fn_prevent_last_admin_delete();

-- Optional backfill after creating trigger:
-- UPDATE movies m SET avg_rating = get_avg_rating(m.movie_id);
