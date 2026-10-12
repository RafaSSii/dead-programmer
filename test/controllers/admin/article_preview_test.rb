require "test_helper"

class Admin::ArticlePreviewTest < ActionDispatch::IntegrationTest
  setup do
    @original_user = ENV["BLOG_ADMIN_USER"]
    @original_password = ENV["BLOG_ADMIN_PASSWORD"]
    ENV["BLOG_ADMIN_USER"] = "preview-admin"
    ENV["BLOG_ADMIN_PASSWORD"] = "preview-secret"
    post admin_login_url, params: { username: "preview-admin", password: "preview-secret" }
    assert_redirected_to admin_articles_path
  end

  teardown do
    ENV["BLOG_ADMIN_USER"] = @original_user
    ENV["BLOG_ADMIN_PASSWORD"] = @original_password
  end

  test "previews unsaved Markdown without creating an article" do
    post admin_preview_articles_url, params: {
      article: {
        title: "Prévia sem salvar",
        excerpt: "Resumo da prévia",
        body: "# Seção de teste\n\nTexto **formatado**.",
        status: "published",
        content_format: "markdown"
      }
    }

    assert_response :success
    assert_select ".preview-banner", /ainda não foi salvo nem publicado/
    assert_select ".post-header h1", "Prévia sem salvar"
    assert_select ".prose h1", "Seção de teste"
    assert_select ".prose strong", "formatado"
    assert_not Article.exists?(title: "Prévia sem salvar")
  end

  test "sanitizes visual HTML in the preview" do
    post admin_preview_articles_url, params: {
      article: {
        title: "Prévia visual",
        body: '<script>alert("xss")</script><p>Conteúdo seguro</p>',
        status: "draft",
        content_format: "visual"
      }
    }

    assert_response :success
    assert_select ".prose p", "Conteúdo seguro"
    assert_no_match(/<script/i, response.body)
  end

  test "new article form offers preview in a separate tab" do
    get new_admin_article_url

    assert_response :success
    assert_select 'button[formtarget="_blank"][formaction=?]', preview_admin_articles_path, text: /Pré-visualizar/
  end
end
