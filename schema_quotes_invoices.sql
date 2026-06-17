-- ============================================
-- Abdul's Tech Solutions — Quotes & Invoices addition
-- Run this once in Supabase SQL Editor (Dashboard → SQL Editor → New Query → paste → Run)
-- Safe to run even if you've already run the original schema.sql — uses IF NOT EXISTS.
-- ============================================

create table if not exists documents (
  id uuid default gen_random_uuid() primary key,
  doc_type text not null,              -- 'quote' or 'invoice'
  doc_number text not null,            -- e.g. Q-0001 / INV-0001
  client_name text not null,
  client_contact text default '',      -- phone / email
  client_address text default '',
  items jsonb not null default '[]',   -- [{description, qty, price}]
  notes text default '',
  status text not null default 'draft',-- draft / sent / accepted / declined (quote) | draft / sent / paid / overdue (invoice)
  issue_date date not null default current_date,
  due_date date,
  linked_job_id uuid references jobs(id) on delete set null,
  converted_to_invoice_id uuid references documents(id) on delete set null, -- set on a quote once it becomes an invoice
  created_at timestamptz default now()
);

alter table documents enable row level security;

do $$
begin
  if not exists (
    select 1 from pg_policies where tablename = 'documents' and policyname = 'Allow all on documents'
  ) then
    create policy "Allow all on documents" on documents for all using (true) with check (true);
  end if;
end $$;
