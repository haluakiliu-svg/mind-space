-- ============================================================
--  MIND SPACE — Supabase 資料庫初始化 SQL
--  請在 Supabase 後台 → SQL Editor 貼上並執行
-- ============================================================

-- 1. 建立 posts 資料表
CREATE TABLE IF NOT EXISTS posts (
  id            BIGSERIAL PRIMARY KEY,
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  category      TEXT NOT NULL CHECK (category IN ('music','explore','tech','marketing')),
  title         TEXT NOT NULL,
  content       TEXT NOT NULL,
  tag           TEXT,
  image_url     TEXT,
  video_url     TEXT,
  -- 音樂專用欄位
  song_name     TEXT,
  artist        TEXT,
  mood          TEXT,
  cover_url     TEXT,
  spotify_url   TEXT
);

-- 2. Row Level Security
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

-- ✅ 所有人可以讀文章（前台顯示）
CREATE POLICY "Public can read posts"
  ON posts FOR SELECT
  USING (true);

-- 🔒 只有登入的用戶可以新增文章
CREATE POLICY "Authenticated can insert posts"
  ON posts FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

-- 🔒 只有登入的用戶可以更新文章
CREATE POLICY "Authenticated can update posts"
  ON posts FOR UPDATE
  USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');

-- 🔒 只有登入的用戶可以刪除文章
CREATE POLICY "Authenticated can delete posts"
  ON posts FOR DELETE
  USING (auth.role() = 'authenticated');


-- 3. Storage bucket（放圖片）
INSERT INTO storage.buckets (id, name, public)
VALUES ('images', 'images', true)
ON CONFLICT (id) DO NOTHING;

-- ✅ 所有人可以讀圖片
CREATE POLICY "Public can view images"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'images');

-- 🔒 只有登入者可以上傳圖片
CREATE POLICY "Authenticated can upload images"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'images' AND auth.role() = 'authenticated');

-- 🔒 只有登入者可以刪除圖片
CREATE POLICY "Authenticated can delete images"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'images' AND auth.role() = 'authenticated');


-- ============================================================
-- 若資料表已存在，執行以下語句更新（遷移用）
-- ============================================================

-- 補上 spotify_url 欄位
ALTER TABLE posts ADD COLUMN IF NOT EXISTS spotify_url TEXT;

-- 刪除舊的開放 policy，換成登入保護版本
-- （先刪除舊 policy 再重建）
DO $$
BEGIN
  -- 刪除可能存在的舊 policy
  DROP POLICY IF EXISTS "Anyone can insert posts" ON posts;
  DROP POLICY IF EXISTS "Anyone can update posts" ON posts;
  DROP POLICY IF EXISTS "Anyone can delete posts" ON posts;
  DROP POLICY IF EXISTS "Anyone can upload images" ON storage.objects;
  DROP POLICY IF EXISTS "Anyone can delete images" ON storage.objects;

  -- 建立新的 authenticated-only policy（如果不存在）
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename='posts' AND policyname='Authenticated can insert posts'
  ) THEN
    CREATE POLICY "Authenticated can insert posts" ON posts FOR INSERT WITH CHECK (auth.role()='authenticated');
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename='posts' AND policyname='Authenticated can update posts'
  ) THEN
    CREATE POLICY "Authenticated can update posts" ON posts FOR UPDATE USING (auth.role()='authenticated') WITH CHECK (auth.role()='authenticated');
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename='posts' AND policyname='Authenticated can delete posts'
  ) THEN
    CREATE POLICY "Authenticated can delete posts" ON posts FOR DELETE USING (auth.role()='authenticated');
  END IF;
END $$;
