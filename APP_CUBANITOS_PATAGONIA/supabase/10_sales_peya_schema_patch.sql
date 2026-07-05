alter table public.sales
add column if not exists peya numeric not null default 0;

update public.sales
set peya = total
where channel = 'pedidosya'
  and coalesce(peya, 0) = 0
  and coalesce(cash, 0) = 0
  and coalesce(transfer, 0) = 0;
