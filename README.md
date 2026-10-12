# Dead Programmer

Blog pessoal para publicar artigos e anotações sobre programação, Linux e tecnologia.

## Stack
- Ruby on Rails 8 / Ruby 3.3.6
- PostgreSQL e Tailwind CSS
- Hotwire + Stimulus
- Tema claro/escuro e editor Markdown/visual básico

## Executar
```bash
bundle install
bin/rails db:prepare
bin/rails db:seed
bin/dev
```
Acesse http://localhost:3000.

## Painel de escrita
O painel fica em `/admin/articles` e exige HTTP Basic. Configure antes de iniciar:
```bash
export BLOG_ADMIN_USER="seu_usuario"
export BLOG_ADMIN_PASSWORD="uma_senha_forte"
bin/dev
```
Sem essas variáveis, o painel retorna indisponível em vez de abrir sem autenticação. Artigos em rascunho não aparecem publicamente.

## Testes
```bash
bin/rails test
```

## MVP
Página inicial, busca, leitura, artigos publicados/rascunhos, painel protegido, editor Markdown e visual básico, alternância de tema. Próximos passos: tags, RSS, sitemap e upload de imagens.
