module Admin
  class ArticlesController < ApplicationController
    before_action :authenticate_admin!
    before_action :set_article, only: %i[edit update destroy]

    def index
      @articles = Article.order(updated_at: :desc)
    end

    def new
      @article = Article.new(content_format: "markdown", status: "draft")
    end

    def create
      @article = Article.new(article_params)
      if @article.save
        redirect_to admin_articles_path, notice: "Artigo salvo."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @article.update(article_params)
        redirect_to admin_articles_path, notice: "Artigo atualizado."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @article.destroy
      redirect_to admin_articles_path, notice: "Artigo removido."
    end

    private

    def authenticate_admin!
      return if session[:admin_authenticated]

      session[:return_to_admin] = request.fullpath
      redirect_to admin_login_path, alert: "Entre para acessar a área de escrita."
    end

    def set_article
      @article = Article.find(params[:id])
    end

    def article_params
      params.require(:article).permit(:title, :slug, :excerpt, :body, :status, :content_format)
    end
  end
end
