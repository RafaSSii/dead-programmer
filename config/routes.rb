Rails.application.routes.draw do
  root "articles#index"
  resources :articles, only: %i[index show], param: :slug

  # The private login URL is supplied at runtime and is never hardcoded in this public repository.
  if ENV["BLOG_LOGIN_PATH"].present?
    private_login_path = ENV["BLOG_LOGIN_PATH"].delete_prefix("/")
    get private_login_path, to: "admin/sessions#new", as: :admin_login
    post private_login_path, to: "admin/sessions#create"
  end
  delete "sair-do-caderno", to: "admin/sessions#destroy", as: :admin_logout

  namespace :admin do
    post "articles/preview", to: "articles#preview", as: :preview_articles
    resources :articles, except: :show
  end
  get "up" => "rails/health#show", as: :rails_health_check
end
