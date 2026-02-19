-- Add missing columns to profiles table
-- We use DO blocks or IF EXISTS checks to make it idempotent-ish, 
-- but straightforward ALTER TABLE statements are often easiest if we know they are missing.

-- 1. First Name & Last Name
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS first_name text,
ADD COLUMN IF NOT EXISTS last_name text;

-- 2. Role (default 'player')
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS role text DEFAULT 'player';

-- 3. NTRP Rating
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS ntrp_rating text;

-- 4. Status (active/pending/blocked)
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS status text DEFAULT 'active';

-- 5. Avatar URL (might already exist, but good to ensure)
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS avatar_url text;

-- 6. Email (optional, usually better to fetch from auth.users, but we store a copy for easy display)
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS email text;

-- 7. Create a trigger to sync email from auth.users (Optional but recommended if we store email)
-- For now, we will just rely on the app to update it or manually populating it.
-- A simple update to backfill email for existing users:
-- UPDATE profiles SET email = (SELECT email FROM auth.users WHERE auth.users.id = profiles.id);
