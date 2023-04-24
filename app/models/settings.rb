class Settings < ApplicationRecord
  validate :only_one, on: :create

  private

    def only_one
      if Settings.count >= 1
        errors.add :base, 'Settings alredy created' 
      end
    end

    def self.get
      last
    end
end
