module Operations
  class V2TripCalculation
    include TripCalculationCost
    
    POLYGON = Geokit::Polygon.new(JSON.parse(File.read('config/polygons/cherkassy.json')).map { |point| Geokit::LatLng.new(point['lat'], point['lng']) })

    def initialize(trip)
      @trip = trip
    end

    private

    def in_town?
      points = []
      points << Geokit::LatLng.new(*@trip.departure)
      points << Geokit::LatLng.new(*@trip.destination)
      @trip.waypoints&.each { |point| points << Geokit::LatLng.new(*point.split(',')) }
      points.all? { |point| POLYGON.contains?(point) }
    end
  end
end
