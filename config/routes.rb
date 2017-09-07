Rails.application.routes.draw do
  mount ActionCable.server => '/cable'

  post 'sign_up', to: 'registrations#create'
  post 'sign_in', to: 'authorizations#create'

  resources :trips, only: %i[index show create] do
    resources :feedbacks, only: :create
  end

  namespace :verifications do
    get 'phone_numbers/send_verification', to: 'phone_numbers#send_verification'
    post 'phone_numbers/verify', to: 'phone_numbers#verify'
  end
end
