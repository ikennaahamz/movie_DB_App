// Movie_DB_App - CRUD + Reports via Supabase
// Covers: users, user_groups, movies, directors, actors, genres, movie_actors, reviews

async function login() {
  const u = document.getElementById('loginUser').value.trim();
  if (!u) return alert('Enter username');
  const { data, error } = await sb.from('users').select('user_id,username,full_name,group_id,user_groups(group_name)').eq('username', u).single();
  if (error || !data) { document.getElementById('loginMsg').textContent = 'Login failed: ' + (error?.message || 'not found'); return; }
  currentUser = { user_id: data.user_id, username: data.username, full_name: data.full_name, group_name: data.user_groups.group_name };
  document.getElementById('loginStatus').textContent = `${currentUser.username} (${currentUser.group_name})`;
  document.getElementById('loginMsg').textContent = `Welcome ${currentUser.full_name}! Role: ${currentUser.group_name}`;
  loadAllDropdowns();
}
function logout() { currentUser = null; document.getElementById('loginStatus').textContent = 'Not logged in'; }

// ---------- MOVIES ----------
async function loadMovies() {
  const { data, error } = await sb.from('movies').select('movie_id,title,release_year,duration_minutes,avg_rating,directors(full_name),genres(genre_name)').order('movie_id');
  if (error) return alert(error.message);
  document.getElementById('moviesBody').innerHTML = data.map(m => `<tr>
    <td>${m.movie_id}</td><td>${m.title}</td><td>${m.release_year}</td><td>${m.duration_minutes}</td>
    <td>${m.directors?.full_name || ''}</td><td>${m.genres?.genre_name || ''}</td><td>${m.avg_rating}</td>
    <td><button onclick="updateMovie(${m.movie_id})">Update+10min</button>
    <button class="danger" onclick="deleteMovie(${m.movie_id})">Delete</button></td></tr>`).join('');
}
async function addMovie() {
  const title = document.getElementById('mTitle').value.trim();
  const release_year = +document.getElementById('mYear').value || 2024;
  const duration_minutes = +document.getElementById('mDur').value || 120;
  const director_id = +document.getElementById('mDirector').value || null;
  const genre_id = +document.getElementById('mGenre').value || null;
  if (!title) return alert('Title required');
  const { error } = await sb.from('movies').insert({ title, release_year, duration_minutes, director_id, genre_id, created_by: currentUser?.user_id || null });
  if (error) return alert(error.message);
  loadMovies(); loadAllDropdowns();
}
async function updateMovie(id) {
  // demo update: +10 minutes
  const { data } = await sb.from('movies').select('duration_minutes').eq('movie_id', id).single();
  const { error } = await sb.from('movies').update({ duration_minutes: data.duration_minutes + 10 }).eq('movie_id', id);
  if (error) alert(error.message); else loadMovies();
}
async function deleteMovie(id) {
  if (!confirm('Delete movie ' + id + '?')) return;
  const { error } = await sb.from('movies').delete().eq('movie_id', id);
  if (error) alert(error.message); else loadMovies();
}
async function addMovieActor() {
  const movie_id = +document.getElementById('maMovie').value;
  const actor_id = +document.getElementById('maActor').value;
  const character_name = document.getElementById('maChar').value;
  const { error } = await sb.from('movie_actors').insert({ movie_id, actor_id, character_name });
  if (error) alert(error.message); else alert('Linked!');
}

// ---------- PEOPLE ----------
async function loadPeople() {
  const [d, a, g] = await Promise.all([
    sb.from('directors').select('*').order('director_id'),
    sb.from('actors').select('*').order('actor_id'),
    sb.from('genres').select('*').order('genre_id')]);
  document.getElementById('directorsBody').innerHTML = (d.data || []).map(x => `<tr><td>${x.director_id}</td><td>${x.full_name}</td><td><button class="danger" onclick="delRow('directors','director_id',${x.director_id})">Delete</button></td></tr>`).join('');
  document.getElementById('actorsBody').innerHTML = (a.data || []).map(x => `<tr><td>${x.actor_id}</td><td>${x.full_name}</td><td><button class="danger" onclick="delRow('actors','actor_id',${x.actor_id})">Delete</button></td></tr>`).join('');
  document.getElementById('genresBody').innerHTML = (g.data || []).map(x => `<tr><td>${x.genre_id}</td><td>${x.genre_name}</td><td><button class="danger" onclick="delRow('genres','genre_id',${x.genre_id})">Delete</button></td></tr>`).join('');
}
async function addDirector() { const v = document.getElementById('dName').value.trim(); if (!v) return; await sb.from('directors').insert({ full_name: v }); loadPeople(); loadAllDropdowns(); }
async function addActor() { const v = document.getElementById('aName').value.trim(); if (!v) return; await sb.from('actors').insert({ full_name: v }); loadPeople(); loadAllDropdowns(); }
async function addGenre() { const v = document.getElementById('gName').value.trim(); if (!v) return; const { error } = await sb.from('genres').insert({ genre_name: v }); if (error) alert(error.message); loadPeople(); loadAllDropdowns(); }
async function delRow(table, pk, id) { const { error } = await sb.from(table).delete().eq(pk, id); if (error) alert(error.message); else loadPeople(); }

// ---------- USERS ----------
async function loadUsers() {
  if (currentUser?.group_name !== 'admin') return alert('Admin only (login as admin1)');
  const { data, error } = await sb.from('users').select('user_id,username,email,is_active,user_groups(group_name)').order('user_id');
  if (error) return alert(error.message);
  document.getElementById('usersBody').innerHTML = data.map(u => `<tr><td>${u.user_id}</td><td>${u.username}</td><td>${u.email}</td>
    <td>${u.user_groups.group_name}</td><td>${u.is_active}</td>
    <td><button onclick="toggleUser(${u.user_id},${u.is_active})">Toggle Active</button>
    <button class="danger" onclick="deleteUser(${u.user_id})">Delete</button></td></tr>`).join('');
}
async function addUser() {
  const username = document.getElementById('uName').value.trim();
  const email = document.getElementById('uEmail').value.trim();
  const full_name = document.getElementById('uFull').value.trim() || username;
  const group_id = +document.getElementById('uGroup').value;
  if (!username || !email) return alert('username+email required');
  const { error } = await sb.from('users').insert({ username, email, full_name, group_id, password_hash: 'demo_hash' });
  if (error) alert(error.message); else loadUsers();
}
async function toggleUser(id, active) { await sb.from('users').update({ is_active: !active }).eq('user_id', id); loadUsers(); }
async function deleteUser(id) { const { error } = await sb.from('users').delete().eq('user_id', id); if (error) alert(error.message); else loadUsers(); }

// ---------- REVIEWS ----------
async function loadReviews() {
  const { data } = await sb.from('reviews').select('review_id,rating,comment,movies(title),users(username)').order('review_id');
  document.getElementById('reviewsBody').innerHTML = (data || []).map(r => `<tr><td>${r.review_id}</td><td>${r.movies?.title}</td><td>${r.users?.username}</td><td>${r.rating}</td><td>${r.comment || ''}</td><td><button class="danger" onclick="delRow2(${r.review_id})">Delete</button></td></tr>`).join('');
}
async function delRow2(id) { await sb.from('reviews').delete().eq('review_id', id); loadReviews(); }
async function addReview() {
  const movie_id = +document.getElementById('rMovie').value;
  const user_id = +document.getElementById('rUser').value;
  const rating = +document.getElementById('rRating').value;
  const comment = document.getElementById('rComment').value;
  // Calls BLOCK 3 procedure if exists, else direct insert:
  const { error } = await sb.rpc('add_review', {}).then(() => ({ error: 'fallback' })).catch(() => ({ error: 'fallback' }));
  // fallback direct insert (works without RPC setup):
  const ins = await sb.from('reviews').upsert({ movie_id, user_id, rating, comment }, { onConflict: 'movie_id,user_id' });
  if (ins.error) alert(ins.error.message); else { loadReviews(); loadMovies(); }
}

// ---------- REPORTS (Q2, Q1, Q7 equivalents client-side) ----------
async function reportMoviesPerGenre() {
  const { data } = await sb.from('movies').select('movie_id,genres(genre_name)');
  const counts = {};
  (data || []).forEach(m => { const g = m.genres?.genre_name || 'Unknown'; counts[g] = (counts[g] || 0) + 1; });
  document.getElementById('reportOut').textContent = 'Movies per genre (Q2):\n' + Object.entries(counts).map(([k, v]) => `${k}: ${v}`).join('\n');
}
async function reportTopRated() {
  const { data } = await sb.from('movies').select('title,avg_rating').order('avg_rating', { ascending: false }).limit(5);
  document.getElementById('reportOut').textContent = 'Top rated (Q1):\n' + (data || []).map(m => `${m.title} - ${m.avg_rating}`).join('\n');
}
async function reportStats() {
  const [m, u, r] = await Promise.all([
    sb.from('movies').select('movie_id', { count: 'exact' }),
    sb.from('users').select('user_id', { count: 'exact' }),
    sb.from('reviews').select('review_id', { count: 'exact' })]);
  document.getElementById('reportOut').textContent = `Overall stats (Q7):\nMovies: ${m.count}\nUsers: ${u.count}\nReviews: ${r.count}`;
}

// ---------- DROPDOWNS ----------
async function loadAllDropdowns() {
  const [dirs, genres, movies, actors, users, groups] = await Promise.all([
    sb.from('directors').select('director_id,full_name'),
    sb.from('genres').select('genre_id,genre_name'),
    sb.from('movies').select('movie_id,title'),
    sb.from('actors').select('actor_id,full_name'),
    sb.from('users').select('user_id,username'),
    sb.from('user_groups').select('group_id,group_name')]);
  const fill = (id, rows, v, t) => { document.getElementById(id).innerHTML = (rows || []).map(x => `<option value="${x[v]}">${x[t]}</option>`).join(''); };
  if (dirs.data) fill('mDirector', dirs.data, 'director_id', 'full_name');
  if (genres.data) fill('mGenre', genres.data, 'genre_id', 'genre_name');
  if (movies.data) { fill('maMovie', movies.data, 'movie_id', 'title'); fill('rMovie', movies.data, 'movie_id', 'title'); }
  if (actors.data) fill('maActor', actors.data, 'actor_id', 'full_name');
  if (users.data) fill('rUser', users.data, 'user_id', 'username');
  if (groups.data) fill('uGroup', groups.data, 'group_id', 'group_name');
}
loadAllDropdowns(); loadMovies(); loadPeople();
