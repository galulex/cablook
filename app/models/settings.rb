class Settings < ApplicationRecord
  MESSAGE_SETTINGS_ALREADY_CREATED = 'Settings already created'.freeze
  ALLOW_FONDY_FOR_ALL_USERS = 'all'.freeze

  validate :only_one, on: :create

  enum payment_system: Constants::Card::PAYMENT_SYSTEM
  enum address_geocoder: %w[yandex open_street_map]

  def is_allowed_for_fondy?(user_phone_number)
    return false unless allowed_users.present?
    return true if fondy_allowed_for_all?
    allowed_users.split(',').include?(user_phone_number)
  end

  private

    def only_one
      if Settings.count >= 1
        errors.add :base, MESSAGE_SETTINGS_ALREADY_CREATED
      end
    end

    def self.get
      last
    end

    def fondy_allowed_for_all?
      allowed_users == ALLOW_FONDY_FOR_ALL_USERS
    end
end
