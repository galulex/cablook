class Settings < ApplicationRecord
  MESSAGE_SETTINGS_ALREADY_CREATED = 'Settings already created'.freeze
  FEATURES = %w[bonuses cashback delivery sos validate_unpaid_trips overspeed_notify].freeze

  validate :only_one, on: :create

  enum payment_system: Constants::Card::PAYMENT_SYSTEM
  enum address_geocoder: %w[yandex open_street_map]

  class << self
    def get(feature = '')
      feature.blank? ? last : enabled?(feature)
    end

    def enable(feature)
      return if enabled?(feature)

      current_settings.disabled_features.delete(feature.to_s)
      current_settings.update(disabled_features: current_settings.disabled_features)
    end

    def disable(feature)
      last.update(disabled_features: current_settings.disabled_features.push(feature)) if enabled?(feature)
    end

    def enabled?(feature)
      !current_settings.disabled_features.include?(feature.to_s)
    end

    def current_settings
      @current_settings ||= last
    end
  end

  def feature
    FEATURES.each { |f| define_singleton_method(f) { !disabled_features.include?(f.to_s) } }
    self
  end

  private

  def only_one
    errors.add :base, MESSAGE_SETTINGS_ALREADY_CREATED if Settings.count >= 1
  end
end
