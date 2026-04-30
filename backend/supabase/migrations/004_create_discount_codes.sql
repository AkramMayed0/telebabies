create table if not exists public.discount_codes (
  id          bigserial primary key,
  code        text not null unique,                        -- e.g. SUMMER20
  type        text not null check (type in ('percent', 'fixed')),
  value       integer not null check (
                value > 0
                and (type = 'fixed' or value <= 100)       -- percent cap
              ),
  min_order   integer not null default 0,                  -- minimum subtotal (YER)
  max_uses    integer check (max_uses is null or max_uses > 0),  -- null = unlimited
  uses        integer not null default 0 check (uses >= 0),
  active      boolean not null default true,
  expires_at  timestamptz,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create trigger discount_codes_updated_at
  before update on public.discount_codes
  for each row execute procedure public.set_updated_at();

alter table public.discount_codes enable row level security;

-- admins have full access
create policy "admin full access" on public.discount_codes
  for all using (
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  );

-- authenticated customers can read a code to validate it at checkout
create policy "customer read active" on public.discount_codes
  for select using (
    auth.uid() is not null
    and active = true
    and (expires_at is null or expires_at > now())
    and (max_uses is null or uses < max_uses)
  );
