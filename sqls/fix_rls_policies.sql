-- Enable RLS
ALTER TABLE leagues ENABLE ROW LEVEL SECURITY;
ALTER TABLE league_members ENABLE ROW LEVEL SECURITY;

-- LEAGUES Policies

-- 1. Everyone can view public leagues
CREATE POLICY "Public leagues are viewable by everyone" 
ON leagues FOR SELECT 
USING (is_public = true);

-- 2. Members can view private leagues they belong to
CREATE POLICY "Members can view private leagues" 
ON leagues FOR SELECT 
USING (
  auth.uid() IN (SELECT user_id FROM league_members WHERE league_id = id)
);

-- 3. Owners can do everything with their leagues
CREATE POLICY "Owners can manage their leagues" 
ON leagues FOR ALL 
USING (auth.uid() = owner_id);


-- LEAGUE MEMBERS Policies

-- 1. Users can view their own memberships (needed for getMyLeagues)
CREATE POLICY "Users can view own memberships" 
ON league_members FOR SELECT 
USING (auth.uid() = user_id);

-- 2. League members can view other members in the same league
CREATE POLICY "Members can view other members" 
ON league_members FOR SELECT 
USING (
  league_id IN (SELECT league_id FROM league_members WHERE user_id = auth.uid())
);

-- 3. Owners can manage members of their leagues
CREATE POLICY "Owners can manage members" 
ON league_members FOR ALL 
USING (
  league_id IN (SELECT id FROM leagues WHERE owner_id = auth.uid())
);

-- 4. Users can join (insert) if the league is public (optional, for join flow later)
-- For now, we rely on the creation flow adding the owner, which falls under "Owners can manage members" technically 
-- OR we specifically allow users to insert themselves.
-- However, for the 'createLeague' flow, the user is NOT yet an owner when inserting into league_members if the RLS checks before the transaction commits fully? 
-- Actually, the user IS the owner of the league.
-- So we need a policy asking: "Is auth.uid() the owner of the league referenced in league_members?"

CREATE POLICY "Owners can insert initial member record"
ON league_members FOR INSERT
WITH CHECK (
  league_id IN (SELECT id FROM leagues WHERE owner_id = auth.uid())
);
