-- Function to update session schedule, clean up availability, and notify participants
-- Deploy this via Supabase SQL Editor

-- DROP ALL variations to avoid ambiguity
drop function if exists update_session_schedule(uuid, text[]);
drop function if exists update_session_schedule(uuid, jsonb);

create or replace function update_session_schedule(
  p_session_id uuid,
  p_round_dates jsonb
) returns void as $$
declare
  v_participant record;
  v_updater_id uuid;
  v_valid_dates date[];
  v_date_str text;
  v_availability jsonb;
  v_new_availability jsonb;
  v_key text;
  v_changed boolean;
  v_rows_updated integer;
begin
  -- Get current user ID
  v_updater_id := auth.uid();

  -- 1. Update Session Schedule
  update league_sessions
  set round_dates = p_round_dates
  where id = p_session_id;

  -- Check if update happened
  get diagnostics v_rows_updated = ROW_COUNT;
  if v_rows_updated = 0 then
    raise exception 'Session not found or permission denied for ID: %', p_session_id;
  end if;

  -- Prepare valid dates set for comparison
  with dates as (
    select jsonb_array_elements_text(p_round_dates) as d
  )
  select array_agg(d::date) into v_valid_dates from dates;

  -- 2. Process Participants
  for v_participant in (select * from session_participants where session_id = p_session_id) loop
    
    -- A. Cleanup Availability
    if v_participant.availability is not null then
      v_availability := v_participant.availability;
      v_new_availability := v_availability;
      v_changed := false;
      
      -- Iterate user's availability keys
      for v_key in select jsonb_object_keys(v_availability) loop
        -- check if key exists in valid dates
        if v_valid_dates is null or not (v_key = any(select to_char(unnest(v_valid_dates), 'YYYY-MM-DD'))) then
          v_new_availability := v_new_availability - v_key;
          v_changed := true;
        end if;
      end loop;

      if v_changed then
        update session_participants
        set availability = v_new_availability
        where id = v_participant.id;
      end if;
    end if;

    -- B. Send Notification
    if v_participant.user_id != v_updater_id then
      insert into notifications (user_id, type, title, message, data, is_read, created_at)
      values (
        v_participant.user_id,
        'schedule_update',
        'Session Schedule Updated',
        'The schedule for your session has changed. Please review your availability.',
        jsonb_build_object('session_id', p_session_id),
        false,
        now()
      );
    end if;
  end loop;
end;
$$ language plpgsql security definer;
