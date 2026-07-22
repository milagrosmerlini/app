-- =====================================================
-- MIGRACION: BASE VIEJA -> MULTI-CARRO
-- Usar solo si el proyecto ya tenia las tablas viejas creadas.
-- No borra ventas ni gastos: los asigna al demo_id 'demo'.
-- =====================================================

create extension if not exists pgcrypto;

create table if not exists public.app_demos (
  id text primary key,
  name text not null,
  app_name text not null,
  footer_text text not null default '',
  logo_url text not null default 'logo.png',
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.app_demo_access_codes (
  code text primary key,
  demo_id text not null references public.app_demos(id) on delete cascade,
  created_at timestamptz not null default now()
);

create table if not exists public.app_demo_admins (
  demo_id text not null references public.app_demos(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (demo_id, user_id)
);

create table if not exists public.admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

insert into public.app_demos (id, name, app_name, footer_text, logo_url, is_active)
values ('demo', 'Carrito Demo', 'Carrito Demo', 'Carrito Demo - App de ejemplo', 'logo.png', true)
on conflict (id) do update set
  name = excluded.name,
  app_name = excluded.app_name,
  footer_text = excluded.footer_text,
  logo_url = excluded.logo_url,
  is_active = excluded.is_active;

insert into public.app_demo_access_codes (code, demo_id)
values ('DEMO2026', 'demo')
on conflict (code) do update set demo_id = excluded.demo_id;

create or replace function public.resolve_demo_by_code(p_code text)
returns table (
  id text,
  name text,
  app_name text,
  footer_text text,
  logo_url text
)
language sql
security definer
set search_path = public
as $$
  select d.id, d.name, d.app_name, d.footer_text, d.logo_url
  from public.app_demo_access_codes c
  join public.app_demos d on d.id = c.demo_id
  where c.code = upper(trim(p_code))
    and d.is_active = true
  limit 1;
$$;

create or replace function public.is_global_admin()
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (select 1 from public.admins a where a.user_id = auth.uid());
$$;

create or replace function public.is_demo_admin(p_demo_id text)
returns boolean
language sql
security definer
set search_path = public
as $$
  select public.is_global_admin()
    or exists (
      select 1
      from public.app_demo_admins a
      where a.demo_id = p_demo_id
        and a.user_id = auth.uid()
    );
$$;

alter table public.products add column if not exists demo_id text;
alter table public.sales add column if not exists demo_id text;
alter table public.expenses add column if not exists demo_id text;
alter table public.monthly_carryovers add column if not exists demo_id text;
alter table public.peya_liquidations add column if not exists demo_id text;
alter table public.monthly_carryover_history add column if not exists demo_id text;
alter table public.daily_cash_adjustments add column if not exists demo_id text;

update public.products set demo_id = 'demo' where demo_id is null;
update public.sales set demo_id = 'demo' where demo_id is null;
update public.expenses set demo_id = 'demo' where demo_id is null;
update public.monthly_carryovers set demo_id = 'demo' where demo_id is null;
update public.peya_liquidations set demo_id = 'demo' where demo_id is null;
update public.monthly_carryover_history set demo_id = 'demo' where demo_id is null;
update public.daily_cash_adjustments set demo_id = 'demo' where demo_id is null;

alter table public.products alter column demo_id set not null;
alter table public.sales alter column demo_id set not null;
alter table public.expenses alter column demo_id set not null;
alter table public.monthly_carryovers alter column demo_id set not null;
alter table public.peya_liquidations alter column demo_id set not null;
alter table public.monthly_carryover_history alter column demo_id set not null;
alter table public.daily_cash_adjustments alter column demo_id set not null;

alter table public.products drop constraint if exists products_pkey;
alter table public.products add primary key (demo_id, sku);

alter table public.monthly_carryovers drop constraint if exists monthly_carryovers_pkey;
alter table public.monthly_carryovers add primary key (demo_id, month);

alter table public.daily_cash_adjustments drop constraint if exists daily_cash_adjustments_pkey;
alter table public.daily_cash_adjustments add primary key (demo_id, day);

do $$
begin
  if not exists (select 1 from pg_constraint where conname = 'products_demo_id_fkey') then
    alter table public.products add constraint products_demo_id_fkey foreign key (demo_id) references public.app_demos(id) on delete cascade;
  end if;
  if not exists (select 1 from pg_constraint where conname = 'sales_demo_id_fkey') then
    alter table public.sales add constraint sales_demo_id_fkey foreign key (demo_id) references public.app_demos(id) on delete cascade;
  end if;
  if not exists (select 1 from pg_constraint where conname = 'expenses_demo_id_fkey') then
    alter table public.expenses add constraint expenses_demo_id_fkey foreign key (demo_id) references public.app_demos(id) on delete cascade;
  end if;
  if not exists (select 1 from pg_constraint where conname = 'monthly_carryovers_demo_id_fkey') then
    alter table public.monthly_carryovers add constraint monthly_carryovers_demo_id_fkey foreign key (demo_id) references public.app_demos(id) on delete cascade;
  end if;
  if not exists (select 1 from pg_constraint where conname = 'peya_liquidations_demo_id_fkey') then
    alter table public.peya_liquidations add constraint peya_liquidations_demo_id_fkey foreign key (demo_id) references public.app_demos(id) on delete cascade;
  end if;
  if not exists (select 1 from pg_constraint where conname = 'monthly_carryover_history_demo_id_fkey') then
    alter table public.monthly_carryover_history add constraint monthly_carryover_history_demo_id_fkey foreign key (demo_id) references public.app_demos(id) on delete cascade;
  end if;
  if not exists (select 1 from pg_constraint where conname = 'daily_cash_adjustments_demo_id_fkey') then
    alter table public.daily_cash_adjustments add constraint daily_cash_adjustments_demo_id_fkey foreign key (demo_id) references public.app_demos(id) on delete cascade;
  end if;
end $$;

create index if not exists idx_products_demo on public.products(demo_id);
create index if not exists idx_sales_demo_day on public.sales(demo_id, day);
create index if not exists idx_expenses_demo_date on public.expenses(demo_id, date);
create index if not exists idx_peya_liq_demo_month on public.peya_liquidations(demo_id, month);
create index if not exists idx_carryover_hist_demo_month on public.monthly_carryover_history(demo_id, month);

alter table public.app_demos enable row level security;
alter table public.app_demo_access_codes enable row level security;
alter table public.app_demo_admins enable row level security;

drop policy if exists app_demos_select_all on public.app_demos;
drop policy if exists app_demos_write_admin on public.app_demos;
drop policy if exists app_demo_codes_write_admin on public.app_demo_access_codes;
drop policy if exists app_demo_admins_select_self on public.app_demo_admins;
drop policy if exists app_demo_admins_write_global_admin on public.app_demo_admins;

create policy app_demos_select_all on public.app_demos
for select to anon, authenticated
using (is_active = true);

create policy app_demos_write_admin on public.app_demos
for all to authenticated
using (public.is_global_admin())
with check (public.is_global_admin());

create policy app_demo_codes_write_admin on public.app_demo_access_codes
for all to authenticated
using (public.is_global_admin())
with check (public.is_global_admin());

create policy app_demo_admins_select_self on public.app_demo_admins
for select to authenticated
using (user_id = auth.uid() or public.is_global_admin());

create policy app_demo_admins_write_global_admin on public.app_demo_admins
for all to authenticated
using (public.is_global_admin())
with check (public.is_global_admin());

grant execute on function public.resolve_demo_by_code(text) to anon, authenticated;
grant execute on function public.is_global_admin() to authenticated;
grant execute on function public.is_demo_admin(text) to authenticated;
grant select on public.app_demos to anon, authenticated;
grant insert, update, delete on public.app_demos to authenticated;
grant insert, update, delete on public.app_demo_access_codes to authenticated;
grant select on public.app_demo_admins to authenticated;
grant insert, update, delete on public.app_demo_admins to authenticated;
