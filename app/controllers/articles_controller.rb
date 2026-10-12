class ArticlesController < ApplicationController
  def index
    @articles = Article.published.recent_first
    if params[:q].present?
      query = "%#{Article.sanitize_sql_like(params[:q].to_s)}%"
      @articles = @articles.where("title ILIKE :q OR excerpt ILIKE :q", q: query)
    end
    @articles = @articles.limit(30)
  end

  def show
    @article = Article.published.find_by!(slug: params[:slug])
  end
end
