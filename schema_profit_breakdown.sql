-- ============================================
-- Abdul's Tech Solutions — Profit breakdown addition
-- Run this once in Supabase SQL Editor (Dashboard → SQL Editor → New Query → paste → Run)
-- Adds parts cost / labour / mileage fields to documents so profit (labour only)
-- can be tracked separately from total invoiced (which includes parts cost passed through).
-- Safe to run even if already applied — uses IF NOT EXISTS.
-- ============================================

alter table documents add column if not exists parts_cost numeric default 0;
alter table documents add column if not exists labour numeric default 0;
alter table documents add column if not exists mileage numeric default 0;
