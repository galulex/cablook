module Operations
  module TripCalculationCost
    def cost
      cost = ((@trip.distance / 1000.0).ceil(1) * cents_per_km + prices.landing) * prices.coefficient
      cost = (prices.min_price * prices.coefficient) if cost < (prices.min_price * prices.coefficient)
      ((cost + cost * Constants::Trip::FEE) / 100).ceil
    end

    private

    def prices
      @prices ||= Price.last
    end

    def cents_per_km
      in_town? ? prices.cents_per_km : prices.outside_cents_per_km
    end
  end
end
