class Settings < ApplicationRecord
  validate :only_one, on: :create

  enum payment_system: Constants::Card::PAYMENT_SYSTEM

  enum address_geocoder: %w[yandex open_street_map]

  def is_allowed_for_fondy?(user_phone_number)
    allowed_users.split(',').any? { |phone_number| user_phone_number.include?(phone_number) }
  end

  private

    def only_one
      if Settings.count >= 1
        errors.add :base, 'Settings already created'
      end
    end

    def self.get
      last
    end
end
