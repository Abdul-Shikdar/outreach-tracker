-- ============================================
-- Abdul's Tech Solutions — Add job summary field to quotes/invoices
-- Run this once in Supabase SQL Editor (Dashboard → SQL Editor → New Query → paste → Run)
-- ============================================

alter table documents add column if not exists summary text default '';
