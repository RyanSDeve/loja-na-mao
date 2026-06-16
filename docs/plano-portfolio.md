# Plano de portfólio: Loja na Mão

## Objetivo

Criar um projeto demonstrável para provar que você consegue entregar um app comercial pequeno, rápido e útil usando Flutter, FlutterFlow como referência de stack, e Supabase.

## Cliente ideal

Pequenos comércios que vendem pelo WhatsApp e ainda controlam pedidos manualmente:

- restaurantes pequenos;
- lojas de roupas;
- docerias;
- lojas de presentes;
- distribuidoras locais;
- prestadores com pacotes de serviço.

## Dor que o projeto resolve

O cliente recebe pedidos bagunçados pelo WhatsApp, perde informação, demora para responder e não tem uma vitrine organizada. O app transforma isso em um catálogo com carrinho, envio de pedido padronizado e registro para acompanhamento.

## Funcionalidades do MVP

- Tela inicial com identidade da loja.
- Busca e filtro de produtos por categoria.
- Carrinho com total.
- Checkout com nome, telefone, endereço e observações.
- Registro do pedido no Supabase.
- Envio do pedido formatado para WhatsApp.
- Painel simples de pedidos recentes.
- Modo demo sem backend para facilitar apresentação.

## Supabase usado no projeto

- `stores`: dados da loja.
- `products`: catálogo de produtos.
- `orders`: pedidos recebidos.
- `order_items`: itens de cada pedido.
- RLS habilitado.
- Políticas públicas apenas para leitura de catálogo e criação de pedidos.

## Como apresentar no 99freelas

Use esse projeto como prova de capacidade, não como produto fechado. A mensagem principal:

> Desenvolvo apps mobile com Flutter/FlutterFlow e Supabase para negócios que precisam vender, organizar pedidos ou digitalizar processos. Este projeto mostra uma vitrine com carrinho, registro de pedidos e integração com WhatsApp, pronto para adaptar ao seu negócio.

## Como gravar um vídeo curto

Roteiro de 60 a 90 segundos:

1. Mostrar a vitrine e explicar que o cliente consegue divulgar produtos.
2. Usar a busca e filtro para mostrar cuidado com UX.
3. Adicionar produtos no carrinho.
4. Preencher checkout.
5. Mostrar pedido indo para WhatsApp.
6. Abrir painel de pedidos.
7. Fechar dizendo que o app registra pedidos e pode evoluir para login, estoque, pagamento e notificações.

## Melhorias para a versão 2

- Login do lojista com Supabase Auth.
- Area admin protegida.
- Cadastro/edição de produtos.
- Upload de imagens com Supabase Storage.
- Status em tempo real com Supabase Realtime.
- Relatorio simples de faturamento.
- Layout adaptado para web para mandar link de demonstração.

## Pacotes que você pode vender

### Pacote inicial

Catálogo simples com WhatsApp, até 20 produtos e identidade básica.

### Pacote profissional

Catálogo com painel de pedidos, categorias, busca, Supabase e ajustes de layout.

### Pacote completo

App com login, painel administrativo, upload de imagens, estoque e relatorios.
