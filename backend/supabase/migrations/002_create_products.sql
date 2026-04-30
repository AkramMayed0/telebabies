create table if not exists public.products (
  id          text primary key,
  name_ar     text not null,
  name_en     text not null,
  cat         text not null,
  age         text not null,
  type        text not null,
  price       integer not null,
  old_price   integer,
  img         text,
  color       text not null default '#FFD23F',
  tag_ar      text,
  tag_en      text,
  desc_ar     text not null default '',
  desc_en     text not null default '',
  sizes       text[] not null default '{}',
  stock       integer not null default 0,
  active      boolean not null default true,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create trigger products_updated_at
  before update on public.products
  for each row execute procedure public.set_updated_at();

alter table public.products enable row level security;

-- anyone can read active products
create policy "public read" on public.products
  for select using (active = true);

-- only admins can insert / update / delete
create policy "admin write" on public.products
  for all using (
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  );

-- seed data
insert into public.products
  (id, name_ar, name_en, cat, age, type, price, old_price, img, color, tag_ar, tag_en, desc_ar, desc_en, sizes, stock)
values
  ('p1','فستان زهري بالكشكش','Pink Ruffle Dress','girls','2-4','dress',8500,12000,
   'https://images.unsplash.com/photo-1518831959646-742c3a14ebf7?w=600&auto=format&fit=crop&q=80',
   '#FF8FB1','جديد','NEW',
   'فستان قطني ناعم بكشكش زهري لطيف، مثالي للمناسبات والإطلالات اليومية.',
   'Soft cotton dress with playful pink ruffles. Perfect for parties and everyday wear.',
   array['18M','2T','3T','4T'], 14),

  ('p2','بدلة دنيم زرقاء','Blue Denim Overall','boys','0-2','overall',11000,null,
   'https://images.unsplash.com/photo-1622290291468-a28f7a7dc6a8?w=600&auto=format&fit=crop&q=80',
   '#A6C8FF','مميز','POPULAR',
   'بدلة دنيم متينة وأنيقة بأحزمة قابلة للتعديل.',
   'Sturdy, stylish denim overalls with adjustable straps.',
   array['6M','12M','18M','24M'], 8),

  ('p3','تيشيرت قوس قزح','Rainbow Tee','unisex','4-6','tshirt',4500,null,
   'https://images.unsplash.com/photo-1503944583220-79d8926ad5e2?w=600&auto=format&fit=crop&q=80',
   '#FFD23F',null,null,
   'تيشيرت قطني خفيف مع طبعة قوس قزح بألوان مرحة.',
   'Light cotton tee with a happy rainbow print.',
   array['4T','5T','6T'], 24),

  ('p4','بيجامة نجوم خضراء','Mint Star Pajama','unisex','2-4','pajama',7000,null,
   'https://images.unsplash.com/photo-1622290291165-d341f1938345?w=600&auto=format&fit=crop&q=80',
   '#BFF5E3',null,null,
   'بيجامة دافئة بطبعة نجوم على قماش قطني ناعم.',
   'Cozy pajamas with a starry print on soft cotton.',
   array['2T','3T','4T'], 17),

  ('p5','حذاء صفير صغير','Little Sneakers','boys','0-2','shoes',9500,null,
   'https://images.unsplash.com/photo-1607522370275-f14206abe5d3?w=600&auto=format&fit=crop&q=80',
   '#FFE2A8',null,null,
   'أحذية رياضية مرنة وخفيفة لخطواته الأولى.',
   'Flexible, lightweight sneakers for first steps.',
   array['18','19','20','21'], 6),

  ('p6','فستان توتو أصفر','Yellow Tutu Dress','girls','4-6','dress',13500,null,
   'https://images.unsplash.com/photo-1519278409-1f56fdda7fe5?w=600&auto=format&fit=crop&q=80',
   '#FFE066','الأكثر مبيعاً','BESTSELLER',
   'فستان توتو منفوش بطبقات لإطلالة الأميرة الصغيرة.',
   'Layered tutu dress for your little princess.',
   array['4T','5T','6T'], 5),

  ('p7','قبعة دب لطيفة','Bear Beanie','unisex','0-2','hat',3000,null,
   'https://images.unsplash.com/photo-1519689680058-324335c77eba?w=600&auto=format&fit=crop&q=80',
   '#D4B896',null,null,
   'قبعة محبوكة على شكل دب صغير بأذنين.',
   'Knit beanie shaped like a tiny bear with ears.',
   array['S','M','L'], 22),

  ('p8','جاكيت وردي شتوي','Pink Winter Jacket','girls','4-6','jacket',18000,null,
   'https://images.unsplash.com/photo-1503919005314-30d93d07d823?w=600&auto=format&fit=crop&q=80',
   '#FF4D8D',null,null,
   'جاكيت دافئ ومبطن لأيام الشتاء الباردة.',
   'Warm, padded jacket for chilly winter days.',
   array['4T','5T','6T'], 11)

on conflict (id) do nothing;
