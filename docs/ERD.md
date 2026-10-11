# ER Diagram - Movie_DB_App

## Tables (8, exceeds 6-table minimum)

```
user_groups ||--o{ users : "1 group has many users"
users ||--o{ movies : "1 employee creates many movies"
users ||--o{ reviews : "1 customer writes many reviews"
directors ||--o{ movies : "1 director directs many movies"
genres ||--o{ movies : "1 genre has many movies"
movies ||--o{ movie_actors : "1 movie has many cast rows"
actors ||--o{ movie_actors : "1 actor plays in many movies"
movies ||--o{ reviews : "1 movie has many reviews"
```

## Mermaid (paste into https://dbdiagram.io or Mermaid Live, screenshot for report)

```mermaid
erDiagram
  user_groups ||--o{ users : has
  users ||--o{ movies : creates
  users ||--o{ reviews : writes
  directors ||--o{ movies : directs
  genres ||--o{ movies : categorizes
  movies ||--o{ movie_actors : cast
  actors ||--o{ movie_actors : plays
  movies ||--o{ reviews : receives

  user_groups {
    int group_id PK
    string group_name UK "admin|employee|customer|technical_staff"
    string description
  }
  users {
    int user_id PK
    string username UK
    string password_hash
    string email UK
    string full_name
    int group_id FK
    bool is_active "DEFAULT TRUE"
    timestamptz created_at "DEFAULT NOW()"
  }
  genres {
    int genre_id PK
    string genre_name UK
  }
  directors {
    int director_id PK
    string full_name
    date birth_date
    string nationality
  }
  actors {
    int actor_id PK
    string full_name
    date birth_date
    string nationality
  }
  movies {
    int movie_id PK
    string title
    int release_year "CHECK 1888-2030"
    int duration_minutes "CHECK >0"
    string language "DEFAULT English"
    int director_id FK
    int genre_id FK
    decimal avg_rating "DEFAULT 0"
    int created_by FK
    timestamptz created_at
  }
  movie_actors {
    int movie_id FK
    int actor_id FK
    string character_name
  }
  reviews {
    int review_id PK
    int movie_id FK
    int user_id FK
    int rating "CHECK 1-5"
    string comment
    date review_date "DEFAULT CURRENT_DATE"
  }
```

## Relational notes for report

- PK: all `*_id` with SERIAL auto-increment, except `movie_actors` composite PK `(movie_id, actor_id)`
- FK: `users.group_id -> user_groups`, `movies.director_id/genre_id/created_by`, junction + reviews with `ON DELETE CASCADE` (except users.group and movies.director use SET NULL / RESTRICT)
- Constraints: UNIQUE on username/email/group_name/genre_name + (movie_id,user_id) in reviews; NOT NULL on titles/names; CHECK on email pattern, year, duration, rating; DEFAULT on booleans, dates, language, avg_rating
- Indexes on FK + title for JOIN/search speed

Screenshot instruction: import mermaid above into draw.io / dbdiagram.io, export PNG, save as `docs/erd.png` and paste into report Section 2.
