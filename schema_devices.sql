-- ============================================
-- Abdul's Tech Solutions — Devices (for bulk reimaging/repair jobs)
-- Run this once in Supabase SQL Editor
-- ============================================

create table if not exists devices (
  id uuid default gen_random_uuid() primary key,
  ticket_id uuid references tickets(id) on delete cascade,
  serial text not null,
  device_name text default '',
  fault text default '',
  notes text default '',
  price numeric default 0,
  created_at timestamptz default now()
);

alter table devices enable row level security;

do $$
begin
  if not exists (select 1 from pg_policies where tablename = 'devices' and policyname = 'Allow all on devices') then
    create policy "Allow all on devices" on devices for all using (true) with check (true);
  end if;
end $$;
