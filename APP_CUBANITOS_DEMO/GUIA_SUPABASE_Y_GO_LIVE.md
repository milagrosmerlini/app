# Guia Simple: Supabase Multi-Carro + Go Live

Esta guia es para usar una sola demo generica con varias nubes internas, una por codigo de acceso.

## 1. Preparar Supabase

1. En Supabase crea o usa un proyecto para demos.
2. En `SQL Editor`, ejecuta:
   - `supabase/01_base_cliente_nuevo.sql`
   - `supabase/03_seed_demo.sql`
   - `supabase/05_secciones_productos.sql`
3. En `Auth > Users`, crea el usuario admin con email y contrasena.
4. En `supabase/02_alta_admin.sql`, cambia el email y el `demo_id` del carro, y ejecutalo.
5. Copia:
   - `Project URL`
   - `anon public key`
6. En `config.js`, completa:
   - `SUPABASE_ENABLED: true`
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
   - `ADMIN_EMAIL`

Si ese proyecto ya tenia la base vieja de la plantilla, ejecuta primero `supabase/04_migrar_base_vieja_a_multi_carro.sql`, despues `supabase/01_base_cliente_nuevo.sql`, `supabase/03_seed_demo.sql` y por ultimo `supabase/05_secciones_productos.sql`.

## 2. Codigos incluidos en la demo

El seed crea dos codigos:

- `DEMO2026`
- `PATAGONIA2026`

Cada codigo abre un `demo_id` distinto y por eso muestra productos, ventas, gastos y caja separados.

## 3. Agregar otro carro

Ejecuta algo asi en Supabase:

```sql
insert into public.app_demos (id, name, app_name, footer_text, logo_url)
values ('centro', 'Cubanitos Centro', 'Cubanitos Centro', 'Cubanitos Centro - App de Caja', 'logo.png');

insert into public.app_demo_access_codes (code, demo_id)
values ('CENTRO2026', 'centro');
```

Despues carga productos para ese carro:

```sql
insert into public.products (demo_id, sku, name, unit, price_presencial, price_pedidosya)
values
  ('centro', 'cubanito_comun', 'Cubanito comun', 'Unidad', 1000, 1300),
  ('centro', 'cubanito_negro', 'Cubanito choco negro', 'Unidad', 1300, 1900),
  ('centro', 'cubanito_blanco', 'Cubanito choco blanco', 'Unidad', 1300, 1900),
  ('centro', 'garrapinadas', 'Garrapinadas', 'Bolsa', 1200, 1600)
on conflict (demo_id, sku) do update set
  name = excluded.name,
  unit = excluded.unit,
  price_presencial = excluded.price_presencial,
  price_pedidosya = excluded.price_pedidosya;
```

## 4. Publicar

Publica una sola carpeta: `PLANTILLA_GENERICA`.

Todas las demos usan el mismo link. Lo que cambia es el codigo que se ingresa en la pantalla `Sesion`.

Tambien podes publicar un link por carro. Es el modo mas comodo para los jefes:

```js
DEFAULT_DEMO_ID: "palihue",
DEFAULT_DEMO_CODE: "PALIHUE2026",
LOCKED_DEMO_MODE: true,
SHOW_ADMIN_EMAIL: false,
ADMIN_EMAIL: "admin-palihue@demo.com",
```

En ese modo, el link ya sabe que es Palihue. El jefe solo escribe su codigo admin, por ejemplo `1234`.

## 5. Admins por carro

El codigo del carro sirve para elegir nube. Para editar, el jefe entra con:

- Email admin creado en `Authentication > Users`.
- Contrasena de ese usuario.

Para darle permiso a otro jefe sobre un carro:

```sql
insert into public.app_demo_admins (demo_id, user_id)
select 'patagonia', id
from auth.users
where email = 'jefe@demo.com'
on conflict (demo_id, user_id) do nothing;
```

Ese jefe solo puede administrar el carro indicado por `demo_id`. Si queres un usuario que administre todos los carros, agregalo a `public.admins`.

Si queres que todos los jefes usen el mismo codigo `1234`, crea cada usuario de Auth con password `1234`, pero asignalo solo al carro que corresponde en `app_demo_admins`.
