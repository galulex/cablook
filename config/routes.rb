require 'sidekiq/web'

Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  mount ActionCable.server => '/cable'
  mount Sidekiq::Web => '/sidekiq'

  namespace :api do
    resource :business, only: %i[create update show destroy]
    resource :session, only: %i[create update]
    resources :bonus_trips, only: %i[index]
    resources :cards, only: %i[index create destroy]
    resources :payments, only: %i[index] do
      post 'retry_pendings', on: :collection
      get 'pending', on: :collection
    end

    post 'cards/update', to: 'cards#update'

    resources :referrals, only: %i[index create]

    post 'trips/new', to: 'v2/trips#new'
    resources :trips, only: %i[index show create] do
      patch 'cancel'
      patch 'retry'
      resources :feedbacks, only: :create
    end

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
        patch 'accept'
        patch 'cancel'
        patch 'finish'
        patch 'start'
        patch 'waiting_client'
      end
    end

    namespace :verifications do
      get 'phone_numbers/send_verification', to: 'phone_numbers#send_verification'
    end
  end

  namespace :admin do
    get 'analytics/:page' => 'analytics#index', constraints: { page: /(days|hours|mileage|by_driver|users)/ }, defaults: { page: 'days' }, as: :page
  end

  # scope '(:locale)', locale: /(ru)/, defaults: { locale: :uk } do
  get 'pwa' => 'welcome#pwa'
  get ':page' => 'welcome#index', constraints: { page: /(about|faq|why|benefits|contacts)/ }, defaults: { page: 'index' }, as: :page
  get 'benefits/ext_opportunities', to: 'welcome#index', defaults: { page: 'ext_opportunities' }, as: :ext_opp
  # end

  resources :locales, only: :show, constraints: { id: /(en|uk|ru)/ }

  root to: 'welcome#index'
end
