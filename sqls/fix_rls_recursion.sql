-- Helper function to check if a user is an admin or owner of a league
-- SECURITY DEFINER ensures this runs without RLS restrictions, preventing recursion
CREATE OR REPLACE FUNCTION public.is_league_admin(_league_id uuid)
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM league_members
    WHERE league_id = _league_id
    AND user_id = auth.uid()
    AND role IN ('owner', 'admin')
  );
$$;

-- Helper function to check if a user is a member of a league
CREATE OR REPLACE FUNCTION public.is_league_member(_league_id uuid)
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM league_members
    WHERE league_id = _league_id
    AND user_id = auth.uid()
  );
$$;

-- Drop existing recursive policies on league_members
DROP POLICY IF EXISTS "League members can view other members" ON public.league_members;
DROP POLICY IF EXISTS "Admins can manage members" ON public.league_members;
DROP POLICY IF EXISTS "Admins can add members" ON public.league_members;
DROP POLICY IF EXISTS "Admins can update members" ON public.league_members;
DROP POLICY IF EXISTS "Admins can delete members" ON public.league_members;
DROP POLICY IF EXISTS "Users can leave" ON public.league_members; -- Optional, if it existed

-- Create new non-recursive policies

-- 1. View Policy: Members can view other members in the same league
CREATE POLICY "Members can view league members"
ON public.league_members
FOR SELECT
TO authenticated
USING (
  is_league_member(league_id)
);

-- 2. Insert Policy: Only Admins/Owners can add new members
-- (Using the new function to avoid recursion)
CREATE POLICY "Admins can add members"
ON public.league_members
FOR INSERT
TO authenticated
WITH CHECK (
  is_league_admin(league_id)
);

-- 3. Update Policy: Only Admins/Owners can update members
CREATE POLICY "Admins can update members"
ON public.league_members
FOR UPDATE
TO authenticated
USING (
  is_league_admin(league_id)
)
WITH CHECK (
  is_league_admin(league_id)
);

-- 4. Delete Policy: Admins/Owners can remove members, AND users can leave (remove themselves)
CREATE POLICY "Admins can remove members"
ON public.league_members
FOR DELETE
TO authenticated
USING (
  is_league_admin(league_id)
);

CREATE POLICY "Users can leave leagues"
ON public.league_members
FOR DELETE
TO authenticated
USING (
  user_id = auth.uid()
);

-- Update policies on other tables that might check league membership (e.g. sessions, clubs)
-- Ensuring they use the safe functions

-- Example: Sessions
-- "League members can view sessions"
-- "Admins can manage sessions"

-- We can proactively safe-guard the sessions table too if we know the policy names,
-- but sticking to league_members is the primary fix for the recursion reported.
