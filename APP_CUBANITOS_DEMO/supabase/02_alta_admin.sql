-- =====================================================
-- ALTA DE ADMIN POR CARRO
-- =====================================================
-- 1) Primero crea el usuario en Supabase Auth (email + password).
-- 2) Cambia el email y el demo_id de abajo.
-- 3) Ejecuta este script.

-- Admin del carro/demo "demo".
insert into public.app_demo_admins (demo_id, user_id)
select 'demo', id
from auth.users
where email = 'admin-demo@demo.com'
on conflict (demo_id, user_id) do nothing;

-- Opcional: admin global para vos. Puede administrar todos los carros y crear admins.
-- Descomenta y cambia el email si queres usarlo.
-- insert into public.admins (user_id)
-- select id
-- from auth.users
-- where email = 'tu-email@demo.com'
-- on conflict (user_id) do nothing;
