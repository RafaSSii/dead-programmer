require "test_helper"
class ArticleTest < ActiveSupport::TestCase
  test "generates a slug from the title" do
    article = Article.new(title: "Minha primeira anotação!", body: "Texto")
    assert article.valid?
    assert_equal "minha-primeira-anotacao", article.slug
  end
  test "requires title and body" do
    article = Article.new
    assert_not article.valid?
    assert_includes article.errors.attribute_names, :title
    assert_includes article.errors.attribute_names, :body
  end
  test "validates status and format" do
    article = Article.new(title: "Teste", body: "Texto", status: "private", content_format: "unknown")
    assert_not article.valid?
    assert_includes article.errors.attribute_names, :status
    assert_includes article.errors.attribute_names, :content_format
  end
  test "refreshes publication date when a draft is published again" do
    article = Article.create!(title: "Publicação", body: "Texto", status: "published")
    first_publication = article.published_at

    article.update!(status: "draft")
    travel 1.day do
      article.update!(status: "published")
      assert_operator article.published_at, :>, first_publication
    end
  end

  test "estimates at least one minute of reading" do
    assert_equal 1, Article.new(title: "Teste", body: "Poucas palavras").reading_minutes
  end
end
