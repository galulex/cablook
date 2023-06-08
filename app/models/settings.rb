class Settings < ApplicationRecord
  MESSAGE_SETTINGS_ALREADY_CREATED = 'Settings already created'.freeze
  FEATURES = %w[bonuses cashback delivery sos validate_unpaid_trips].freeze

  validate :only_one, on: :create

  enum payment_system: Constants::Card::PAYMENT_SYSTEM
  enum address_geocoder: %w[yandex open_street_map]

  class << self
    def method_missing(name, *args)
      return !disabled_features.include?(name.to_s) if FEATURES.include?(name.to_s)

      last.send(name, *args)
    end

    def enable(feature)
      return unless disabled_features.include?(feature.to_s)

      update(disabled_features: disabled_features - [feature.to_s])
    end

    def disable(feature)
      return if disabled_features.include?(feature.to_s)

      update(disabled_features: disabled_features.push(feature))
    end
  end

  private

  def only_one
    errors.add :base, MESSAGE_SETTINGS_ALREADY_CREATED if Settings.count >= 1
  end
end
