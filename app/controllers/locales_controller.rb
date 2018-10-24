class LocalesController < ApplicationController
  def show
    session[:locale] = params[:id]
    redirect_to :root
  end
end
