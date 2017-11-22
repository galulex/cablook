module SearchEngine
  module FindCar
    class Free
      def self.call(trip_id:)
        new(trip_id: trip_id).call
      end

      def initialize(trip_id:)
        @trip_id = trip_id
      end

      attr_reader :trip_id

      def call
        car_ids = car_repository.free_cars.map(&:id)
        cars = car_ids.map do |car_id|
          location = redis.get("car_#{car_id}").try(:split, ',')
          { car_id: car_id, location: location } if location
        end.compact
        return if cars.empty?
        locations = cars.map { |car| car[:location] }
        trip = trip_repository.by_id(trip_id)
        nearest = NearestPoint.call(origins_location: locations, destination: trip.departure)
        car = cars.detect { |car| car[:location] == [nearest.origin.lat, nearest.origin.lng] }
        { car_id: car[:car_id], duration: nearest.duration_in_traffic_in_seconds }
      end

      private

      def car_repository
        @car_repository ||= Repositories::Car.new(ROM.env)
      end

      def trip_repository
        @trip_repository ||= Repositories::Trip.new(ROM.env)
      end

      def redis
        @redis = Redis.new
      end
    end
  end
end
