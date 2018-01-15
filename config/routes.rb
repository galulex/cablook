require 'sidekiq/web'

Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  mount ActionCable.server => '/cable'
  mount Sidekiq::Web => '/sidekiq'

  namespace :api do
    resource :session, only: %i[create update]
    resources :cards, only: %i[index create destroy]
    resources :subscriptions, only: %i[create]
    resources :trips, only: %i[index show create] do
      patch 'cancel'
      resources :feedbacks, only: :create
    end

    namespace :drivers_app do
      resources :cars, only: :index
      patch 'assign_car', to: 'assign_car#update'
      post 'sign_up', to: 'registrations#create'
      resources :sessions, only: :create do
        delete :destroy, on: :collection
      end
    end

    namespace :verifications do
      get 'emails/send_verification', to: 'emails#send_verification'
      post 'emails/verify', to: 'emails#verify'
    end
  end
end
