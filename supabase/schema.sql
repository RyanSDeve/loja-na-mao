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

create policy "Public stores are readable"
  on public.stores for select
  using (true);

create policy "Public products are readable"
  on public.products for select
  using (is_available = true);

create policy "Anyone can create orders"
  on public.orders for insert
  with check (true);

create policy "Anyone can create order items"
  on public.order_items for insert
  with check (true);

insert into public.stores (name, slug, whatsapp, headline, delivery_minutes, minimum_order)
values (
  'Loja na Mao Demo',
  'loja-demo',
  '5599999999999',
  'Catalogo rapido, pedidos organizados e venda pelo WhatsApp.',
  45,
  25
)
on conflict (slug) do nothing;

insert into public.products (store_id, name, description, category, price, image_url)
select s.id, p.name, p.description, p.category, p.price, p.image_url
from public.stores s
cross join (
  values
    ('Combo Executivo', 'Produto campeao para almoco rapido com entrega local.', 'Mais vendidos', 34.90, null),
    ('Kit Presente', 'Opcao pronta para datas comemorativas e pedidos de ultima hora.', 'Kits', 79.90, null),
    ('Produto Premium', 'Item de maior margem para destacar a vitrine da loja.', 'Premium', 129.90, null),
    ('Oferta da Semana', 'Produto promocional para aumentar conversao.', 'Promocoes', 24.90, null)
) as p(name, description, category, price, image_url)
where s.slug = 'loja-demo'
on conflict do nothing;
