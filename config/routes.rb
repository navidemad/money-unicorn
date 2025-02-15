Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  
  resource :session

  namespace :admin do
    namespace :youtube do
      resources :shorts, only: [:index]
    end
    get "theme", to: "pages#theme"

    root to: "youtube/shorts#index"
  end

  root to: "admin/youtube/shorts#index"
end
