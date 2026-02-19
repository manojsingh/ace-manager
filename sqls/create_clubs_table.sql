-- Create clubs table
CREATE TABLE IF NOT EXISTS clubs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  location text NOT NULL,
  court_count int NOT NULL DEFAULT 0,
  image_url text,
  created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE clubs ENABLE ROW LEVEL SECURITY;

-- Policy: Everyone can view clubs (for now)
CREATE POLICY "Public read access"
ON clubs FOR SELECT
USING (true);

-- Policy: Only Admins can insert/update/delete
-- Re-using is_admin_of_league logic concept but for App Admins. 
-- Assuming profiles.role = 'admin' designates an App Admin.

CREATE POLICY "Admins can manage clubs"
ON clubs FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM profiles
    WHERE id = auth.uid() AND role = 'admin'
  )
);
