Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  
  resource :session

  namespace :dashboard do
    resources :youtube_channels do
      resources :youtube_shorts, except: %i[ new show ], module: :youtube_channels do
        member do
          post :regenerate
        end
      end
      member do
        post :generate_youtube_short
      end
    end
    get "theme", to: "pages#theme"
    get "home", to: "pages#index"

    root to: "pages#index"
  end

  root to: "dashboard/pages#index"
end
