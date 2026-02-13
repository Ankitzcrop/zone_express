Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  namespace :api do
    namespace :v1 do
      post 'send_otp', to: 'auth#send_otp'
      post 'verify_otp', to: 'auth#verify_otp'
      resource :profile, only: [:show, :update]
      resources :addresses do
        collection do
          get :delivery_addresses
        end
      end
      get 'home', to: 'home#index'
    end
  end
  namespace :api do
    namespace :v1 do
      resources :schedules, only: [] do
        collection do
          get :available_dates
          post :book_pickup
        end
      end
    end
  end
  namespace :api do
    namespace :v1 do
      resources :packages, only: [] do
        collection do
          get :filters
          post :save_package
        end
      end
    end
  end
  namespace :api do
    namespace :v1 do
      resources :orders do
        member do
          post :add_package
          post :add_schedule
          post :select_delivery_type
          post :select_addresses
          post :apply_promo
          get  :summary
          post :confirm
        end
      end
    end
  end
  namespace :api do
    namespace :v1 do

      resources :delivery_types, only: [:create, :index]
      resources :promo_codes, only: [:create, :index]

    end
  end
end
