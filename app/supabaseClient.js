// Copy your anon key from Supabase Dashboard > Project Settings > API > anon public
const SUPABASE_URL = "https://cryurmsriazcxhirnnqa.supabase.co";
const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNyeXVybXNyaWF6Y3hoaXJubnFhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTE2Mzg2OTEsImV4cCI6MjEwNzIxNDY5MX0.YVsDbgzcO1nbUxx6YMkgn-nnhNc_7BOvgPbFg1IEWyk";

const sb = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
let currentUser = null; // {user_id, username, group_name, full_name}
