-- Basketly · Module 4: addresses and orders.
-- SQL Editor -> New query -> paste all -> Run. Safe to run twice.

-- One saved delivery address per person.
create table if not exists public.addresses (
  user_id    uuid primary key default auth.uid() references auth.users (id) on delete cascade,
  full_name  text not null,
  phone      text not null,
  line       text not null,
  city       text not null,
  updated_at timestamptz not null default now()
);

alter table public.addresses enable row level security;

drop policy if exists "own address" on public.addresses;
create policy "own address" on public.addresses
  for all to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Order numbers like BK-20001, BK-20002 ...
create sequence if not exists public.order_number_seq start 20001;

create table if not exists public.orders (
  id             uuid primary key default gen_random_uuid(),
  number         text not null unique
                   default ('BK-' || nextval('public.order_number_seq')::text),
  user_id        uuid not null references auth.users (id) on delete cascade,
  status         text not null default 'placed'
                   check (status in ('placed', 'packed', 'on_the_way', 'delivered', 'cancelled')),
  payment_method text not null check (payment_method in ('cod', 'demo_card')),
  subtotal       int  not null,
  discount       int  not null default 0,
  delivery_fee   int  not null default 0,
  total          int  not null,
  promo_code     text,
  address        jsonb not null,
  slot_start     timestamptz not null,
  slot_label     text not null,
  created_at     timestamptz not null default now()
);

create table if not exists public.order_items (
  id         bigint generated always as identity primary key,
  order_id   uuid not null references public.orders (id) on delete cascade,
  product_id uuid not null references public.products (id),
  name       text not null,     -- copied, so old orders still read right
  price      int  not null,     -- the price at the time of the order
  quantity   int  not null check (quantity between 1 and 20),
  size       text,
  colour     text,
  line_total int  not null
);

-- People can READ their own orders. Nobody can write orders from the app:
-- only the place-order Edge Function can, after checking every price.
alter table public.orders      enable row level security;
alter table public.order_items enable row level security;

drop policy if exists "read own orders" on public.orders;
create policy "read own orders" on public.orders
  for select to authenticated using (auth.uid() = user_id);

drop policy if exists "read own order items" on public.order_items;
create policy "read own order items" on public.order_items
  for select to authenticated
  using (exists (select 1 from public.orders o where o.id = order_id and o.user_id = auth.uid()));
