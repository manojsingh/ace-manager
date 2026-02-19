-- Allow Admins (and Owners) to add members to a league
-- This requires checking if the executing user is an admin/owner of the target league.
-- To avoid recursion on the `league_members` table, we use a SECURITY DEFINER function.

-- 1. Create helper function to check admin/owner role
-- Uses SECURITY DEFINER to bypass RLS on league_members lookup
CREATE OR REPLACE FUNCTION is_admin_of_league(target_league_id uuid)
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
  SELECT EXISTS (
    -- 1. Check if user is a League Admin or League Owner (via membership)
    SELECT 1 
    FROM league_members 
    WHERE league_id = target_league_id 
      AND user_id = auth.uid() 
      AND role IN ('owner', 'admin')
  ) OR EXISTS (
    -- 2. Check if user is the Owner of the league record
    SELECT 1 
    FROM leagues 
    WHERE id = target_league_id 
      AND owner_id = auth.uid()
  ) OR EXISTS (
    -- 3. Check if user is an App Admin (Platform Superuser)
    SELECT 1
    FROM profiles
    WHERE id = auth.uid()
      AND role = 'admin'
  );
$$;

-- 2. Drop existing restrictive policy
DROP POLICY IF EXISTS "Owners can insert initial member record" ON league_members;
DROP POLICY IF EXISTS "Admins can add members" ON league_members;

-- 3. Create new policy using the helper function
CREATE POLICY "Admins can add members"
ON league_members FOR INSERT
WITH CHECK (
  is_admin_of_league(league_id)
);
