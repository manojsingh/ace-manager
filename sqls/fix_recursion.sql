-- Drop existing policies to start fresh and avoid conflicts
DROP POLICY IF EXISTS "Public leagues are viewable by everyone" ON leagues;
DROP POLICY IF EXISTS "Members can view private leagues" ON leagues;
DROP POLICY IF EXISTS "Owners can manage their leagues" ON leagues;

DROP POLICY IF EXISTS "Users can view own memberships" ON league_members;
DROP POLICY IF EXISTS "Members can view other members" ON league_members;
DROP POLICY IF EXISTS "Owners can manage members" ON league_members;
DROP POLICY IF EXISTS "Owners can insert initial member record" ON league_members;

-- Function to get league IDs for the current user safely (bypassing RLS)
CREATE OR REPLACE FUNCTION get_my_league_ids()
RETURNS SETOF uuid
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
  SELECT league_id FROM league_members WHERE user_id = auth.uid()
$$;

-- LEAGUES Policies

CREATE POLICY "Public leagues are viewable by everyone" 
ON leagues FOR SELECT 
USING (is_public = true);

CREATE POLICY "Owners can manage their leagues" 
ON leagues FOR ALL 
USING (auth.uid() = owner_id);

CREATE POLICY "Members can view private leagues" 
ON leagues FOR SELECT 
USING (
  id IN (SELECT get_my_league_ids())
);

-- LEAGUE MEMBERS Policies

CREATE POLICY "Users can view own memberships" 
ON league_members FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Members can view other members in same league" 
ON league_members FOR SELECT 
USING (
  league_id IN (SELECT get_my_league_ids())
);

CREATE POLICY "Owners can manage members" 
ON league_members FOR ALL 
USING (
  league_id IN (SELECT id FROM leagues WHERE owner_id = auth.uid())
);

-- Allow inserting if you own the league
CREATE POLICY "Owners can insert initial member record"
ON league_members FOR INSERT
WITH CHECK (
  league_id IN (SELECT id FROM leagues WHERE owner_id = auth.uid())
);
