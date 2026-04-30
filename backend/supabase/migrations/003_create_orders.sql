-- order status enum
create type order_status as enum (
  'pending',
  'confirmed',
  'preparing',
  'shipped',
  'delivered',
  'rejected'
);

-- sequence for readable order IDs (TB-0001, TB-0002 …)
create sequence if not exists order_seq start 1;

-- orders table
create table if not exists public.orders (
  id            text primary key default 'TB-' || to_char(nextval('order_seq'), 'FM0000'),
  user_id       uuid not null references public.profiles(id) on delete restrict,
  status        order_status not null default 'pending',

  -- delivery
  name          text not null,
  phone         text not null,
  city          text not null,
  address       text not null,

  -- payment
  payment       text not null check (payment in ('jaib', 'cremi', 'bank')),
  receipt_url   text,

  -- totals
  subtotal      integer not null,
  shipping      integer not null default 1500,
  discount      integer not null default 0,
  total         integer not null,

  -- promo
  promo_code    text,

  -- timestamps
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

-- order items
create table if not exists public.order_items (
  id          bigserial primary key,
  order_id    text not null references public.orders(id) on delete cascade,
  product_id  text not null references public.products(id) on delete restrict,
  size        text not null,
  qty         integer not null check (qty > 0),
  unit_price  integer not null
);

-- updated_at trigger
create trigger orders_updated_at
  before update on public.orders
  for each row execute procedure public.set_updated_at();

-- RLS
alter table public.orders      enable row level security;
alter table public.order_items enable row level security;

-- customers see only their own orders
create policy "own orders" on public.orders
  for all using (auth.uid() = user_id);

-- admins see all orders
create policy "admin all orders" on public.orders
  for all using (
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  );

-- order items follow order visibility
create policy "own order items" on public.order_items
  for all using (
    exists (
      select 1 from public.orders o
      where o.id = order_items.order_id
        and (o.user_id = auth.uid() or exists (
          select 1 from public.profiles p
          where p.id = auth.uid() and p.role = 'admin'
        ))
    )
  );
