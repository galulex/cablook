class WelcomeController < ApplicationController
  layout 'pwa2', only: :pwa

  caches_action :index, cache_path: -> { "#{params[:page]}_#{session[:locale]}" }

  def index
    render params[:page]
  end

  def pwa
  end
end
