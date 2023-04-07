class Settings < ApplicationRecord
  before_create :only_one_settings

  private

    def only_one_settings
      raise "Settings alredy created" if Settings.count > 0
    end

    def self.get
      self.last
    end

    def self.bonuses_enabled?
      self.last.bonuses
    end

    def self.bonuses_switch
      self.last.update!(bonuses: !self.last.bonuses)
    end

    def self.cashback_enabled?
      self.last.cashback
    end

    def self.cashback_switch
      self.last.update!(cashback: !self.last.cashback)
    end
end
