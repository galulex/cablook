class CardsController < ApplicationController
  layout 'pwa'
  before_action :set_session_locale, only: :new

  private

  def set_session_locale
    session[:locale] = params[:locale]
  end
end
