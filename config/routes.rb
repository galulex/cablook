require 'sidekiq/web'

Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  mount ActionCable.server => '/cable'
  mount Sidekiq::Web => '/sidekiq'

  namespace :api do
    resource :business, only: %i[create update show destroy]
    resource :session, only: %i[create update]
    resources :bonus_trips, only: %i[index]
    resources :cards, only: %i[index new create update destroy]
    resources :orders, only: %i[create destroy]
    resources :delivery, only: :create
    resources :payments, only: %i[index] do
      post 'retry_pendings', on: :collection
      get 'pending', on: :collection
    end
    resources :favorite_addresses, only: %i[index create destroy]
    resource :notification_settings, only: %i[update]
    resources :vendors, only: %i[index show]

    resource :user, only: %i[show update]
    resource :device, only: :create

    resource :statistics, only: :show
    resource :settings, only: :show

    post 'cards/update', to: 'cards#complete', as: :card_callback
    resource :address, only: :show

    resources :referrals, only: %i[index create]

    post 'trips/new', to: 'v2/trips#new'
    post 'notify_driver', to: 'notifications#new'
    resources :trips, only: %i[index show create update] do
      get 'unpaid_trips', on: :collection
      patch 'cancel'
      patch 'retry'
      resources :feedbacks, only: :create
    end

    post 'drivers_app/trips/new', to: 'v2/trips#new'
    namespace :drivers_app do
      resources :cars, only: :index
      patch 'assign_car', to: 'assign_car#update'
      resources :maps, only: %i[index]
      post 'sign_up', to: 'registrations#create'
      resources :sessions, only: :create do
        delete :destroy, on: :collection
      end
      resources :trips, only: %i[index] do
        get 'currents', on: :collection
        get 'all', on: :collection
        patch 'accept'
        patch 'update'
        patch 'cancel'
        patch 'finish'
        patch 'start'
        patch 'waiting_client'
        patch 'payments_verify'
        patch 'unrelease'
      end
      resources :statistics, only: :index
      resources :trips_statistics, only: :index
      resource :driver_cards, only: :show
    end

    namespace :verifications do
      get 'phone_numbers/send_verification', to: 'phone_numbers#send_verification'
    end
  end

  namespace :admin do
    get 'analytics/:page' => 'analytics#index', constraints: { page: /(days|hours|mileage|by_driver|users)/ }, defaults: { page: 'days' }, as: :page
  end

  # scope '(:locale)', locale: /(ru)/, defaults: { locale: :uk } do
  get '/pwa(/*all)', to: redirect(subdomain: :app, path: '/')
  get '/(*all)', constraints: { subdomain: /app/ }, defaults: { subdomain: :app }, to: 'welcome#pwa', as: :pwa
  get '/(*all)', constraints: { subdomain: /driver/ }, defaults: { subdomain: :driver }, to: 'welcome#driver', as: :driver
  get ':page' => 'welcome#index', constraints: { page: /(about|faq|why|benefits|contacts|become_driver)/ }, defaults: { page: 'index' }, as: :page
  get 'benefits/ext_opportunities', to: 'welcome#index', defaults: { page: 'ext_opportunities' }, as: :ext_opp
  # end
  resource :driver_request, only: :create

  resources :locales, only: :show, constraints: { id: /(en|uk|ru)/ }
  resources :cards, only: %i[create new]
  post 'webhook', to: 'api/webhooks#update'

  root to: 'welcome#index'
end
