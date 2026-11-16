-- Basketly · Module 6: product photos in Supabase Storage.
-- SQL Editor -> New query -> paste all -> Run. Safe to run twice.

-- A public bucket: anyone can VIEW the photos (the shop is public),
-- but only you, from the dashboard, can upload or delete them.
insert into storage.buckets (id, name, public)
values ('products', 'products', true)
on conflict (id) do update set public = true;

-- image_url holds just the file name. The app turns it into the full
-- public link, so the project URL is never written into the database.
update public.products as p
set image_url = v.file
from (values
  ('Fresh milk, 1 L',        'fresh-milk.png'),
  ('Eggs, 12',               'eggs.png'),
  ('Basmati rice, 5 kg',     'basmati-rice.png'),
  ('Bananas, dozen',         'bananas.png'),
  ('Linen kurta',            'linen-kurta.png'),
  ('Lawn summer dress',      'lawn-dress.png'),
  ('Everyday sneakers',      'sneakers.png'),
  ('Cotton cap',             'cotton-cap.png'),
  ('Wireless Earbuds Pro',   'earbuds.png'),
  ('Power bank, 20,000 mAh', 'power-bank.png'),
  ('Smart watch',            'smart-watch.png'),
  ('Electric kettle, 1.7 L', 'kettle.png'),
  ('Cotton bedsheet set',    'bedsheet.png'),
  ('Scented candle',         'candle.png')
) as v(name, file)
where p.name = v.name;

-- Quick check: every product should show a file name.
select name, image_url from public.products order by department_slug, name;
