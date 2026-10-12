module Admin
  class ArticlesController < ApplicationController
    before_action :authenticate_admin!
    before_action :set_article, only: %i[edit update destroy]
    def index = @articles = Article.order(updated_at: :desc)
    def new = @article = Article.new(content_format: "markdown", status: "draft")
    def create
      @article = Article.new(article_params)
      return redirect_to(admin_articles_path, notice: "Artigo salvo.") if @article.save
      render :new, status: :unprocessable_entity
    end
    def edit; end
    def update
      return redirect_to(admin_articles_path, notice: "Artigo atualizado.") if @article.update(article_params)
      render :edit, status: :unprocessable_entity
    end
    def destroy
      @article.destroy
      redirect_to admin_articles_path, notice: "Artigo removido."
    end
    private
    def authenticate_admin!
      user, password = ENV.values_at("BLOG_ADMIN_USER", "BLOG_ADMIN_PASSWORD")
      return head :service_unavailable if user.blank? || password.blank?
      authenticate_or_request_with_http_basic("Dead Programmer Admin") do |u, p|
        ActiveSupport::SecurityUtils.secure_compare(u, user) && ActiveSupport::SecurityUtils.secure_compare(p, password)
      end
    end
    def set_article = @article = Article.find(params[:id])
    def article_params = params.require(:article).permit(:title, :slug, :excerpt, :body, :status, :content_format)
  end
end
