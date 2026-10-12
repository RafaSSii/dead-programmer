require "test_helper"
class ArticlesControllerTest < ActionDispatch::IntegrationTest
  test "home page renders" do
    get root_url
    assert_response :success
    assert_select "h1", /Aprendendo em público/
  end
  test "published article can be read" do
    article = Article.create!(title: "Artigo público", body: "Texto de teste", status: "published")
    get article_url(article.slug)
    assert_response :success
    assert_select "h1", "Artigo público"
  end
  test "draft article is not publicly accessible" do
    article = Article.create!(title: "Rascunho privado", body: "Ainda não publicado")
    get article_url(article.slug)
    assert_response :not_found
  end
end
