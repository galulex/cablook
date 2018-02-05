module SearchEngine
  class NearestPoint
    def self.call(attrs = {})
      new(attrs).call
    end

    def initialize(origins_location:, destination:, departure: 'now')
      @origins_location = origins_location
      @destination = destination
      @departure = departure
    end

    attr_reader :origins_location, :destination, :departure

    def call
      add_origins
      add_destination
      matrix.shortest_route_by_duration_to(destination_address)
    end

    def add_origins
      origins_location.each do |origin|
        place = GoogleDistanceMatrix::Place.new(lat: origin[0], lng: origin[1])
        matrix.origins << place
      end
    end

    def add_destination
      matrix.destinations << destination_address
    end

    private

    def destination_address
      @destination_address ||= GoogleDistanceMatrix::Place.new(lat: destination[0], lng: destination[1])
    end

    def matrix
      return @matrix if defined?(@matrix)

      @matrix = GoogleDistanceMatrix::Matrix.new

      @matrix.configure do |config|
        config.departure_time = departure
      end
      @matrix
    end
  end
end
