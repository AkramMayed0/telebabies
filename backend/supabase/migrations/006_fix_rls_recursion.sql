-- Replace all policies that query public.profiles inside a profiles policy
-- with a SECURITY DEFINER function to break the infinite recursion.

create or replace function public.is_admin()
returns boolean language sql security definer stable as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'admin'
  );
$$;

-- profiles
drop policy if exists "admin full access" on public.profiles;
create policy "admin full access" on public.profiles
  for all using (public.is_admin());

-- products
drop policy if exists "admin write" on public.products;
create policy "admin write" on public.products
  for all using (public.is_admin());

-- orders
drop policy if exists "admin all orders" on public.orders;
create policy "admin all orders" on public.orders
  for all using (public.is_admin());

-- order_items (nested check)
drop policy if exists "own order items" on public.order_items;
create policy "own order items" on public.order_items
  for all using (
    exists (
      select 1 from public.orders o
      where o.id = order_items.order_id
        and (o.user_id = auth.uid() or public.is_admin())
    )
  );

-- discount_codes
drop policy if exists "admin full access" on public.discount_codes;
create policy "admin full access" on public.discount_codes
  for all using (public.is_admin());
