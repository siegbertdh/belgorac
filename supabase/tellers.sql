-- =====================================================================
--  BELGORAC – anonieme speltellers
--  Plakken in: Supabase → SQL Editor → New query → Run
--
--  Wat dit doet:
--   * Eén tabel met per spel één getal: hoe vaak er op "Spelen" geklikt is.
--   * Er wordt NIETS over spelers bewaard: geen naam, geen IP, geen account.
--   * Iedereen mag de tellers lezen.
--   * Ophogen kan alleen met +1 via de functie count_play, en alleen voor
--     de spellen die in de lijst staan. Rechtstreeks schrijven in de tabel
--     is voor bezoekers verboden.
-- =====================================================================

create table if not exists public.game_plays (
  game  text primary key,
  plays bigint not null default 0
);

insert into public.game_plays (game) values
  ('belgoville'), ('zombienacht'), ('nova3-demonenjacht'), ('belgogoal'),
  ('belgofashion'), ('fietsrace'), ('king-of-pop-tycoon'), ('belgodorp')
on conflict (game) do nothing;

alter table public.game_plays enable row level security;
revoke all on public.game_plays from anon, authenticated;
grant select on public.game_plays to anon, authenticated;

drop policy if exists "iedereen mag de tellers lezen" on public.game_plays;
create policy "iedereen mag de tellers lezen" on public.game_plays
  for select to anon, authenticated using (true);

-- +1 voor één spel (bestaat het spel niet in de tabel, dan gebeurt er niets)
create or replace function public.count_play(g text) returns void
language sql security definer set search_path = '' as $$
  update public.game_plays set plays = plays + 1 where game = g;
$$;

revoke all on function public.count_play(text) from public;
grant execute on function public.count_play(text) to anon, authenticated;

-- Nieuw spel toevoegen later:
--   insert into public.game_plays (game) values ('naam-van-de-repo');
-- Tellers op nul zetten:
--   update public.game_plays set plays = 0;
