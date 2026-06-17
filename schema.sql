-- ============================================
-- Abdul's Tech Solutions — Outreach App Schema
-- Run this once in Supabase SQL Editor
-- (Dashboard → SQL Editor → New Query → paste this → Run)
-- ============================================

-- Table: businesses contacted each week
create table if not exists outreach (
  id uuid default gen_random_uuid() primary key,
  week_key text not null,
  name text not null,
  type text,
  area text,
  contact text,
  link text,
  message text,
  status text default 'unsent',
  notes text default '',
  contacted_date timestamptz,
  created_at timestamptz default now()
);

-- Table: jobs / income tracker
create table if not exists jobs (
  id uuid default gen_random_uuid() primary key,
  client text not null,
  job_type text,
  amount numeric default 0,
  status text default 'pending',
  source text default 'outreach',
  notes text default '',
  job_date timestamptz default now(),
  created_at timestamptz default now()
);

-- Table: which Facebook post index is active for which week
create table if not exists fb_posts_used (
  id uuid default gen_random_uuid() primary key,
  week_key text not null unique,
  post_index int default 0,
  created_at timestamptz default now()
);

-- Enable Row Level Security
alter table outreach enable row level security;
alter table jobs enable row level security;
alter table fb_posts_used enable row level security;

-- Allow all access for now (single user, password handled in app layer)
-- NOTE: this means anyone with your anon key could read/write.
-- Since the anon key is public-facing in your HTML, this is fine for a
-- single-user personal tool, but don't store anything truly sensitive.
create policy "Allow all on outreach" on outreach for all using (true) with check (true);
create policy "Allow all on jobs" on jobs for all using (true) with check (true);
create policy "Allow all on fb_posts_used" on fb_posts_used for all using (true) with check (true);
