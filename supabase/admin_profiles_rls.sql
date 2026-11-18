alter table public.admin_profiles enable row level security;

drop policy if exists admin_profiles_select_own on public.admin_profiles;

create policy admin_profiles_select_own
on public.admin_profiles
for select
to authenticated
using ((select auth.uid()) = id);
