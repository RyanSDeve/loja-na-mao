# Loja na Mao

App demo de catalogo, carrinho e pedidos para pequenos comercios, criado com Flutter e Supabase.

> Projeto de portfolio com uma vitrine demonstrativa de doceria premium: o cliente escolhe produtos, monta o pedido, envia pelo WhatsApp e o pedido fica registrado no backend.

## Links

- Demo web: em breve
- Repositorio: https://github.com/RyanSDeve/loja-na-mao
- Stack: Flutter, Dart, Supabase, PostgreSQL, WhatsApp

## Problema

Muitos pequenos comercios vendem pelo WhatsApp, mas recebem pedidos desorganizados, sem padrao e sem historico centralizado. Isso atrasa o atendimento e dificulta acompanhar pedidos.

## Solucao

O Loja na Mao e uma base white-label para negocios locais. Nesta demo, ele aparece como **Doce Encanto**, uma doceria que vende caixas de brigadeiros, kits presenteaveis e tortas premium.

- catalogo de produtos com busca e categorias;
- carrinho com resumo do pedido;
- checkout com dados do cliente;
- envio do pedido formatado para WhatsApp;
- registro do pedido no Supabase;
- painel simples de pedidos recentes.

## Resultado esperado para o cliente

- pedidos mais organizados;
- atendimento mais rapido no WhatsApp;
- vitrine mais profissional;
- menos perda de informacao;
- base pronta para evoluir com login, estoque, fotos e pagamento.

## Screenshots

Adicione os prints finais nesta pasta:

```text
assets/screenshots/
```

Sugestao de prints:

| Tela | Arquivo |
| --- | --- |
| Vitrine inicial | `assets/screenshots/01-vitrine.png` |
| Busca/filtros | `assets/screenshots/02-busca-filtros.png` |
| Checkout | `assets/screenshots/03-checkout.png` |
| Painel de pedidos | `assets/screenshots/04-painel-pedidos.png` |

## Visual da demo

O asset principal da vitrine esta em:

```text
assets/images/storefront-hero.png
```

Ele foi criado para dar contexto comercial ao app: produto local, embalagem presenteavel, checkout no celular e sensacao de pedido pronto para WhatsApp.

![Cena comercial da demo Loja na Mao](assets/images/storefront-hero.png)

## Funcionalidades

- Modo demo sem Supabase, usando dados locais.
- Modo conectado ao Supabase via `--dart-define`.
- Tabelas para lojas, produtos, pedidos e itens do pedido.
- Row Level Security habilitado.
- Politicas para leitura publica do catalogo e criacao de pedidos.
- Layout responsivo para mobile e web.

## Backend Supabase

O schema inicial esta em:

```text
supabase/schema.sql
```

Se voce ja rodou uma versao antiga da demo e quer limpar os dados antigos, use:

```text
supabase/reset_demo_data.sql
```

Tabelas principais:

- `stores`: dados da loja;
- `products`: catalogo;
- `orders`: pedidos;
- `order_items`: itens do pedido.

## Como rodar

Instale as dependencias:

```bash
flutter pub get
```

Rode em modo demo:

```bash
flutter run -d chrome
```

Rode conectado ao Supabase:

```bash
flutter run -d chrome --dart-define=SUPABASE_URL=SUA_URL --dart-define=SUPABASE_ANON_KEY=SUA_ANON_KEY
```

Gere build web:

```bash
flutter build web --release --dart-define=SUPABASE_URL=SUA_URL --dart-define=SUPABASE_ANON_KEY=SUA_ANON_KEY
```

O build fica em:

```text
build/web
```

## Como apresentar para clientes

Pitch curto:

> Desenvolvi uma demo de app para pequenos comercios venderem pelo WhatsApp com catalogo, carrinho e pedidos salvos no Supabase. A mesma estrutura pode ser adaptada para restaurantes, lojas, docerias, servicos locais e pequenos negocios.

## Proximas evolucoes

- Login do lojista com Supabase Auth.
- Cadastro e edicao de produtos pelo app.
- Upload de fotos com Supabase Storage.
- Status do pedido em tempo real.
- Dashboard de vendas.
- Tema personalizavel por loja.

## Documentacao do portfolio

- [Passo a passo de publicacao](docs/passo-a-passo-publicacao.md)
- [Checklist de portfolio](docs/checklist-portfolio.md)
- [Roteiro de video](docs/roteiro-video.md)
- [Texto para 99freelas](docs/texto-99freelas.md)
