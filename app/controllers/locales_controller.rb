class LocalesController < ApplicationController
  def show
    session[:locale] = params[:id]
    redirect_back fallback_location: request.referrer
  end
end
