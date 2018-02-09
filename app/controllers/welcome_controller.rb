class WelcomeController < ApplicationController
  def index
    render params[:page]
  end
end
