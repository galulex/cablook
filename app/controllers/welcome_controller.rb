class WelcomeController < ApplicationController
  layout 'pwa', only: :pwa

  def index
    render params[:page]
  end

  def pwa
  end
end
