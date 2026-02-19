-- Allow users to update their own participation record (e.g., availability)
CREATE POLICY "Users can update their own participation" 
ON session_participants FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);
