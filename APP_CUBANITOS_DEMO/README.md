# Plantilla App de Carrito Multi-Carro

Esta carpeta sirve para tener una sola app demo conectada a un solo proyecto Supabase, pero con varias "nubes" separadas por codigo de acceso.

## Como funciona

1. La persona entra a la app.
2. Escribe el codigo del carro, por ejemplo `DEMO2026` o `PATAGONIA2026`.
3. La app guarda ese carro como activo y recarga.
4. Productos, ventas, gastos, caja e historiales se filtran por `demo_id`.

## Modo recomendado: un link por carro

Para publicar un link tipo `app-palihue.com`, deja ese link fijo a Palihue en `config.js`:

```js
DEFAULT_DEMO_ID: "palihue",
DEFAULT_DEMO_CODE: "PALIHUE2026",
LOCKED_DEMO_MODE: true,
SHOW_ADMIN_EMAIL: false,
ADMIN_EMAIL: "admin-palihue@demo.com",
```

Con eso, el jefe entra directo a la app de Palihue y solo escribe su codigo admin, por ejemplo `1234`.

Para otro link, por ejemplo `app-gaseosas.com`, usas el mismo Supabase pero cambias:

```js
DEFAULT_DEMO_ID: "gaseosas",
DEFAULT_DEMO_CODE: "GASEOSAS2026",
LOCKED_DEMO_MODE: true,
SHOW_ADMIN_EMAIL: false,
ADMIN_EMAIL: "admin-gaseosas@demo.com",
```

## Agregar un carro nuevo

En Supabase, crear una fila en:

- `app_demos`: datos visibles de la app, como nombre, pie y logo.
- `app_demo_access_codes`: codigo que abre ese carro.

Ejemplo:

```sql
insert into public.app_demos (id, name, app_name, footer_text, logo_url)
values ('centro', 'Cubanitos Centro', 'Cubanitos Centro', 'Cubanitos Centro - App de Caja', 'logo.png');

insert into public.app_demo_access_codes (code, demo_id)
values ('CENTRO2026', 'centro');
```

Despues cargá productos para ese `demo_id` en `products`.

## Agregar jefes/admins por carro

1. En Supabase, crea el usuario en `Authentication > Users`.
2. Ejecuta un alta en `app_demo_admins`:

```sql
insert into public.app_demo_admins (demo_id, user_id)
select 'centro', id
from auth.users
where email = 'jefe-centro@demo.com'
on conflict (demo_id, user_id) do nothing;
```

Ese usuario solo queda como admin del carro `centro`. Puede editar productos, ventas, gastos y caja de ese carro, pero no de los otros.

## Archivos importantes

- `config.js`: configuracion base, Supabase y demos locales de respaldo.
- `supabase/01_base_cliente_nuevo.sql`: crea la base multi-carro.
- `supabase/02_alta_admin.sql`: alta del usuario admin.
- `supabase/03_seed_demo.sql`: datos de ejemplo para `DEMO2026` y `PATAGONIA2026`.
- `supabase/04_migrar_base_vieja_a_multi_carro.sql`: convierte una base vieja a multi-carro sin borrar datos.
- `supabase/05_secciones_productos.sql`: agrega secciones configurables para organizar los productos de Cobrar.

## Importante

Esta version separa los datos en la app por `demo_id`. Para demos comerciales alcanza bien. Si algun dia guardas datos sensibles de clientes reales, conviene endurecer RLS con autenticacion por usuario/carro.
