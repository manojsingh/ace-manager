-- Insert sample courts for Elite Tennis Center (replace CLUB_ID with actual ID after running seeds)
-- Ideally we would select the ID, but for this script we can just insert based on club name lookups if we were running in a block.
-- Since this is just a raw SQL script for the user to run, I'll use a DO block to lookup the club ID.

DO $$
DECLARE
  v_club_id uuid;
BEGIN
  -- Find 'Riverside Tennis Center' (using the first club from previous seed)
  SELECT id INTO v_club_id FROM clubs WHERE name = 'Riverside Tennis Center' LIMIT 1;

  IF v_club_id IS NOT NULL THEN
    INSERT INTO courts (club_id, name, surface_type) VALUES
    (v_club_id, 'Court 1', 'Red Clay'),
    (v_club_id, 'Court 2', 'Grass'),
    (v_club_id, 'Court 3', 'Hard Court (Acrylic)'),
    (v_club_id, 'Court 4', 'Hard Court (Acrylic)');
  END IF;
END $$;
