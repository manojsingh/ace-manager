-- Create matches table
CREATE TABLE IF NOT EXISTS matches (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  session_id uuid REFERENCES league_sessions(id) ON DELETE CASCADE,
  date timestamptz NOT NULL,
  status text DEFAULT 'scheduled', -- 'scheduled', 'completed', 'cancelled'
  score text, -- e.g., '6-4, 6-2'
  winner_id uuid REFERENCES auth.users(id),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create match_participants table (linking users to matches)
CREATE TABLE IF NOT EXISTS match_participants (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  match_id uuid REFERENCES matches(id) ON DELETE CASCADE,
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  team_id int, -- 1 or 2 (for doubles pairing or just opposing sides)
  UNIQUE(match_id, user_id)
);

-- Enable RLS
ALTER TABLE matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE match_participants ENABLE ROW LEVEL SECURITY;

-- Policies for matches
CREATE POLICY "Public read matches"
ON matches FOR SELECT
USING (true);

CREATE POLICY "League owners manage matches"
ON matches FOR ALL
USING (
  exists (
    select 1 from league_sessions ls
    join leagues l on ls.league_id = l.id
    where ls.id = matches.session_id and l.owner_id = auth.uid()
  )
);

-- Policies for match_participants
CREATE POLICY "Public read match_participants"
ON match_participants FOR SELECT
USING (true);

CREATE POLICY "League owners manage match_participants"
ON match_participants FOR ALL
USING (
  exists (
    select 1 from matches m
    join league_sessions ls on m.session_id = ls.id
    join leagues l on ls.league_id = l.id
    where m.id = match_participants.match_id and l.owner_id = auth.uid()
  )
);

-- Update session_participants to include stats
ALTER TABLE session_participants 
ADD COLUMN IF NOT EXISTS points int DEFAULT 0,
ADD COLUMN IF NOT EXISTS wins int DEFAULT 0,
ADD COLUMN IF NOT EXISTS losses int DEFAULT 0,
ADD COLUMN IF NOT EXISTS matches_played int DEFAULT 0;
    