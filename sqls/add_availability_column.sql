-- Migration to add availability column to session_participants
-- Run this in Supabase SQL Editor

alter table session_participants
add column if not exists availability jsonb default '{}'::jsonb;

-- Optional: Add an index if we plan to query by availability often (not needed for current MVP)
-- create index idx_session_participants_availability on session_participants using gin (availability);
