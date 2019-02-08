class WelcomeController < ApplicationController
  layout 'pwa2', only: :pwa

  caches_action :index, cache_path: -> { "#{params[:page]}_#{session[:locale]}" }
  caches_action :pwa

  def index
    render params[:page]
  end
end
