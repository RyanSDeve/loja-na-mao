# Loja na Mao

Projeto de portfolio Flutter + Supabase pensado para captar clientes no 99freelas.

> Demo comercial: catalogo, carrinho, pedido no WhatsApp e backend Supabase para pequenos comercios.

## Proposta

Um aplicativo white-label para pequenos comercios venderem pelo celular:

- Vitrine de produtos com busca e filtros.
- Carrinho e resumo do pedido.
- Envio do pedido para WhatsApp.
- Registro do lead/pedido no Supabase.
- Painel simples para o lojista acompanhar pedidos recentes.
- Estrutura pronta para evoluir para login, pagamento, estoque e notificacoes.

## Por que esse projeto ajuda no 99freelas

Ele mostra algo que o cliente entende rapido: mais pedidos, catalogo profissional e atendimento organizado. Tambem mostra sua stack real:

- Flutter/Dart para app mobile.
- Supabase para banco, auth e backend.
- PostgreSQL com tabelas e politicas.
- Integração com WhatsApp.
- Arquitetura simples, facil de explicar e evoluir.

## Como rodar

No terminal local, rode:

```bash
flutter pub get
flutter run
```

Para rodar no navegador:

```bash
flutter run -d chrome
```

Para conectar no Supabase:

```bash
flutter run --dart-define=SUPABASE_URL=SUA_URL --dart-define=SUPABASE_ANON_KEY=SUA_ANON_KEY
```

Se nao passar as variaveis, o app roda em modo demonstracao com dados locais.

## Backend Supabase

O SQL inicial esta em `supabase/schema.sql`.

Fluxo sugerido:

1. Criar um projeto no Supabase.
2. Abrir SQL Editor.
3. Rodar o conteudo de `supabase/schema.sql`.
4. Inserir produtos de exemplo.
5. Rodar o app com `--dart-define`.

## Pitch para colocar no portfolio

> App de catalogo e pedidos para pequenos comercios, feito em Flutter com backend Supabase. O cliente consegue divulgar produtos, receber pedidos pelo WhatsApp e consultar os pedidos em um painel simples. Projeto pensado para negocios locais que precisam vender online sem contratar um ecommerce completo.

## Proximas evolucoes boas para portfolio

- Login do lojista com Supabase Auth.
- Upload de fotos no Supabase Storage.
- Controle de estoque.
- Status do pedido em tempo real.
- Area administrativa completa.
- Deploy web para demonstracao publica.

## Guia passo a passo

Veja o guia completo em `docs/passo-a-passo-publicacao.md`.
