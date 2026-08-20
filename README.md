# Monthly Planner — 獨立網頁版待辦 App

這個資料夾是一個完整、可以獨立部署的網頁 App：
- 資料儲存在 **Supabase**（雲端資料庫），不是 localStorage、也不是 Claude Artifact 的 window.storage
- 用 **Email + 密碼** 登入，每個帳號只會看到自己的待辦資料（Row Level Security）
- 部署到 **Vercel** 後會拿到一個像 `https://xxxxx.vercel.app` 的網址
- 支援加入手機主畫面（PWA）

## 檔案說明
- `index.html` — 整個 App（月曆、待辦、便條紙、登入畫面全部在這一份檔案裡）
- `config.js` — 你要把 Supabase 的 URL 和 anon key 貼在這裡
- `supabase-schema.sql` — 到 Supabase 的 SQL Editor 貼上執行一次，建立資料表 + 安全規則
- `manifest.json` / `sw.js` / `icons/` — PWA 設定，讓手機可以「加入主畫面」
- `vercel.json` — 部署設定（不用動）

## 設定順序（詳細步驟請看對話中的逐步引導）
1. 建立 Supabase 帳號 + 專案
2. 在 Supabase SQL Editor 執行 `supabase-schema.sql`
3. 確認 Authentication 是用 Email 登入（預設就是開啟的）
4. 複製 Supabase 的 Project URL 和 anon key
5. 貼到 `config.js`
6. 把整個資料夾上傳到 GitHub
7. 用 Vercel 匯入這個 GitHub repo 部署
8. 拿到 Vercel 網址
9. 手機 Safari 打開網址 →「加入主畫面」
10. 電腦、手機分別登入同一組帳號密碼，測試同步
