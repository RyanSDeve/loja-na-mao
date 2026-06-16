-- Opcional: use este arquivo apenas se quiser limpar os dados antigos da demo
-- e carregar novamente a vitrine da doceria.

delete from public.order_items
where order_id in (
  select id
  from public.orders
  where store_id in (select id from public.stores where slug = 'loja-demo')
);

delete from public.orders
where store_id in (select id from public.stores where slug = 'loja-demo');

delete from public.products
where store_id in (select id from public.stores where slug = 'loja-demo');

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
select s.id, p.name, p.description, p.category, p.price, null
from public.stores s
cross join (
  values
    ('Caixa Brigadeiros Gourmet', 'Nove brigadeiros artesanais em embalagem pronta para presente.', 'Mais pedidos', 49.90),
    ('Kit Presente Especial', 'Seleção de doces finos com fita, tag e cartão para mensagem.', 'Presentes', 89.90),
    ('Torta Chocolate Belga', 'Torta premium para celebrações, com cobertura cremosa e crocante.', 'Premium', 139.90),
    ('Combo Café da Tarde', 'Mini tortas e docinhos para reuniões pequenas ou entrega rápida.', 'Promoções', 64.90)
) as p(name, description, category, price)
where s.slug = 'loja-demo';
