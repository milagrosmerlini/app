-- =====================================================
-- BASE SUPABASE - DEMO MULTI-CARRO (PLANTILLA)
-- Ejecutar este archivo en SQL Editor de un proyecto NUEVO.
-- =====================================================

create extension if not exists pgcrypto;

-- ---------------------------
-- Demos / carros
-- ---------------------------

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

-- ---------------------------
-- Tablas principales
-- ---------------------------

create table if not exists public.products (
  demo_id text not null references public.app_demos(id) on delete cascade,
  sku text not null,
  name text not null,
  unit text not null default 'Unidad',
  price_presencial numeric(12,2) not null default 0,
  price_pedidosya numeric(12,2) not null default 0,
  created_at timestamptz not null default now(),
  primary key (demo_id, sku)
);

create table if not exists public.sales (
  demo_id text not null references public.app_demos(id) on delete cascade,
  id text primary key,
  day date not null,
  time text not null,
  channel text not null default 'presencial' check (channel in ('presencial','pedidosya')),
  items jsonb not null default '[]'::jsonb,
  total numeric(12,2) not null default 0,
  cash numeric(12,2) not null default 0,
  transfer numeric(12,2) not null default 0,
  peya numeric(12,2) not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.expenses (
  demo_id text not null references public.app_demos(id) on delete cascade,
  id text primary key,
  date date not null,
  provider text not null,
  qty numeric(12,3) not null default 0,
  description text not null,
  iva numeric(12,2) not null default 0,
  iibb numeric(12,2) not null default 0,
  amount numeric(12,2) not null default 0,
  method text not null default 'efectivo',
  pay_cash numeric(12,2) not null default 0,
  pay_transfer numeric(12,2) not null default 0,
  pay_peya numeric(12,2) not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.monthly_carryovers (
  demo_id text not null references public.app_demos(id) on delete cascade,
  month text not null, -- formato: YYYY-MM
  cash numeric(12,2) not null default 0,
  transfer numeric(12,2) not null default 0,
  peya numeric(12,2) not null default 0,
  created_at timestamptz not null default now(),
  primary key (demo_id, month)
);

create table if not exists public.peya_liquidations (
  demo_id text not null references public.app_demos(id) on delete cascade,
  id text primary key,
  month text not null, -- formato: YYYY-MM
  from_date date not null,
  to_date date not null,
  amount numeric(12,2) not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.monthly_carryover_history (
  demo_id text not null references public.app_demos(id) on delete cascade,
  id text primary key,
  month text not null, -- formato: YYYY-MM
  cash numeric(12,2) not null default 0,
  transfer numeric(12,2) not null default 0,
  peya numeric(12,2) not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.daily_cash_adjustments (
  demo_id text not null references public.app_demos(id) on delete cascade,
  day date not null,
  initial numeric(12,2) not null default 0,
  real numeric(12,2),
  delta numeric(12,2),
  adjust_saved boolean not null default false,
  initial_locked boolean not null default false,
  saved_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  primary key (demo_id, day)
);

-- ---------------------------
-- Indices utiles
-- ---------------------------
create index if not exists idx_products_demo on public.products(demo_id);
create index if not exists idx_sales_demo_day on public.sales(demo_id, day);
create index if not exists idx_expenses_demo_date on public.expenses(demo_id, date);
create index if not exists idx_peya_liq_demo_month on public.peya_liquidations(demo_id, month);
create index if not exists idx_carryover_hist_demo_month on public.monthly_carryover_history(demo_id, month);

-- ---------------------------
-- RLS
-- ---------------------------
alter table public.app_demos enable row level security;
alter table public.app_demo_access_codes enable row level security;
alter table public.app_demo_admins enable row level security;
alter table public.products enable row level security;
alter table public.sales enable row level security;
alter table public.expenses enable row level security;
alter table public.monthly_carryovers enable row level security;
alter table public.peya_liquidations enable row level security;
alter table public.monthly_carryover_history enable row level security;
alter table public.daily_cash_adjustments enable row level security;
alter table public.admins enable row level security;

-- Limpieza de policies si ya existian (idempotente)
drop policy if exists app_demos_select_all on public.app_demos;
drop policy if exists app_demos_write_admin on public.app_demos;
drop policy if exists app_demo_codes_write_admin on public.app_demo_access_codes;
drop policy if exists app_demo_admins_select_self on public.app_demo_admins;
drop policy if exists app_demo_admins_write_global_admin on public.app_demo_admins;
drop policy if exists products_select_all on public.products;
drop policy if exists products_write_admin on public.products;
drop policy if exists sales_select_all on public.sales;
drop policy if exists sales_insert_all on public.sales;
drop policy if exists sales_update_admin on public.sales;
drop policy if exists sales_delete_admin on public.sales;
drop policy if exists expenses_select_all on public.expenses;
drop policy if exists expenses_write_admin on public.expenses;
drop policy if exists carryovers_select_all on public.monthly_carryovers;
drop policy if exists carryovers_write_admin on public.monthly_carryovers;
drop policy if exists peya_liq_select_all on public.peya_liquidations;
drop policy if exists peya_liq_write_admin on public.peya_liquidations;
drop policy if exists carryover_hist_select_all on public.monthly_carryover_history;
drop policy if exists carryover_hist_write_admin on public.monthly_carryover_history;
drop policy if exists cash_adjust_select_all on public.daily_cash_adjustments;
drop policy if exists cash_adjust_write_admin on public.daily_cash_adjustments;
drop policy if exists admins_select_self on public.admins;

-- Lectura publica de datos de demo. La app filtra por demo_id despues de validar codigo.
create policy app_demos_select_all on public.app_demos
for select to anon, authenticated
using (is_active = true);

create policy products_select_all on public.products
for select to anon, authenticated
using (true);

create policy sales_select_all on public.sales
for select to anon, authenticated
using (true);

create policy expenses_select_all on public.expenses
for select to authenticated
using (public.is_demo_admin(demo_id));

create policy carryovers_select_all on public.monthly_carryovers
for select to authenticated
using (public.is_demo_admin(demo_id));

create policy peya_liq_select_all on public.peya_liquidations
for select to authenticated
using (public.is_demo_admin(demo_id));

create policy carryover_hist_select_all on public.monthly_carryover_history
for select to authenticated
using (public.is_demo_admin(demo_id));

create policy cash_adjust_select_all on public.daily_cash_adjustments
for select to authenticated
using (public.is_demo_admin(demo_id));

-- Escritura de catalogo/finanzas solo admin (auth + fila en public.admins)
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

create policy products_write_admin on public.products
for all to authenticated
using (public.is_demo_admin(demo_id))
with check (public.is_demo_admin(demo_id));

create policy expenses_write_admin on public.expenses
for all to authenticated
using (public.is_demo_admin(demo_id))
with check (public.is_demo_admin(demo_id));

create policy carryovers_write_admin on public.monthly_carryovers
for all to authenticated
using (public.is_demo_admin(demo_id))
with check (public.is_demo_admin(demo_id));

create policy peya_liq_write_admin on public.peya_liquidations
for all to authenticated
using (public.is_demo_admin(demo_id))
with check (public.is_demo_admin(demo_id));

create policy carryover_hist_write_admin on public.monthly_carryover_history
for all to authenticated
using (public.is_demo_admin(demo_id))
with check (public.is_demo_admin(demo_id));

create policy cash_adjust_write_admin on public.daily_cash_adjustments
for all to authenticated
using (public.is_demo_admin(demo_id))
with check (public.is_demo_admin(demo_id));

-- Ventas: cualquiera con el codigo puede crear venta; editar/eliminar solo admin
create policy sales_insert_all on public.sales
for insert to anon, authenticated
with check (true);

create policy sales_update_admin on public.sales
for update to authenticated
using (public.is_demo_admin(demo_id))
with check (public.is_demo_admin(demo_id));

create policy sales_delete_admin on public.sales
for delete to authenticated
using (public.is_demo_admin(demo_id));

-- Admins: cada usuario autenticado solo puede leer su propia fila
create policy admins_select_self on public.admins
for select to authenticated
using (user_id = auth.uid());

-- ---------------------------
-- Grants (permite acceso via API)
-- ---------------------------
grant usage on schema public to anon, authenticated;
grant execute on function public.resolve_demo_by_code(text) to anon, authenticated;
grant execute on function public.is_global_admin() to authenticated;
grant execute on function public.is_demo_admin(text) to authenticated;

grant select on public.app_demos to anon, authenticated;
grant select on public.products to anon, authenticated;
grant select on public.sales to anon, authenticated;
grant select on public.expenses to anon, authenticated;
grant select on public.monthly_carryovers to anon, authenticated;
grant select on public.peya_liquidations to anon, authenticated;
grant select on public.monthly_carryover_history to anon, authenticated;
grant select on public.daily_cash_adjustments to anon, authenticated;
grant select on public.admins to authenticated;
grant select on public.app_demo_admins to authenticated;

grant insert on public.sales to anon, authenticated;
grant update, delete on public.sales to authenticated;

grant insert, update, delete on public.app_demos to authenticated;
grant insert, update, delete on public.app_demo_access_codes to authenticated;
grant insert, update, delete on public.app_demo_admins to authenticated;
grant insert, update, delete on public.products to authenticated;
grant insert, update, delete on public.expenses to authenticated;
grant insert, update, delete on public.monthly_carryovers to authenticated;
grant insert, update, delete on public.peya_liquidations to authenticated;
grant insert, update, delete on public.monthly_carryover_history to authenticated;
grant insert, update, delete on public.daily_cash_adjustments to authenticated;
