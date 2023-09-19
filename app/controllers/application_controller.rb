class ApplicationController < ActionController::Base
  before_action :set_locale
  http_basic_authenticate_with name: ENV['ADMIN_USERNAME'] || 'admin', password: ENV['ADMIN_PASSWORD'] || 'admin', if: :admin_controller?

  private

  def admin_controller?
    self.class < ActiveAdmin::BaseController
  end

  def set_locale
    I18n.locale = match_check&.to_sym
  end

  def match_check
    %w[en uk ru].include?(detect_locale) ? detect_locale : I18n.default_locale
  end

  def detect_locale
    (request.env['HTTP_PWA_LANGUAGE'] || request.env['HTTP_API_LANGUAGE']) || session[:locale]
  end

  def set_admin_locale
    I18n.locale = :en
  end

  def not_found
    raise ActionController::RoutingError, 'Not Found'
  end
end
