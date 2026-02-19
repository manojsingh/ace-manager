-- Add round_dates column to league_sessions table
ALTER TABLE league_sessions
ADD COLUMN IF NOT EXISTS round_dates JSONB DEFAULT '[]'::jsonb;
