-- Add missing columns to league_sessions if they don't exist
ALTER TABLE league_sessions 
ADD COLUMN IF NOT EXISTS format text,
ADD COLUMN IF NOT EXISTS game_type text,
ADD COLUMN IF NOT EXISTS rules text,
ADD COLUMN IF NOT EXISTS court_promotion boolean DEFAULT false;

-- Create session_participants table if it doesn't exist
CREATE TABLE IF NOT EXISTS session_participants (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  session_id uuid REFERENCES league_sessions(id) ON DELETE CASCADE,
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  status text DEFAULT 'active', -- active, injured, withdrawn
  joined_at timestamptz DEFAULT now(),
  UNIQUE(session_id, user_id)
);

-- Enable RLS on new table
ALTER TABLE session_participants ENABLE ROW LEVEL SECURITY;

-- Policies for session_participants
CREATE POLICY "Public read session participants"
ON session_participants FOR SELECT
USING (true); -- Simplify for now, can be restricted later

CREATE POLICY "Owners can manage session participants"
ON session_participants FOR ALL
USING (
  exists (
    select 1 from league_sessions ls
    join leagues l on ls.league_id = l.id
    where ls.id = session_id and l.owner_id = auth.uid()
  )
);


-- Function to create session and participants in one transaction
CREATE OR REPLACE FUNCTION create_league_session_with_participants(
  p_league_id uuid,
  p_name text,
  p_start_date timestamptz,
  p_end_date timestamptz,
  p_format text,
  p_game_type text,
  p_rules text,
  p_court_promotion boolean,
  p_participant_ids uuid[]
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_session_id uuid;
  v_session_row json;
BEGIN
  -- 1. Insert Session
  INSERT INTO league_sessions (
    league_id, name, start_date, end_date, 
    format, game_type, rules, court_promotion, status
  ) VALUES (
    p_league_id, p_name, p_start_date, p_end_date,
    p_format, p_game_type, p_rules, p_court_promotion, 'upcoming'
  ) RETURNING id INTO v_session_id;

  -- 2. Insert Participants
  IF array_length(p_participant_ids, 1) > 0 THEN
    INSERT INTO session_participants (session_id, user_id)
    SELECT v_session_id, unnest(p_participant_ids);
  END IF;

  -- 3. Return the created session
  SELECT row_to_json(ls.*) INTO v_session_row
  FROM league_sessions ls
  WHERE ls.id = v_session_id;

  RETURN v_session_row;
END;
$$;
