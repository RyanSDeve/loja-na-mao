# Passo a passo para transformar em portfolio

Este projeto foi pensado para ser uma vitrine do que voce sabe fazer com Flutter, FlutterFlow como stack de trabalho, Supabase e app comercial.

## 1. Criar repositorio no GitHub

Faz sentido criar um repositorio publico, sim.

Motivo:

- cliente ve que voce tem projeto real;
- voce pode colocar o link no 99freelas;
- o README vira uma pagina de apresentacao;
- mostra organizacao, documentacao e cuidado tecnico;
- facilita evoluir o projeto aos poucos.

Nome sugerido do repositorio:

```text
loja-na-mao-flutter-supabase
```

Descricao sugerida:

```text
App demo de catalogo, carrinho e pedidos para pequenos comercios usando Flutter e Supabase.
```

Depois de criar o repositorio no GitHub, rode:

```bash
git add .
git commit -m "Cria app demo Loja na Mao"
git branch -M main
git remote add origin URL_DO_SEU_REPOSITORIO
git push -u origin main
```

## 2. Criar projeto Supabase para demo

Faz sentido criar um projeto Supabase so para demo, sim.

Motivo:

- voce mostra backend real, nao so tela bonita;
- pedidos podem ser registrados de verdade;
- voce pratica PostgreSQL, RLS e estrutura de tabelas;
- no 99freelas isso diferencia voce de quem so monta interface.

Cuidados:

- nao use dados pessoais reais;
- nao coloque chave secreta no GitHub;
- use apenas a anon key no app;
- deixe RLS ligado;
- trate esse Supabase como ambiente descartavel de demonstracao.

Passos:

1. Entre no Supabase.
2. Crie um novo projeto.
3. Nome sugerido: `loja-na-mao-demo`.
4. Espere o projeto ficar pronto.
5. Abra o SQL Editor.
6. Cole e rode o conteudo de `supabase/schema.sql`.
7. Va em Project Settings > API.
8. Copie a Project URL e a anon public key.
9. Rode o app usando `--dart-define`.

Comando:

```bash
flutter run -d chrome --dart-define=SUPABASE_URL=SUA_PROJECT_URL --dart-define=SUPABASE_ANON_KEY=SUA_ANON_KEY
```

## 3. Rodar como demo web

Para portfolio, o melhor primeiro alvo e web. Cliente nao precisa instalar APK.

Rode:

```bash
flutter run -d chrome
```

Mesmo sem Supabase, o app roda em modo demo com dados locais.

Depois que estiver tudo certo:

```bash
flutter build web --release
```

O build sai em:

```text
build/web
```

## 4. Onde hospedar

Opcoes boas:

- Firebase Hosting;
- Netlify;
- Vercel;
- GitHub Pages.

Para comecar rapido, Netlify costuma ser simples:

1. Gere `flutter build web --release`.
2. Entre no Netlify.
3. Arraste a pasta `build/web`.
4. Copie o link publicado.
5. Coloque o link no README e no perfil do 99freelas.

## 5. O que colocar no perfil do 99freelas

Coloque uma frase objetiva:

```text
Veja meu projeto demo: app de catalogo e pedidos feito com Flutter e Supabase, com carrinho, WhatsApp e backend real.
```

Coloque tambem:

- link do app publicado;
- link do GitHub;
- video curto demonstrando o fluxo;
- prints da tela inicial, carrinho, checkout e painel de pedidos.

## 6. Roteiro do video

Tempo ideal: 60 a 90 segundos.

Roteiro:

1. "Esse e um app demo que criei para pequenos comercios."
2. Mostrar tela inicial.
3. Buscar produto.
4. Filtrar categoria.
5. Adicionar item no carrinho.
6. Abrir checkout.
7. Mostrar envio para WhatsApp.
8. Abrir tela de pedidos.
9. "O backend foi estruturado com Supabase e PostgreSQL."

## 7. Evolucoes que valem muito

Quando quiser deixar mais forte:

- criar area admin com login;
- permitir cadastrar produtos pelo app;
- upload de fotos no Supabase Storage;
- status do pedido em tempo real;
- dashboard de vendas;
- tema customizavel por loja;
- deploy web publico.

## 8. Ordem recomendada para voce

1. Rodar local no Chrome.
2. Criar Supabase demo.
3. Conectar app no Supabase.
4. Criar repositorio GitHub.
5. Subir codigo.
6. Publicar web.
7. Gravar video.
8. Colocar no 99freelas.
