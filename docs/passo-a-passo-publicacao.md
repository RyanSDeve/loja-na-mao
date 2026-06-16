# Passo a passo para publicar o portfólio

Este guia assume que o GitHub e o projeto Supabase ja foram criados.

## Estado atual

- GitHub: `https://github.com/RyanSDeve/loja-na-mao`
- Supabase: projeto `loja-na-mao-demo`
- App: Flutter web/mobile com modo demo e modo Supabase
- Próximo objetivo: gerar prova visual e publicar um link de demonstração

## 1. Validar o Supabase

No Supabase, abra o SQL Editor e rode o conteúdo de:

```text
supabase/schema.sql
```

Se aparecerem produtos antigos da primeira versão da demo, rode também:

```text
supabase/reset_demo_data.sql
```

Esse reset limpa os pedidos/produtos da loja demo e carrega a vitrine atual da doceria.

Depois, confira no Table Editor:

- `stores`
- `products`
- `orders`
- `order_items`

## 2. Rodar conectado ao Supabase

No terminal do projeto:

```bash
flutter pub get
flutter run -d chrome --dart-define=SUPABASE_URL=SUA_PROJECT_URL --dart-define=SUPABASE_ANON_KEY=SUA_ANON_KEY
```

Teste:

1. Adicionar produto ao carrinho.
2. Abrir checkout.
3. Preencher dados ficticios.
4. Registrar pedido.
5. Conferir se abriu o WhatsApp.
6. Conferir se `orders` recebeu o pedido.
7. Conferir se `order_items` recebeu os itens.

## 3. Tirar prints

Salve os prints em:

```text
assets/screenshots/
```

Use estes nomes:

```text
01-vitrine.png
02-busca-filtros.png
03-checkout.png
04-painel-pedidos.png
```

Depois atualize o README para exibir as imagens.

## 4. Gravar vídeo curto

Use o roteiro em:

```text
docs/roteiro-video.md
```

Objetivo: provar o fluxo completo em 60 a 90 segundos.

## 5. Gerar build web

Rode:

```bash
flutter build web --release --dart-define=SUPABASE_URL=SUA_PROJECT_URL --dart-define=SUPABASE_ANON_KEY=SUA_ANON_KEY
```

O resultado fica em:

```text
build/web
```

## 6. Publicar no Netlify

Caminho simples:

1. Entre no Netlify.
2. Va em Add new site.
3. Escolha Deploy manually.
4. Arraste a pasta `build/web`.
5. Copie a URL gerada.
6. Coloque a URL no README.

## 7. Atualizar README com o link

No README, troque:

```text
Demo web: em breve
```

por:

```text
Demo web: SUA_URL_PUBLICA
```

## 8. Fazer commit final

Depois de adicionar prints e link:

```bash
git add .
git commit -m "Prepara portfólio público"
git push
```

## 9. Colocar no 99freelas

Use:

- link da demo web;
- link do GitHub;
- vídeo curto;
- texto em `docs/texto-99freelas.md`.

## Ordem recomendada

1. Validar Supabase.
2. Rodar app conectado.
3. Gerar prints.
4. Gravar vídeo.
5. Publicar web.
6. Atualizar README.
7. Subir commit.
8. Divulgar no 99freelas.
