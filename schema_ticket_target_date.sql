-- ============================================
-- Abdul's Tech Solutions — Ticket target date
-- Run this once in Supabase SQL Editor
-- ============================================

alter table tickets add column if not exists target_date date;
