# Dead Programmer

Blog pessoal para publicar artigos e anotações sobre programação, Linux e tecnologia.

## Stack
- Ruby on Rails 8 / Ruby 3.3.6
- PostgreSQL e Tailwind CSS
- Hotwire + Stimulus
- Tema claro/escuro e editor Markdown/visual básico

## Executar
Configure as credenciais administrativas e um caminho privado antes de iniciar o servidor:
```bash
export BLOG_ADMIN_USER="seu_usuario"
export BLOG_ADMIN_PASSWORD="uma_senha_forte"
export BLOG_LOGIN_PATH="escolha-um-caminho-longo-e-dificil-de-adivinhar"
bundle install
bin/rails db:prepare
bin/rails db:seed
bin/dev
```
Acesse http://localhost:3000. A tela de login ficará disponível no caminho escolhido em `BLOG_LOGIN_PATH`; esse caminho não fica gravado no repositório nem aparece na navegação pública.

## Painel privado de escrita
Após entrar com as credenciais configuradas em `BLOG_ADMIN_USER` e `BLOG_ADMIN_PASSWORD`, você poderá gerenciar os artigos em `/admin/articles`. Não existe cadastro público. Se `BLOG_LOGIN_PATH` não estiver configurado, a rota de login não é criada e o painel administrativo retorna 404 para visitantes não autenticados.

Use HTTPS em produção, mantenha as variáveis de ambiente fora do repositório e escolha um caminho privado que não reutilize senhas. O caminho discreto é uma camada adicional; a autenticação é a proteção real.

## Testes
```bash
bin/rails test
```

## MVP
Página inicial, busca, leitura, artigos publicados/rascunhos, painel protegido por login, editor Markdown e visual básico, alternância de tema. Próximos passos: tags, RSS, sitemap e upload de imagens.
