module Operations
  module TripCalculationCost
    def cost
      cost = (@trip.distance / 1000.0).ceil(1) * cents_per_km + Constants::Trip::LANDING
      cost = Constants::Trip::MIN_PRICE if cost < Constants::Trip::MIN_PRICE
      ((cost + cost * Constants::Trip::FEE) / 100).ceil
    end
  end
end