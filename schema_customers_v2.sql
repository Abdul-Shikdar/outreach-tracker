-- ============================================
-- Abdul's Tech Solutions — Customers, Quotes & Invoices (v2 proper structure)
-- Run this once in Supabase SQL Editor (Dashboard → SQL Editor → New Query → paste → Run)
--
-- If you already ran schema_quotes_invoices.sql (the earlier flat "documents" table),
-- this REPLACES that approach with a proper customers table + documents linked to it.
-- Safe to run even if the old "documents" table exists from before — it adds the
-- customer_id link and backfills customers from any existing quotes/invoices.
-- ============================================

-- Table: customers
create table if not exists customers (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  phone text default '',
  email text default '',
  address text default '',
  notes text default '',
  created_at timestamptz default now()
);

alter table customers enable row level security;

do $$
begin
  if not exists (select 1 from pg_policies where tablename = 'customers' and policyname = 'Allow all on customers') then
    create policy "Allow all on customers" on customers for all using (true) with check (true);
  end if;
end $$;

-- Table: documents (quotes & invoices) — create if it doesn't exist yet
create table if not exists documents (
  id uuid default gen_random_uuid() primary key,
  doc_type text not null,
  doc_number text not null,
  client_name text not null,
  client_contact text default '',
  client_address text default '',
  items jsonb not null default '[]',
  notes text default '',
  status text not null default 'draft',
  issue_date date not null default current_date,
  due_date date,
  linked_job_id uuid references jobs(id) on delete set null,
  converted_to_invoice_id uuid references documents(id) on delete set null,
  created_at timestamptz default now()
);

alter table documents enable row level security;

do $$
begin
  if not exists (select 1 from pg_policies where tablename = 'documents' and policyname = 'Allow all on documents') then
    create policy "Allow all on documents" on documents for all using (true) with check (true);
  end if;
end $$;

-- Add customer_id link to documents (new in this version)
alter table documents add column if not exists customer_id uuid references customers(id) on delete set null;

-- Add payment_method to documents (cash / transfer) — used for the 5% cash discount calc
alter table documents add column if not exists payment_method text default 'cash';

-- Backfill: create a customer record for every distinct client_name already in documents
-- that doesn't already have a matching customer (case-insensitive match on name).
insert into customers (name, phone, email, address)
select distinct on (lower(trim(d.client_name)))
  trim(d.client_name),
  case when d.client_contact ~ '^[0-9+ ]+$' then d.client_contact else '' end,
  case when d.client_contact ~ '@' then d.client_contact else '' end,
  d.client_address
from documents d
where not exists (
  select 1 from customers c where lower(trim(c.name)) = lower(trim(d.client_name))
);

-- Link existing documents to their matching customer record
update documents d
set customer_id = c.id
from customers c
where lower(trim(c.name)) = lower(trim(d.client_name))
  and d.customer_id is null;
