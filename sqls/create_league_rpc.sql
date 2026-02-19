-- RPC to create a league and automatically add the creator as the owner
-- This avoids RLS race conditions where the user creates a league but can't yet "see" it to add themselves as a member.

CREATE OR REPLACE FUNCTION create_league_v2(
  p_name text,
  p_description text,
  p_location text,
  p_is_public boolean,
  p_logo_url text
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER -- Run as database owner to bypass RLS during creation
SET search_path = public
AS $$
DECLARE
  v_league_id uuid;
  v_user_id uuid;
  v_league_record json;
BEGIN
  -- Get current user ID
  v_user_id := auth.uid();
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'User not logged in';
  END IF;

  -- 1. Insert League
  INSERT INTO leagues (
    name, 
    description, 
    owner_id, 
    location, 
    is_public, 
    logo_url
  )
  VALUES (
    p_name, 
    p_description, 
    v_user_id, 
    p_location, 
    p_is_public, 
    p_logo_url
  )
  RETURNING id INTO v_league_id;

  -- 2. Insert Owner into League Members
  INSERT INTO league_members (
    league_id, 
    user_id, 
    role
  )
  VALUES (
    v_league_id, 
    v_user_id, 
    'owner'
  )
  ON CONFLICT (league_id, user_id) DO NOTHING;

  -- 3. Return the created league
  SELECT row_to_json(l.*) INTO v_league_record
  FROM leagues l
  WHERE l.id = v_league_id;

  RETURN v_league_record;
END;
$$;
