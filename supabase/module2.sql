-- Basketly · Module 2: sizes, colours and popularity.
-- SQL Editor -> New query -> paste all -> Run. Safe to run twice.

alter table public.products add column if not exists sizes          text[] not null default '{}';
alter table public.products add column if not exists sold_out_sizes text[] not null default '{}';
alter table public.products add column if not exists colours        jsonb  not null default '[]';
alter table public.products add column if not exists popularity     int    not null default 0;

update public.products set
  sizes = '{S,M,L,XL,XXL}', sold_out_sizes = '{XXL}',
  colours = '[{"name":"Sand","hex":"#D8C29A"},{"name":"White","hex":"#FFFFFF"},{"name":"Olive","hex":"#6B7A3A"},{"name":"Black","hex":"#221326"}]',
  popularity = 95
where name = 'Linen kurta';

update public.products set
  sizes = '{XS,S,M,L,XL}',
  colours = '[{"name":"Rose","hex":"#C25B7A"},{"name":"Mint","hex":"#A9D6C2"}]',
  popularity = 88
where name = 'Lawn summer dress';

update public.products set
  sizes = '{40,41,42,43,44,45}', sold_out_sizes = '{40}',
  colours = '[{"name":"White","hex":"#FFFFFF"},{"name":"Black","hex":"#221326"}]',
  popularity = 81
where name = 'Everyday sneakers';

update public.products set
  colours = '[{"name":"Olive","hex":"#6B7A3A"},{"name":"Navy","hex":"#24315A"}]',
  popularity = 40
where name = 'Cotton cap';

update public.products set popularity = 99 where name = 'Wireless Earbuds Pro';
update public.products set popularity = 90 where name = 'Fresh milk, 1 L';
update public.products set popularity = 85 where name = 'Eggs, 12';
update public.products set popularity = 70 where name = 'Basmati rice, 5 kg';
update public.products set popularity = 65 where name = 'Smart watch';
update public.products set popularity = 55 where name = 'Power bank, 20,000 mAh';
update public.products set popularity = 50 where name = 'Electric kettle, 1.7 L';
