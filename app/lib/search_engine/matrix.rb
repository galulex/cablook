module SearchEngine
  class Matrix
    def initialize(*places)
      matrix = GoogleDistanceMatrix::Matrix.new
      places.compact!
      places[0..-2].each { |place| matrix.origins << build(place) }
      matrix.destinations << build(places.last)
      @data = matrix.data.flatten
    end

    def duration
      @data.map(&:duration_in_seconds).sum
    end

    def distance
      @data.map(&:distance_in_meters).sum
    end

    private

    def build(place)
      GoogleDistanceMatrix::Place.new(lat: place[0], lng: place[1])
    end
  end
end
