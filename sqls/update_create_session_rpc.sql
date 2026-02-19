-- Update the RPC to create a session
-- This version explicitly ONLY adds the provided p_participant_ids
-- It does NOT add all league members by default.

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
  v_session_record json;
BEGIN
  -- 1. Create the session
  INSERT INTO league_sessions (
    league_id, 
    name, 
    start_date, 
    end_date, 
    format, 
    game_type, 
    rules, 
    court_promotion,
    status -- Default to upcoming if not specified, usually handled by DB default
  )
  VALUES (
    p_league_id, 
    p_name, 
    p_start_date, 
    p_end_date, 
    p_format, 
    p_game_type, 
    p_rules, 
    p_court_promotion,
    'upcoming'
  )
  RETURNING id INTO v_session_id;

  -- 2. Add participants (ONLY those explicitly provided)
  IF p_participant_ids IS NOT NULL AND array_length(p_participant_ids, 1) > 0 THEN
    INSERT INTO session_participants (session_id, user_id, status, joined_at)
    SELECT 
      v_session_id, 
      unnest(p_participant_ids), 
      'active', 
      now()
    ON CONFLICT (session_id, user_id) DO NOTHING;
  END IF;
  
  -- 3. Return the created session
  SELECT row_to_json(ls.*) INTO v_session_record
  FROM league_sessions ls
  WHERE ls.id = v_session_id;

  RETURN v_session_record;
END;
$$;
