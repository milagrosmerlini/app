// Configuracion simple por cliente.
// Solo cambia estos valores y deja el resto igual.
window.APP_CONFIG = {
  APP_NAME: "Cubanitos Demo",
  FOOTER_TEXT: "Cubanitos Demo - App de ejemplo",
  LOGO_URL: "logo.png",

  // Importante: usar un prefijo distinto por cliente para no mezclar datos locales.
  STORAGE_PREFIX: "cubanitos_demo",

  // Demo/carro inicial. Cada codigo abre una nube distinta dentro del mismo Supabase.
  DEFAULT_DEMO_ID: "demo",
  DEFAULT_DEMO_CODE: "DEMO2026",
  // true = el link queda fijo en DEFAULT_DEMO_CODE y el jefe solo pone su clave admin.
  // false = app general donde se puede cambiar de carro escribiendo el codigo del carro.
  LOCKED_DEMO_MODE: true,
  SHOW_ADMIN_EMAIL: false,
  DEMOS: [
    {
      id: "demo",
      code: "DEMO2026",
      name: "Cubanitos Demo",
      app_name: "Cubanitos Demo",
      footer_text: "Cubanitos Demo - App de ejemplo",
      logo_url: "logo.png",
    },
    {
      id: "patagonia",
      code: "PATAGONIA2026",
      name: "Cubanitos Patagonia",
      app_name: "Cubanitos Patagonia",
      footer_text: "Cubanitos Patagonia - App de Caja",
      logo_url: "logo.png",
    },
    {
      id: "palihue",
      code: "PALIHUE2026",
      name: "Cubanitos Palihue",
      app_name: "Cubanitos Palihue",
      footer_text: "Cubanitos Palihue - App de Caja",
      logo_url: "logo.png",
    },
  ],

  // Email sugerido en el login admin. Podes crear varios admins por carro en Supabase.
  ADMIN_EMAIL: "admin-demo@demo.com",

  // Supabase del cliente.
  // Dejar en false mientras el proyecto demo de Supabase este pausado.
  SUPABASE_ENABLED: true,
  SUPABASE_URL: "https://hgjqjyfgvpyajxlibpmm.supabase.co",
  SUPABASE_ANON_KEY: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhnanFqeWZndnB5YWp4bGlicG1tIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQ2ODk0MDcsImV4cCI6MjEwMDI2NTQwN30.DgysJ1VKNABI_GGKwOjlG8Z0D4rLeS6TjJgwgui7HnM",

  // Productos por defecto (si la tabla products esta vacia).
  DEFAULT_PRODUCTS: [
    { sku: "cubanito_comun", name: "Cubanito comun", unit: "Unidad", prices: { presencial: 1000, pedidosya: 1000 } },
    { sku: "cubanito_negro", name: "Cubanito choco negro", unit: "Unidad", prices: { presencial: 1300, pedidosya: 1300 } },
    { sku: "cubanito_blanco", name: "Cubanito choco blanco", unit: "Unidad", prices: { presencial: 1300, pedidosya: 1300 } },
    { sku: "garrapinadas", name: "Garrapinadas", unit: "Bolsa", prices: { presencial: 1200, pedidosya: 1200 } },
  ],
};
