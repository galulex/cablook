class Settings < ApplicationRecord
  MESSAGE_SETTINGS_ALREADY_CREATED = 'Settings already created'.freeze

  validate :only_one, on: :create

  enum payment_system: Constants::Card::PAYMENT_SYSTEM
  enum address_geocoder: %w[yandex open_street_map]

  private

    def only_one
      if Settings.count >= 1
        errors.add :base, MESSAGE_SETTINGS_ALREADY_CREATED
      end
    end

    def self.get
      last
    end
end
