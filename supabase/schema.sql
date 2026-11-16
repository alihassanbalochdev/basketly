-- Basketly · Module 1
-- Supabase dashboard -> SQL Editor -> New query -> paste all -> Run.

create table if not exists public.departments (
  slug        text primary key,
  name        text not null,
  item_count  int  not null default 0,
  tint        text not null,          -- tile colour, like '#E5EEDC'
  position    int  not null
);

create table if not exists public.products (
  id              uuid primary key default gen_random_uuid(),
  department_slug text not null references public.departments (slug),
  name            text not null,
  subtitle        text,
  price           int  not null check (price > 0),       -- whole rupees
  was_price       int  check (was_price is null or was_price > price),
  image_url       text,
  is_deal         boolean not null default false,
  is_staple       boolean not null default false,
  created_at      timestamptz not null default now()
);

-- The catalogue is public: anyone can read it, nobody can change it
-- from the app. (Baskets and orders get their own, private rules later.)
alter table public.departments enable row level security;
alter table public.products    enable row level security;

drop policy if exists "catalogue is public" on public.departments;
create policy "catalogue is public" on public.departments
  for select to anon, authenticated using (true);

drop policy if exists "catalogue is public" on public.products;
create policy "catalogue is public" on public.products
  for select to anon, authenticated using (true);

-- ---------- sample data ----------
insert into public.departments (slug, name, item_count, tint, position) values
  ('groceries',   'Groceries',      3240, '#E5EEDC', 1),
  ('fashion',     'Fashion',         248, '#F3E2E8', 2),
  ('electronics', 'Electronics',    1102, '#E2E6F1', 3),
  ('home',        'Home & living',   864, '#F4EADB', 4)
on conflict (slug) do nothing;

insert into public.products (department_slug, name, subtitle, price, was_price, is_deal, is_staple) values
  ('groceries',   'Fresh milk, 1 L',        'Full cream',           290,  null, false, true),
  ('groceries',   'Eggs, 12',               'Free range',           420,  null, false, true),
  ('groceries',   'Basmati rice, 5 kg',     'Extra long grain',    2450,  2700, false, true),
  ('groceries',   'Bananas, dozen',         'Fresh today',          220,  null, false, false),
  ('fashion',     'Linen kurta',            'Men, sand',           3290,  4100, false, false),
  ('fashion',     'Lawn summer dress',      'Women, rose',         4850,  null, false, false),
  ('fashion',     'Everyday sneakers',      'Unisex, sizes 40–45', 6499,  7999, false, false),
  ('fashion',     'Cotton cap',             'Unisex, olive',        990,  null, false, false),
  ('electronics', 'Wireless Earbuds Pro',   'Noise cancelling',    5499,  8999, true,  false),
  ('electronics', 'Power bank, 20,000 mAh', 'Fast charging',       4299,  null, false, false),
  ('electronics', 'Smart watch',            'Heart rate, GPS',     9999, 12499, false, false),
  ('home',        'Electric kettle, 1.7 L', 'Stainless steel',     3750,  null, false, false),
  ('home',        'Cotton bedsheet set',    'King size',           4200,  4900, false, false),
  ('home',        'Scented candle',         'Oud and amber',       1150,  null, false, false);
