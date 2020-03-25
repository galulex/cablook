class WelcomeController < ApplicationController
  layout :defined_layout

  caches_action :index, cache_path: -> { "#{params[:page]}_#{session[:locale]}" }
  caches_action :pwa

  def index
    render params[:page]
  end

  private

  def defined_layout
    case action_name
    when 'pwa'
      'pwa2'
    when 'driver'
      'driver'
    else
      'application'
    end
  end
end
