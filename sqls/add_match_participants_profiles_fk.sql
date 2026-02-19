-- Add explicit foreign key relationship between match_participants and profiles
-- This allows PostgREST to embed profiles when querying match_participants

ALTER TABLE match_participants
ADD CONSTRAINT match_participants_profiles_fkey
FOREIGN KEY (user_id)
REFERENCES profiles(id)
ON DELETE CASCADE;
