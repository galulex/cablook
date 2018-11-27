class LocalesController < ApplicationController
  def show
    session[:locale] = params[:id]
    redirect_back fallback_location: root_path
  end
end
