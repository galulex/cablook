module Operations
  class V2TripCalculation
    POLYGON = Geokit::Polygon.new(JSON.parse(File.read('config/polygons/cherkassy.json')).map { |point| Geokit::LatLng.new(point['lat'], point['lng']) })

    def initialize(trip)
      @trip = trip
    end

    def cost
      cost = (@trip.distance / 1000.0).ceil(1) * cents_per_km + Constants::Trip::LANDING
      cost = Constants::Trip::MIN_PRICE if cost < Constants::Trip::MIN_PRICE
      ((cost + cost * Constants::Trip::FEE) / 100).ceil
    end

    private

    def cents_per_km
      in_town? ? Constants::Trip::CENTS_PER_KM : Constants::Trip::OUTSIDE_CENTS_PER_KM
    end

    def in_town?
      points = []
      points << Geokit::LatLng.new(*@trip.departure)
      points << Geokit::LatLng.new(*@trip.destination)
      @trip.waypoints&.each { |point| points << Geokit::LatLng.new(*point.split(',')) }
      points.all? { |point| POLYGON.contains?(point) }
    end
  end
end
