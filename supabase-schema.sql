-- ============================================================
-- Monthly Planner — Supabase schema
-- 請把這整份貼到 Supabase 的 SQL Editor，按 Run 執行一次即可
-- ============================================================

-- 1) 類別表（會議/課程/工作...）
create table if not exists public.categories (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  label text not null,
  color text not null,
  created_at timestamptz not null default now()
);

-- 2) 待辦事項表
create table if not exists public.tasks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  date text not null,                 -- 格式 YYYY-MM-DD
  title text not null,
  status text not null default 'todo', -- 'todo' | 'done'
  category_id uuid,
  created_at timestamptz not null default now()
);

-- 3) 便條紙表（每個使用者一筆）
create table if not exists public.notes (
  user_id uuid primary key references auth.users(id) on delete cascade,
  content text not null default '',
  updated_at timestamptz not null default now()
);

-- ------------------------------------------------------------
-- 開啟 Row Level Security（RLS）：每個使用者只能存取自己的資料
-- ------------------------------------------------------------
alter table public.categories enable row level security;
alter table public.tasks      enable row level security;
alter table public.notes      enable row level security;

-- categories 政策
create policy "categories_select_own" on public.categories
  for select using (auth.uid() = user_id);
create policy "categories_insert_own" on public.categories
  for insert with check (auth.uid() = user_id);
create policy "categories_update_own" on public.categories
  for update using (auth.uid() = user_id);
create policy "categories_delete_own" on public.categories
  for delete using (auth.uid() = user_id);

-- tasks 政策
create policy "tasks_select_own" on public.tasks
  for select using (auth.uid() = user_id);
create policy "tasks_insert_own" on public.tasks
  for insert with check (auth.uid() = user_id);
create policy "tasks_update_own" on public.tasks
  for update using (auth.uid() = user_id);
create policy "tasks_delete_own" on public.tasks
  for delete using (auth.uid() = user_id);

-- notes 政策
create policy "notes_select_own" on public.notes
  for select using (auth.uid() = user_id);
create policy "notes_insert_own" on public.notes
  for insert with check (auth.uid() = user_id);
create policy "notes_update_own" on public.notes
  for update using (auth.uid() = user_id);
create policy "notes_delete_own" on public.notes
  for delete using (auth.uid() = user_id);

-- ------------------------------------------------------------
-- 新使用者註冊時，自動建立 5 個預設類別 + 一筆空便條紙
-- ------------------------------------------------------------
create or replace function public.handle_new_planner_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.notes (user_id, content) values (new.id, '');
  insert into public.categories (user_id, label, color) values
    (new.id, '會議', 'lavender'),
    (new.id, '課程', 'blue'),
    (new.id, '工作', 'pink'),
    (new.id, '生活', 'mint'),
    (new.id, '其他', 'gray');
  return new;
end;
$$;

drop trigger if exists on_auth_user_created_planner on auth.users;
create trigger on_auth_user_created_planner
  after insert on auth.users
  for each row execute procedure public.handle_new_planner_user();
