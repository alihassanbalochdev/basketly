-- Basketly · Module 6b: department illustrations from Supabase Storage.
-- Run after module6.sql (it uses the same 'products' bucket). Safe to run twice.

alter table public.departments add column if not exists image_url text;

update public.departments as d
set image_url = v.file
from (values
  ('groceries',   'dept-groceries.png'),
  ('fashion',     'dept-fashion.png'),
  ('electronics', 'dept-electronics.png'),
  ('home',        'dept-home.png')
) as v(slug, file)
where d.slug = v.slug;

select slug, image_url from public.departments order by position;
