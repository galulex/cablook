class ApplicationController < ActionController::Base
  before_action :set_locale

  private

  def set_locale
    I18n.locale = match_check&.to_sym || (session[:locale] || I18n.default_locale)
  end

  def match_check
    %w[en uk ru].include?(detect_locale) ? detect_locale : I18n.default_locale
  end

  def detect_locale
    request.env['HTTP_PWA_LANGUAGE'] || request.env['HTTP_API_LANGUAGE']
  end

  def set_admin_locale
    I18n.locale = :en
  end
end
