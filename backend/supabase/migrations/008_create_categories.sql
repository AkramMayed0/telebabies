create table if not exists public.categories (
  id        bigserial primary key,
  type      text not null check (type in ('age_group', 'gender', 'clothing_type')),
  name      text not null,
  is_active boolean not null default true,
  unique (type, name)
);

alter table public.categories enable row level security;

create policy "public read categories" on public.categories
  for select using (true);

create policy "admin write categories" on public.categories
  for all using (
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  );

-- seed with values that match existing product filters
insert into public.categories (type, name) values
  ('gender',        'girls'),
  ('gender',        'boys'),
  ('gender',        'unisex'),
  ('age_group',     '0-2'),
  ('age_group',     '2-4'),
  ('age_group',     '4-6'),
  ('age_group',     '6-10'),
  ('clothing_type', 'dress'),
  ('clothing_type', 'tshirt'),
  ('clothing_type', 'jacket'),
  ('clothing_type', 'pajama'),
  ('clothing_type', 'shoes'),
  ('clothing_type', 'overall'),
  ('clothing_type', 'hat')
on conflict (type, name) do nothing;
