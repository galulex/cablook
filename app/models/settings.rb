class Settings < ApplicationRecord
  before_create :only_one_settings

  enum payment_system: Constants::Card::PAYMENT_SYSTEM

  private

    def only_one_settings
      raise "Settings alredy created" if Settings.count > 0
    end

    def self.get
      self.last
    end
end
