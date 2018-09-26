class Price < ApplicationRecord
  validates :cents_per_km, :outside_cents_per_km, :landing, :idle_price, :min_price, :coefficient, presence: true
  before_create :only_one_price

  private

    def only_one_price
      raise "Price alredy created" if Price.count > 0
    end
end
