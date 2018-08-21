module Operations
  class TripCalculation
    include TripCalculationCost
    
    def initialize(departure:, destination:, waypoints: [])
      @departure = departure
      @destination = destination
      @waypoints = waypoints&.map { |w| w.split(',') }
    end

    attr_reader :departure, :destination, :waypoints

    def distance
      matrix.distance
    end

    def duration
      matrix.duration
    end

    private

    def cents_per_km
      cents_per_km = in_town? ? prices.cents_per_km : prices.outside_cents_per_km
    end

    def in_town?
      points = []
      points << Geokit::LatLng.new(departure[0], departure[1])
      points << Geokit::LatLng.new(destination[0], destination[1])
      waypoints&.each { |point| points << Geokit::LatLng.new(point[0], point[1]) }
      points.all? { |point| polygon.contains?(point) }
    end

    def matrix
      @matrix ||= SearchEngine::Directions.new(departure, destination, waypoints)
    end

    def polygon
      @polygon ||= Geokit::Polygon.new(polygon_data)
    end

    def polygon_data
      points = JSON.parse(File.read('config/polygons/cherkassy.json'))
      points.map { |point| Geokit::LatLng.new(point['lat'], point['lng']) }
    end
  end
end
