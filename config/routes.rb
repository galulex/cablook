Rails.application.routes.draw do
  post 'sign_up', to: 'registrations#create'
  post 'sign_in', to: 'authorizations#create'
end
