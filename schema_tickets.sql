-- ============================================
-- Abdul's Tech Solutions — Job Tickets
-- Run this once in Supabase SQL Editor (Dashboard → SQL Editor → New Query → paste → Run)
-- ============================================

create table if not exists tickets (
  id uuid default gen_random_uuid() primary key,
  ticket_number text not null,
  customer_id uuid references customers(id) on delete set null,
  document_id uuid references documents(id) on delete set null, -- the accepted quote this came from
  title text not null,
  status text not null default 'open', -- open / in_progress / done
  log jsonb not null default '[]',      -- [{timestamp, note}]
  created_at timestamptz default now()
);

alter table tickets enable row level security;

do $$
begin
  if not exists (select 1 from pg_policies where tablename = 'tickets' and policyname = 'Allow all on tickets') then
    create policy "Allow all on tickets" on tickets for all using (true) with check (true);
  end if;
end $$;
