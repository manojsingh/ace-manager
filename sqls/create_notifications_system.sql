-- 1. Create Notifications Table
CREATE TABLE IF NOT EXISTS notifications (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    type TEXT NOT NULL, -- e.g., 'league_invite', 'session_invite', 'system'
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    data JSONB DEFAULT '{}'::jsonb, -- Store extra data like league_id, session_id
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 2. Enable RLS
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- 3. RLS Policies

-- Users can view their own notifications
CREATE POLICY "Users can view own notifications"
ON notifications FOR SELECT
USING (auth.uid() = user_id);

-- Users can update their own notifications (e.g., mark as read)
CREATE POLICY "Users can update own notifications"
ON notifications FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- 4. Function to Auto-Create Notification on League Member Add
CREATE OR REPLACE FUNCTION notify_new_league_member()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_league_name TEXT;
BEGIN
    -- Get league name
    SELECT name INTO v_league_name FROM leagues WHERE id = NEW.league_id;

    -- Create notification
    INSERT INTO notifications (user_id, type, title, message, data)
    VALUES (
        NEW.user_id,
        'league_invite',
        'New League Membership',
        'You have been added to the league "' || v_league_name || '".',
        jsonb_build_object('league_id', NEW.league_id)
    );

    RETURN NEW;
END;
$$;

-- 5. Trigger
DROP TRIGGER IF EXISTS on_league_member_added ON league_members;
CREATE TRIGGER on_league_member_added
AFTER INSERT ON league_members
FOR EACH ROW
EXECUTE FUNCTION notify_new_league_member();
