module Operations
  class TripCalculation
    def initialize(departure:, destination:, waypoints: [])
      @departure = departure
      @destination = destination
      @waypoints = waypoints
    end

    attr_reader :departure, :destination, :waypoints

    def cost
      cost = (matrix.distance / 1000.0).ceil(1) * Constants::Trip::CENTS_PER_KM + Constants::Trip::LANDING
      cost = Constants::Trip::MIN_PRICE if cost < Constants::Trip::MIN_PRICE
      ((cost + cost * Constants::Trip::FEE) / 100).ceil
    end

    def distance
      matrix.distance
    end

    def duration
      matrix.duration
    end

    private

    def matrix
      @matrix ||= SearchEngine::Directions.new(departure, destination, waypoints&.map { |w| w.split(',') })
    end
  end
end
