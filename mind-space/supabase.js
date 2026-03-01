// ============================================================
//  MIND SPACE — Supabase 設定檔
//  請將下方的 YOUR_SUPABASE_URL 和 YOUR_SUPABASE_ANON_KEY
//  替換成你在 Supabase 後台取得的值
// ============================================================

const SUPABASE_URL = 'YOUR_SUPABASE_URL';        // 例如 https://xxxx.supabase.co
const SUPABASE_ANON_KEY = 'YOUR_SUPABASE_ANON_KEY'; // 很長的 JWT 字串

// Supabase JS SDK (透過 CDN 載入，不需安裝)
// 在每個 HTML 頁面的 <head> 中已經引入：
// <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/dist/umd/supabase.min.js"></script>

let _supabase = null;

function getSupabase() {
  if (!_supabase) {
    _supabase = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
  }
  return _supabase;
}

// ============================================================
//  文章 CRUD
// ============================================================

async function fetchPosts(category = null) {
  const db = getSupabase();
  let query = db
    .from('posts')
    .select('*')
    .order('created_at', { ascending: false });

  if (category) query = query.eq('category', category);

  const { data, error } = await query;
  if (error) { console.error('fetchPosts error:', error); return []; }
  return data;
}

async function createPost(post) {
  const db = getSupabase();
  const { data, error } = await db
    .from('posts')
    .insert([post])
    .select()
    .single();

  if (error) { console.error('createPost error:', error); return null; }
  return data;
}

async function deletePost(id) {
  const db = getSupabase();
  const { error } = await db.from('posts').delete().eq('id', id);
  if (error) { console.error('deletePost error:', error); return false; }
  return true;
}

// ============================================================
//  圖片上傳 (Supabase Storage)
// ============================================================

async function uploadImage(file) {
  const db = getSupabase();
  const ext = file.name.split('.').pop();
  const fileName = `${Date.now()}-${Math.random().toString(36).slice(2)}.${ext}`;
  const filePath = `posts/${fileName}`;

  const { error } = await db.storage
    .from('images')          // Supabase Storage bucket 名稱
    .upload(filePath, file, { cacheControl: '3600', upsert: false });

  if (error) { console.error('uploadImage error:', error); return null; }

  const { data } = db.storage.from('images').getPublicUrl(filePath);
  return data.publicUrl;
}

// ============================================================
//  工具函式
// ============================================================

function formatDate(dateStr) {
  const d = new Date(dateStr);
  return `${d.getFullYear()}.${String(d.getMonth()+1).padStart(2,'0')}.${String(d.getDate()).padStart(2,'0')}`;
}

function getYouTubeEmbed(url) {
  const match = url.match(/(?:youtu\.be\/|youtube\.com\/watch\?v=)([^&\s]+)/);
  return match ? `https://www.youtube.com/embed/${match[1]}` : url;
}
