class Settings < ApplicationRecord
  validate :only_one, on: :create

  enum payment_system: Constants::Card::PAYMENT_SYSTEM

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
