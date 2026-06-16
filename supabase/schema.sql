create extension if not exists "pgcrypto";

create table if not exists public.stores (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null unique,
  whatsapp text not null,
  headline text not null,
  delivery_minutes integer not null default 45,
  minimum_order numeric(10, 2) not null default 0,
  is_open boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  store_id uuid not null references public.stores(id) on delete cascade,
  name text not null,
  description text not null,
  category text not null,
  image_url text,
  price numeric(10, 2) not null check (price >= 0),
  is_available boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  store_id uuid not null references public.stores(id) on delete cascade,
  customer_name text not null,
  customer_phone text not null,
  address text not null,
  notes text,
  total numeric(10, 2) not null check (total >= 0),
  status text not null default 'new' check (status in ('new', 'confirmed', 'delivering', 'done', 'cancelled')),
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  product_id uuid not null references public.products(id),
  quantity integer not null check (quantity > 0),
  unit_price numeric(10, 2) not null check (unit_price >= 0),
  created_at timestamptz not null default now()
);

alter table public.stores enable row level security;
alter table public.products enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;

drop policy if exists "Public stores are readable" on public.stores;
drop policy if exists "Public products are readable" on public.products;
drop policy if exists "Demo catalog products are readable" on public.products;
drop policy if exists "Demo catalog products can be created" on public.products;
drop policy if exists "Demo catalog products can be updated" on public.products;
drop policy if exists "Demo catalog products can be deleted" on public.products;
drop policy if exists "Anyone can create orders" on public.orders;
drop policy if exists "Orders are readable for demo panel" on public.orders;
drop policy if exists "Anyone can create order items" on public.order_items;
drop policy if exists "Order items are readable for demo panel" on public.order_items;

create policy "Public stores are readable"
  on public.stores for select
  to anon, authenticated
  using (true);

create policy "Demo catalog products are readable"
  on public.products for select
  to anon, authenticated
  using (true);

create policy "Demo catalog products can be created"
  on public.products for insert
  to anon, authenticated
  with check (true);

create policy "Demo catalog products can be updated"
  on public.products for update
  to anon, authenticated
  using (true)
  with check (true);

create policy "Demo catalog products can be deleted"
  on public.products for delete
  to anon, authenticated
  using (true);

create policy "Anyone can create orders"
  on public.orders for insert
  to anon, authenticated
  with check (true);

create policy "Orders are readable for demo panel"
  on public.orders for select
  to anon, authenticated
  using (true);

create policy "Anyone can create order items"
  on public.order_items for insert
  to anon, authenticated
  with check (true);

create policy "Order items are readable for demo panel"
  on public.order_items for select
  to anon, authenticated
  using (true);

insert into public.stores (name, slug, whatsapp, headline, delivery_minutes, minimum_order)
values (
  'Doce Encanto',
  'loja-demo',
  '5599999999999',
  'Doces artesanais, kits presenteáveis e pedidos organizados para vender mais pelo WhatsApp.',
  45,
  25
)
on conflict (slug) do update set
  name = excluded.name,
  whatsapp = excluded.whatsapp,
  headline = excluded.headline,
  delivery_minutes = excluded.delivery_minutes,
  minimum_order = excluded.minimum_order,
  is_open = true;

insert into public.products (store_id, name, description, category, price, image_url)
select s.id, p.name, p.description, p.category, p.price, p.image_url
from public.stores s
cross join (
  values
    ('Caixa Brigadeiros Gourmet', 'Nove brigadeiros artesanais em embalagem pronta para presente.', 'Mais pedidos', 49.90, null),
    ('Kit Presente Especial', 'Seleção de doces finos com fita, tag e cartão para mensagem.', 'Presentes', 89.90, null),
    ('Torta Chocolate Belga', 'Torta premium para celebrações, com cobertura cremosa e crocante.', 'Premium', 139.90, null),
    ('Combo Café da Tarde', 'Mini tortas e docinhos para reuniões pequenas ou entrega rápida.', 'Promoções', 64.90, null)
) as p(name, description, category, price, image_url)
where s.slug = 'loja-demo'
and not exists (
  select 1
  from public.products existing
  where existing.store_id = s.id
    and existing.name = p.name
);
