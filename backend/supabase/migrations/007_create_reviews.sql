create table if not exists public.reviews (
  id          bigserial primary key,
  user_id     uuid not null references public.profiles(id) on delete cascade,
  product_id  text not null references public.products(id) on delete cascade,
  rating      integer not null check (rating between 1 and 5),
  comment     text,
  created_at  timestamptz not null default now(),
  unique (user_id, product_id)
);

alter table public.reviews enable row level security;

create policy "public read reviews" on public.reviews
  for select using (true);

create policy "insert own review" on public.reviews
  for insert with check (auth.uid() = user_id);

create policy "delete own or admin" on public.reviews
  for delete using (
    auth.uid() = user_id
    or exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  );
