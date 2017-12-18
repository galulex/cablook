require 'sidekiq/web'

Rails.application.routes.draw do
  mount ActionCable.server => '/cable'
  mount Sidekiq::Web => '/sidekiq'

  resource :session, only: %i[create update]
  resources :cards, only: %i[index create destroy]
  resources :subscriptions, only: %i[create]
  resources :trips, only: %i[index show create] do
    resources :feedbacks, only: :create
  end

  namespace :drivers_app do
    resources :cars, only: :index
    patch 'assign_car', to: 'assign_car#update'
    post 'sign_up', to: 'registrations#create'
    post 'sign_in', to: 'authentications#create'
  end

  namespace :verifications do
    get 'emails/send_verification', to: 'emails#send_verification'
    post 'emails/verify', to: 'emails#verify'
  end
end
