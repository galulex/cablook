class ApplicationController < ActionController::Base
  before_action :set_locale

  private

  def set_locale
    I18n.locale = request.env['HTTP_API_LANGUAGE']&.to_sym || (session[:locale] || I18n.default_locale)
  end

  def set_admin_locale
    I18n.locale = :en
  end
end
