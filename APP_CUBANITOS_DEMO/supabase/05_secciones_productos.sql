-- =====================================================
-- SECCIONES DE PRODUCTOS
-- Ejecutar una sola vez en Supabase para habilitar las
-- pestañas de Cobrar en Demo y Palihue.
-- =====================================================

create table if not exists public.product_sections (
  demo_id text not null references public.app_demos(id) on delete cascade,
  id text not null,
  name text not null,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  primary key (demo_id, id)
);

alter table public.products
  add column if not exists section_id text not null default 'cubanitos';

create index if not exists idx_product_sections_demo
  on public.product_sections(demo_id, sort_order);

create unique index if not exists idx_product_sections_demo_name_unique
  on public.product_sections(demo_id, lower(name));

alter table public.product_sections enable row level security;

drop policy if exists product_sections_select_all on public.product_sections;
drop policy if exists product_sections_write_admin on public.product_sections;

create policy product_sections_select_all on public.product_sections
for select to anon, authenticated
using (true);

create policy product_sections_write_admin on public.product_sections
for all to authenticated
using (public.is_demo_admin(demo_id))
with check (public.is_demo_admin(demo_id));

grant select on public.product_sections to anon, authenticated;
grant insert, update, delete on public.product_sections to authenticated;

insert into public.product_sections (demo_id, id, name, sort_order)
values
  ('demo', 'cubanitos', 'Cubanitos', 0),
  ('demo', 'extras', 'Extras', 1),
  ('palihue', 'cubanitos', 'Cubanitos', 0),
  ('palihue', 'extras', 'Extras', 1)
on conflict (demo_id, id) do update set
  name = excluded.name,
  sort_order = excluded.sort_order;

update public.products
set section_id = 'extras'
where demo_id in ('demo', 'palihue')
  and sku = 'garrapinadas';

update public.products
set section_id = 'cubanitos'
where demo_id in ('demo', 'palihue')
  and sku <> 'garrapinadas'
  and (section_id is null or section_id = '');
