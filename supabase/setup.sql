create table if not exists public.leaderboard (
  user_id uuid primary key references auth.users (id) on delete cascade,
  nick text not null check (char_length(nick) between 1 and 16),
  num smallint not null check (num between 0 and 99),
  color text not null check (color ~ '^#[0-9A-Fa-f]{6}$'),
  avatar_url text,
  km bigint not null default 0 check (km >= 0),
  p1 integer not null default 0 check (p1 >= 0),
  p2 integer not null default 0 check (p2 >= 0),
  p3 integer not null default 0 check (p3 >= 0),
  gp smallint not null default 0 check (gp between 0 and 100),
  updated_at timestamptz not null default now()
);

-- Add the Google profile photo field when upgrading an existing leaderboard.
alter table public.leaderboard add column if not exists avatar_url text;

create table if not exists public.participant_progress (
  user_id uuid primary key references auth.users (id) on delete cascade,
  state jsonb not null,
  updated_at timestamptz not null default now()
);

alter table public.leaderboard enable row level security;
alter table public.participant_progress enable row level security;

drop policy if exists "Anyone can view leaderboard" on public.leaderboard;
create policy "Anyone can view leaderboard"
  on public.leaderboard for select using (true);
drop policy if exists "Participants create their own score" on public.leaderboard;
create policy "Participants create their own score"
  on public.leaderboard for insert to authenticated
  with check ((select auth.uid()) = user_id);
drop policy if exists "Participants update their own score" on public.leaderboard;
create policy "Participants update their own score"
  on public.leaderboard for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

drop policy if exists "Participants read their own progress" on public.participant_progress;
create policy "Participants read their own progress"
  on public.participant_progress for select to authenticated
  using ((select auth.uid()) = user_id);
drop policy if exists "Participants create their own progress" on public.participant_progress;
create policy "Participants create their own progress"
  on public.participant_progress for insert to authenticated
  with check ((select auth.uid()) = user_id);
drop policy if exists "Participants update their own progress" on public.participant_progress;
create policy "Participants update their own progress"
  on public.participant_progress for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

grant select on public.leaderboard to anon, authenticated;
grant insert, update on public.leaderboard to authenticated;
grant select, insert, update on public.participant_progress to authenticated;

-- Enable live leaderboard refresh without failing if it's already published.
do $$ begin
  alter publication supabase_realtime add table public.leaderboard;
exception when duplicate_object then null;
end $$;
