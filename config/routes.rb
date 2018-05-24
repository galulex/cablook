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
    resources :referrals, only: %i[index create]
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
      get 'emails/send_verification', to: 'emails#send_verification'
      post 'emails/verify', to: 'emails#verify'
    end
  end

  # scope '(:locale)', locale: /(ru)/, defaults: { locale: :ua } do
  get 'pwa' => 'welcome#pwa'
  get ':page' => 'welcome#index', constraints: { page: /(about|faq|why|benefits|contacts)/ }, defaults: { page: 'index' }, as: :page
  # end

  root to: 'welcome#index'
end
