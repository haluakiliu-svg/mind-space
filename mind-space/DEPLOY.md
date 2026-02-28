# MIND SPACE — 部署說明 DEPLOY GUIDE

## 📋 步驟總覽

```
1. 建立 Supabase 專案（資料庫 + 圖片儲存）
2. 執行 SQL 初始化資料庫
3. 填入 API Key 到 supabase.js
4. 推上 GitHub
5. 部署到 Vercel
```

---

## STEP 1｜建立 Supabase 專案

1. 前往 **https://supabase.com** → 點「Start your project」
2. 用 GitHub 登入（最快）
3. 點「New project」
   - Organization: 選你的帳號
   - Name: `mind-space`（任意）
   - Database Password: 設一個強密碼（記下來）
   - Region: `Southeast Asia (Singapore)` 最近
4. 等待約 1 分鐘建立完成

---

## STEP 2｜初始化資料庫

1. 進入你的 Supabase 專案後台
2. 左側選單 → **SQL Editor**
3. 點「New query」
4. 把 `schema.sql` 的全部內容貼入，點「Run」
5. 看到 `Success` 就完成了

---

## STEP 3｜取得 API Key

1. 左側選單 → **Project Settings（齒輪圖示）** → **API**
2. 複製以下兩個值：
   - **Project URL**：像 `https://abcdefgh.supabase.co`
   - **anon / public key**：很長的 JWT 字串

3. 打開專案資料夾中的 **`supabase.js`**，替換：

```js
// 改這兩行！
const SUPABASE_URL = 'https://你的ID.supabase.co';
const SUPABASE_ANON_KEY = '你的anon key';
```

---

## STEP 4｜驗證 Storage（圖片儲存）

1. Supabase 後台 → 左側 **Storage**
2. 確認有一個名為 `images` 的 bucket
3. 如果沒有，點「New bucket」→ Name: `images`，勾選「Public bucket」→ Save
4. 點進 `images` bucket → **Policies** → 確認有 `Public can view` 的規則
   - 如果沒有，點「New policy」→ 選「Full customization」→ 允許 SELECT（select）給所有人

---

## STEP 5｜本地測試

用 VS Code 的 Live Server 套件，或直接用：
```bash
npx serve .
```
開啟 http://localhost:3000，確認前台和後台正常運作。

---

## STEP 6｜推上 GitHub

```bash
# 在專案資料夾中
git init
git add .
git commit -m "init: mind space website"
git branch -M main

# 在 GitHub 建立新 repo，然後：
git remote add origin https://github.com/你的帳號/mind-space.git
git push -u origin main
```

---

## STEP 7｜部署到 Vercel

1. 前往 **https://vercel.com** → 用 GitHub 登入
2. 點「Add New Project」
3. 選擇你剛推的 `mind-space` repo → Import
4. Framework Preset 選「**Other**」
5. 點「Deploy」→ 等 1 分鐘
6. 部署完成！Vercel 會給你一個免費網址

### ✅ 之後更新網站

只要 `git push`，Vercel 自動重新部署。

---

## 🔒 安全建議（選做）

目前後台是完全公開的，任何人只要知道網址都可以進入。
如果要保護後台，有兩個選項：

**Option A（簡單）：Vercel Password Protection**
- Vercel 後台 → 你的 project → Settings → Security → Password Protection

**Option B（完整）：Supabase Auth**
- 在後台加入 Google 或 Email 登入
- 需要額外設定，之後可以找我幫你做

---

## 📁 檔案結構

```
mind-space/
├── index.html        ← 首頁
├── music.html        ← 我在聽音樂
├── explore.html      ← 我在探索世界
├── tech.html         ← 科技投資思考
├── marketing.html    ← 行銷專案思考
├── admin.html        ← 後台上稿介面
├── supabase.js       ← ⚠ 填入你的 API Key
├── schema.sql        ← 資料庫初始化 SQL
└── DEPLOY.md         ← 本文件
```

---

## ❓常見問題

**Q: 上傳圖片失敗？**
A: 確認 Storage bucket 名稱是 `images`，且設定為 Public。

**Q: 文章發布成功但前台看不到？**
A: 確認 `posts` table 的 Row Level Security 政策有開放 SELECT。

**Q: 部署到 Vercel 後網址是什麼？**
A: 預設是 `your-repo-name.vercel.app`，可以在 Vercel 設定自訂網域。
