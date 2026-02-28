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
  -- Spotify
  spotify_url   TEXT
);

-- 2. 開放公開讀取（前台可以匿名讀取文章）
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public can read posts"
  ON posts FOR SELECT
  USING (true);

CREATE POLICY "Anyone can insert posts"
  ON posts FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Anyone can delete posts"
  ON posts FOR DELETE
  USING (true);

-- ⚠️ 注意：上面的 INSERT/DELETE 政策是開放給所有人，適合個人網站。
-- 如果你之後想加登入保護後台，可以改成：
-- WITH CHECK (auth.role() = 'authenticated');

-- 3. 建立 Storage bucket（放圖片）
-- 請在 Supabase 後台 → Storage → New Bucket 手動建立：
-- Bucket 名稱：images
-- Public bucket：✅ 勾選（讓圖片可以公開存取）

-- 4. Storage 公開讀取政策（在 Storage → images bucket → Policies 新增）
-- 或直接執行以下 SQL：
INSERT INTO storage.buckets (id, name, public)
VALUES ('images', 'images', true)
ON CONFLICT (id) DO NOTHING;

CREATE POLICY "Public can view images"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'images');

CREATE POLICY "Anyone can upload images"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'images');

CREATE POLICY "Anyone can delete images"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'images');
