-- Function to delete a user from auth.users (and cascade to public tables)
create or replace function delete_user_account(target_user_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  -- Optional: Check if the requesting user is an admin
  -- (You can uncomment this if you have an is_admin function or role check)
  -- if not exists (select 1 from public.profiles where id = auth.uid() and role = 'admin') then
  --   raise exception 'Unauthorized';
  -- end if;

  -- 1. Delete from public tables first (to be safe, though Cascade might handle it)
  -- Delete lease memberships
  delete from public.league_members where user_id = target_user_id;
  
  -- Delete profile
  delete from public.profiles where id = target_user_id;

  -- 2. Delete from auth.users
  -- This requires the function to be SECURITY DEFINER and created by a superuser (like in the dashboard)
  delete from auth.users where id = target_user_id;
end;
$$;
