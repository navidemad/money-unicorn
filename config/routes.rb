Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  
  resource :session

  namespace :dashboard do
    namespace :youtube do
      resources :channels do
        resources :shorts, module: :channels
        member do
          post :generate_youtube_short
        end
      end
    end
    get "theme", to: "pages#theme"
    get "home", to: "pages#index"

    root to: "pages#index"
  end

  root to: "dashboard/pages#index"
end
