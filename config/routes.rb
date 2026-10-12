Rails.application.routes.draw do
  root "articles#index"
  resources :articles, only: %i[index show], param: :slug

  # Not linked from public pages; the admin area also requires authenticated credentials.
  get "caderno-privado-7f3c9a", to: "admin/sessions#new", as: :admin_login
  post "caderno-privado-7f3c9a", to: "admin/sessions#create"
  delete "sair-do-caderno", to: "admin/sessions#destroy", as: :admin_logout

  namespace :admin do
    resources :articles, except: :show
  end
  get "up" => "rails/health#show", as: :rails_health_check
end
