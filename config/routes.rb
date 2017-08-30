Rails.application.routes.draw do
  post 'sign_up', to: 'registrations#create'
  post 'sign_in', to: 'authorizations#create'

  resources :trips, only: %i[index show create] do
    resources :feedbacks, only: :create
  end
end
