# Movie_DB_App - CMPE344 Term Project

Movie database with login + roles, deployed on Supabase + static web hosting.
Stack: **Supabase (Postgres) + HTML/JS** - no backend needed.

## 1. Quick Start (5 min)

### A. Create Supabase DB (choose Supabase - recommended over Railway for HTML/JS)
1. Go to https://supabase.com > New Project > name `movie-db-app`, set DB password, region closest to Cyprus (EU Central)
2. Invite group members: Project Settings > Team > Invite collaborator
3. Go to SQL Editor > New Query, run in order:
   - `sql/ddl.sql`
   - `sql/plpgsql.sql`
   - `sql/dml.sql`
4. Verify: Table Editor should show 8 tables: `user_groups, users, genres, directors, actors, movies, movie_actors, reviews`
5. Test queries: run `sql/queries.sql` one by one, screenshot outputs for report

### B. Why Supabase over Railway?
- Supabase gives instant REST API + JS client, perfect for pure HTML/JS. Railway needs you to code+host a backend (Node/Python). For this class, Supabase = less code, faster deploy.
- If instructor insists on Railway: create Postgres on Railway, run same `ddl.sql/dml.sql`, then host a tiny Node/Express wrapper - but stick with Supabase unless told otherwise.

### C. Run GUI locally
1. Open `app/supabaseClient.js`, paste your `SUPABASE_URL` + `SUPABASE_ANON_KEY` (Project Settings > API)
2. Open `app/index.html` in browser (double-click) OR `npx serve app`
3. Login as `admin1` -> test 5 screens:
   - 1.Login, 2.Movies (insert/update/delete), 3.People&Genres, 4.Users&Roles (admin only), 5.Reviews&Reports

### D. Deploy online (required by spec)
Option 1 - Vercel (easiest for static):
```
npm i -g vercel
cd app
vercel --prod
```
Option 2 - Render: New > Static Site > point to `app/` folder, publish directory `app`
Option 3 - Railway: New > GitHub Repo > Static + `npx serve app`
Put live URL in report + GitHub README.

## 2. Repo structure (matches GITHUB phase requirement)
```
Movie_DB_App/
  sql/ddl.sql       - DDL with PK/FK/CHECK/DEFAULT
  sql/dml.sql       - sample inserts + update/delete examples
  sql/queries.sql   - 7 management queries
  sql/plpgsql.sql   - 5 blocks (2 functions, 1 procedure, 2 triggers)
  app/index.html    - 5 screens GUI
  app/app.js        - CRUD via supabase-js
  app/supabaseClient.js - DB connection code (for report Section 3)
  app/styles.css
  docs/ERD.md       - ER diagram + mermaid source
  docs/REPORT_OUTLINE.md - copy-paste for final report
```

## 3. DB connection code (for report)
See `app/supabaseClient.js`:
```js
const sb = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
```

## 4. GitHub (required)
1. `git init` here already exists - add files: `git add .; git commit -m "Movie_DB_App CMPE344"; git branch -M main; git remote add origin <your-repo-url>; git push -u origin main`
2. Settings > General > make Public before 17 May 2026
3. Collaborators: Settings > Collaborators > invite team
4. Add live demo URL + screenshots to this README

## 5. Report checklist (due 17 May 2026, present 18-22 May)
- [ ] 1.Intro: domain (movie catalog + reviews), assumptions, member names/IDs
- [ ] 2.DB: ERD png from docs/ERD.md, full ddl.sql, dml sample, queries.sql + 7 outputs, plpgsql.sql + test outputs
- [ ] 3.Software: supabaseClient.js code, 5 screenshots (one per screen) + brief captions
- [ ] 4.GitHub: public link
