Rails.application.routes.draw do
  root "articles#index"
  resources :articles, only: %i[index show], param: :slug
  namespace :admin do
    resources :articles, except: :show
  end
  get "up" => "rails/health#show", as: :rails_health_check
end
