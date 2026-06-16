# Plano de portfolio: Loja na Mao

## Objetivo

Criar um projeto demonstravel para provar que voce consegue entregar um app comercial pequeno, rapido e util usando Flutter, FlutterFlow como referencia de stack, e Supabase.

## Cliente ideal

Pequenos comercios que vendem pelo WhatsApp e ainda controlam pedidos manualmente:

- restaurantes pequenos;
- lojas de roupas;
- docerias;
- lojas de presentes;
- distribuidoras locais;
- prestadores com pacotes de servico.

## Dor que o projeto resolve

O cliente recebe pedidos baguncados pelo WhatsApp, perde informacao, demora para responder e nao tem uma vitrine organizada. O app transforma isso em um catalogo com carrinho, envio de pedido padronizado e registro no backend.

## Funcionalidades do MVP

- Tela inicial com identidade da loja.
- Busca e filtro de produtos por categoria.
- Carrinho com total.
- Checkout com nome, telefone, endereco e observacoes.
- Registro do pedido no Supabase.
- Envio do pedido formatado para WhatsApp.
- Painel simples de pedidos recentes.
- Modo demo sem backend para facilitar apresentacao.

## Supabase usado no projeto

- `stores`: dados da loja.
- `products`: catalogo de produtos.
- `orders`: pedidos recebidos.
- `order_items`: itens de cada pedido.
- RLS habilitado.
- Politicas publicas apenas para leitura de catalogo e criacao de pedidos.

## Como apresentar no 99freelas

Use esse projeto como prova de capacidade, nao como produto fechado. A mensagem principal:

> Desenvolvo apps mobile com Flutter/FlutterFlow e Supabase para negocios que precisam vender, organizar pedidos ou digitalizar processos. Este projeto mostra uma vitrine com carrinho, registro de pedidos no backend e integracao com WhatsApp, pronto para adaptar ao seu negocio.

## Como gravar um video curto

Roteiro de 60 a 90 segundos:

1. Mostrar a vitrine e explicar que o cliente consegue divulgar produtos.
2. Usar a busca e filtro para mostrar cuidado com UX.
3. Adicionar produtos no carrinho.
4. Preencher checkout.
5. Mostrar pedido indo para WhatsApp.
6. Abrir painel de pedidos.
7. Fechar dizendo que o backend foi feito com Supabase e pode evoluir para login, estoque, pagamento e notificacoes.

## Melhorias para a versao 2

- Login do lojista com Supabase Auth.
- Area admin protegida.
- Cadastro/edicao de produtos.
- Upload de imagens com Supabase Storage.
- Status em tempo real com Supabase Realtime.
- Relatorio simples de faturamento.
- Layout adaptado para web para mandar link de demonstracao.

## Pacotes que voce pode vender

### Pacote inicial

Catalogo simples com WhatsApp, ate 20 produtos e identidade basica.

### Pacote profissional

Catalogo com painel de pedidos, categorias, busca, Supabase e ajustes de layout.

### Pacote completo

App com login, painel administrativo, upload de imagens, estoque e relatorios.
