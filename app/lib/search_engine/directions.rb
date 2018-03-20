module SearchEngine
  class Directions
    def initialize(origin, destination, waypoints = nil)
      gmaps = GoogleMapsService::Client.new
      @data = gmaps.directions(origin.to_a, destination.to_a, waypoints: waypoints)[0]
    end

    def duration
      @data[:legs].sum { |l| l.dig(:duration, :value) }
    end

    def distance
      @data[:legs].sum { |l| l.dig(:distance, :value) }
    end

    private

    def build(place)
      GoogleDistanceMatrix::Place.new(lat: place[0], lng: place[1])
    end
  end
end
