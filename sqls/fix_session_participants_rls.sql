-- Enable RLS
ALTER TABLE session_participants ENABLE ROW LEVEL SECURITY;

-- Drop existing policies to be safe (in case they exist but are wrong)
DROP POLICY IF EXISTS "Session participants are viewable by everyone" ON session_participants;
DROP POLICY IF EXISTS "Users can join sessions" ON session_participants;
DROP POLICY IF EXISTS "Users can leave sessions" ON session_participants;
DROP POLICY IF EXISTS "League managers can manage session participants" ON session_participants;

-- 1. View session participants (Public/Authenticated)
CREATE POLICY "Session participants are viewable by everyone" 
ON session_participants FOR SELECT 
USING (true);

-- 2. Users can join sessions (Insert own record)
-- Requirement: User must be a member of the league (any role)
CREATE POLICY "Users can join sessions" 
ON session_participants FOR INSERT 
WITH CHECK (
  auth.uid() = user_id
  AND EXISTS (
    SELECT 1 FROM league_sessions ls
    JOIN league_members lm ON ls.league_id = lm.league_id
    WHERE ls.id = session_id 
    AND lm.user_id = auth.uid()
  )
);

-- 3. Users can leave sessions (Delete own record)
CREATE POLICY "Users can leave sessions" 
ON session_participants FOR DELETE 
USING (auth.uid() = user_id);

-- 4. Managers (Admin/Owner) can manage participants (Insert/Update/Delete)
CREATE POLICY "League managers can manage session participants" 
ON session_participants FOR ALL 
USING (
  EXISTS (
    SELECT 1 FROM league_sessions ls
    JOIN leagues l ON ls.league_id = l.id
    LEFT JOIN league_members lm ON l.id = lm.league_id AND lm.user_id = auth.uid()
    WHERE ls.id = session_participants.session_id
    AND (l.owner_id = auth.uid() OR lm.role = 'admin')
  )
);
