-- Sync email and metadata from auth.users to public.profiles

-- 1. Update email from auth.users
UPDATE public.profiles
SET email = auth.users.email
FROM auth.users
WHERE public.profiles.id = auth.users.id
  AND public.profiles.email IS NULL;

-- 2. Update first_name and last_name from raw_user_meta_data if available
-- Note: This depends on how your auth provider stores metadata. 
-- Common paths: raw_user_meta_data->>'full_name', raw_user_meta_data->>'name', etc.
-- If you don't have metadata, you might want to set a fallback like 'User' + id

UPDATE public.profiles
SET 
  first_name = COALESCE(
    (auth.users.raw_user_meta_data->>'first_name'), 
    split_part(COALESCE(auth.users.raw_user_meta_data->>'full_name', auth.users.raw_user_meta_data->>'name', 'User'), ' ', 1)
  ),
  last_name = COALESCE(
    (auth.users.raw_user_meta_data->>'last_name'), 
    substring(COALESCE(auth.users.raw_user_meta_data->>'full_name', auth.users.raw_user_meta_data->>'name', '') from position(' ' in COALESCE(auth.users.raw_user_meta_data->>'full_name', auth.users.raw_user_meta_data->>'name', '')) + 1)
  )
FROM auth.users
WHERE public.profiles.id = auth.users.id
  AND (public.profiles.first_name IS NULL OR public.profiles.first_name = '');

-- 3. Set default role if null
UPDATE public.profiles
SET role = 'player'
WHERE role IS NULL;

-- 4. Set default status if null
UPDATE public.profiles
SET status = 'active'
WHERE status IS NULL;
