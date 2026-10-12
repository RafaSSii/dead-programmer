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

## Painel privado de escrita
A tela de login não aparece na navegação pública. Acesse diretamente:

`/caderno-privado-7f3c9a`

O caminho escondido é apenas uma camada de discrição, não substitui autenticação. O painel exige usuário e senha e não permite cadastro público. Configure as credenciais antes de iniciar:
```bash
export BLOG_ADMIN_USER="seu_usuario"
export BLOG_ADMIN_PASSWORD="uma_senha_forte"
bin/dev
```
Depois do login, o painel fica em `/admin/articles`. Sem as variáveis de ambiente, o login permanece indisponível. Use HTTPS em produção e não armazene credenciais no repositório.

## Testes
```bash
bin/rails test
```

## MVP
Página inicial, busca, leitura, artigos publicados/rascunhos, painel protegido por login, editor Markdown e visual básico, alternância de tema. Próximos passos: tags, RSS, sitemap e upload de imagens.
