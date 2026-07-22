-- =====================================================
-- SEED DEMO MULTI-CARRO
-- Ejecutar en el proyecto DEMO luego de 01_base_cliente_nuevo.sql
-- =====================================================

-- Carros / demos disponibles por codigo
insert into public.app_demos (id, name, app_name, footer_text, logo_url, is_active)
values
  ('demo', 'Cubanitos Demo', 'Cubanitos Demo', 'Cubanitos Demo - App de ejemplo', 'logo.png', true),
  ('patagonia', 'Cubanitos Patagonia', 'Cubanitos Patagonia', 'Cubanitos Patagonia - App de Caja', 'logo.png', true),
  ('palihue', 'Cubanitos Palihue', 'Cubanitos Palihue', 'Cubanitos Palihue - App de Caja', 'logo.png', true)
on conflict (id) do update set
  name = excluded.name,
  app_name = excluded.app_name,
  footer_text = excluded.footer_text,
  logo_url = excluded.logo_url,
  is_active = excluded.is_active;

insert into public.app_demo_access_codes (code, demo_id)
values
  ('DEMO2026', 'demo'),
  ('PATAGONIA2026', 'patagonia'),
  ('PALIHUE2026', 'palihue')
on conflict (code) do update set
  demo_id = excluded.demo_id;

-- Limpia ventas viejas de estas nubes para arrancar limpio
delete from public.sales where demo_id in ('demo', 'patagonia', 'palihue');
delete from public.expenses where demo_id in ('demo', 'patagonia', 'palihue') and id like 'demo_%';
delete from public.peya_liquidations where demo_id in ('demo', 'patagonia', 'palihue') and id like 'demo_%';
delete from public.monthly_carryover_history where demo_id in ('demo', 'patagonia', 'palihue') and id like 'demo_%';
delete from public.monthly_carryovers where demo_id in ('demo', 'patagonia', 'palihue') and month = '2026-03';

-- Productos demo
insert into public.products (demo_id, sku, name, unit, price_presencial, price_pedidosya)
values
  ('demo', 'cubanito_comun', 'Cubanito comun', 'Unidad', 1000, 1000),
  ('demo', 'cubanito_negro', 'Cubanito choco negro', 'Unidad', 1300, 1300),
  ('demo', 'cubanito_blanco', 'Cubanito choco blanco', 'Unidad', 1300, 1300),
  ('demo', 'garrapinadas', 'Garrapinadas', 'Bolsa', 1200, 1200),
  ('patagonia', 'cubanito_comun', 'Cubanito comun', 'Unidad', 1200, 1200),
  ('patagonia', 'cubanito_negro', 'Cubanito choco negro', 'Unidad', 1500, 1500),
  ('patagonia', 'cubanito_blanco', 'Cubanito choco blanco', 'Unidad', 1500, 1500),
  ('patagonia', 'garrapinadas', 'Garrapinadas', 'Bolsa', 1400, 1400),
  ('palihue', 'cubanito_comun', 'Cubanito comun', 'Unidad', 1200, 1200),
  ('palihue', 'cubanito_negro', 'Cubanito choco negro', 'Unidad', 1500, 1500),
  ('palihue', 'cubanito_blanco', 'Cubanito choco blanco', 'Unidad', 1500, 1500),
  ('palihue', 'garrapinadas', 'Garrapinadas', 'Bolsa', 1400, 1400)
on conflict (demo_id, sku) do update set
  name = excluded.name,
  unit = excluded.unit,
  price_presencial = excluded.price_presencial,
  price_pedidosya = excluded.price_pedidosya;

-- Ventas demo recientes (julio 2026)
-- Demo: pocas ventas chicas para probar la app.
-- Palihue: ventas distintas y mas cargadas para diferenciar el carro.
insert into public.sales (demo_id, id, day, time, channel, items, total, cash, transfer, peya)
values
  ('demo', 'demo_sale_20260720_001', '2026-07-20', '15:05', 'presencial', '[{"sku":"cubanito_comun","qty":2,"unitPrice":1000}]'::jsonb, 2000, 2000, 0, 0),
  ('demo', 'demo_sale_20260721_001', '2026-07-21', '16:22', 'presencial', '[{"sku":"cubanito_negro","qty":1,"unitPrice":1300},{"sku":"cubanito_blanco","qty":1,"unitPrice":1300}]'::jsonb, 2600, 0, 2600, 0),
  ('palihue', 'demo_pali_sale_20260720_001', '2026-07-20', '15:40', 'presencial', '[{"sku":"cubanito_comun","qty":5,"unitPrice":1200},{"sku":"garrapinadas","qty":2,"unitPrice":1400}]'::jsonb, 8800, 8800, 0, 0),
  ('palihue', 'demo_pali_sale_20260721_001', '2026-07-21', '17:25', 'presencial', '[{"sku":"cubanito_negro","qty":3,"unitPrice":1500},{"sku":"cubanito_blanco","qty":3,"unitPrice":1500}]'::jsonb, 9000, 4000, 5000, 0),
  ('patagonia', 'demo_pat_sale_20260721_001', '2026-07-21', '18:20', 'presencial', '[{"sku":"cubanito_blanco","qty":3,"unitPrice":1500}]'::jsonb, 4500, 0, 4500, 0)
on conflict (id) do update set
  demo_id = excluded.demo_id,
  day = excluded.day,
  time = excluded.time,
  channel = excluded.channel,
  items = excluded.items,
  total = excluded.total,
  cash = excluded.cash,
  transfer = excluded.transfer,
  peya = excluded.peya;

-- Gastos demo
insert into public.expenses (demo_id, id, date, provider, qty, description, iva, iibb, amount, method, pay_cash, pay_transfer, pay_peya)
values
  ('demo', 'demo_exp_001', '2026-03-10', 'MAXI', 2, 'CUBANITO COMUN', 0, 0, 1800, 'efectivo', 1800, 0, 0),
  ('demo', 'demo_exp_002', '2026-03-11', 'PLASTICOS BLANCOS', 1, 'BOLSAS GARRAPINADAS', 0, 0, 2500, 'transferencia', 0, 2500, 0),
  ('patagonia', 'demo_pat_exp_001', '2026-03-10', 'MAXI', 3, 'CUBANITO COMUN', 0, 0, 2700, 'efectivo', 2700, 0, 0),
  ('palihue', 'demo_pali_exp_001', '2026-03-10', 'MAXI', 3, 'CUBANITO COMUN', 0, 0, 2700, 'efectivo', 2700, 0, 0)
on conflict (id) do update set
  demo_id = excluded.demo_id,
  date = excluded.date,
  provider = excluded.provider,
  qty = excluded.qty,
  description = excluded.description,
  iva = excluded.iva,
  iibb = excluded.iibb,
  amount = excluded.amount,
  method = excluded.method,
  pay_cash = excluded.pay_cash,
  pay_transfer = excluded.pay_transfer,
  pay_peya = excluded.pay_peya;

-- Sobrante mensual demo
insert into public.monthly_carryovers (demo_id, month, cash, transfer, peya)
values
  ('demo', '2026-03', 15000, 9000, 0),
  ('patagonia', '2026-03', 8000, 5000, 0),
  ('palihue', '2026-03', 9000, 4500, 0)
on conflict (demo_id, month) do update set
  cash = excluded.cash,
  transfer = excluded.transfer,
  peya = excluded.peya;

-- Historial sobrante demo
insert into public.monthly_carryover_history (demo_id, id, month, cash, transfer, peya)
values
  ('demo', 'demo_carry_hist_001', '2026-03', 12000, 7000, 0),
  ('demo', 'demo_carry_hist_002', '2026-03', 15000, 9000, 0),
  ('patagonia', 'demo_pat_carry_hist_001', '2026-03', 8000, 5000, 0),
  ('palihue', 'demo_pali_carry_hist_001', '2026-03', 9000, 4500, 0)
on conflict (id) do update set
  demo_id = excluded.demo_id,
  month = excluded.month,
  cash = excluded.cash,
  transfer = excluded.transfer,
  peya = excluded.peya;

-- Sin PedidosYa / PeYa: no se cargan liquidaciones.
