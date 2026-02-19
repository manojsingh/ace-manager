-- Add foreign key constraint to session_participants for profiles
-- This is needed for Supabase/PostgREST to detect the relationship for joins like .select('*, profiles(*)')

DO $$ 
BEGIN
  -- Check if the constraint already exists to avoid errors on re-run
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'session_participants_user_id_fkey_profiles') THEN
    ALTER TABLE session_participants
    ADD CONSTRAINT session_participants_user_id_fkey_profiles
    FOREIGN KEY (user_id)
    REFERENCES profiles(id)
    ON DELETE CASCADE;
  END IF;
END $$;
