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
        return if redis_cars_location.empty?
        nearest = NearestPoint.call(
          origins_location: redis_cars_location.map { |car| car[:location] },
          destination: trip_repository.by_id(trip_id).departure
        )
        location = redis_cars_location.detect { |car| car[:location] == [nearest.origin.lat, nearest.origin.lng] }
        { car_id: location[:car_id], duration: nearest.duration_in_traffic_in_seconds }
      end

      private

      def redis_cars_location
        @cars ||= car_repository.free_cars.map(&:id).map do |car_id|
          location = redis.get("car_#{car_id}").try(:split, ',')
          { car_id: car_id, location: location } if location
        end.compact
      end

      def car_repository
        @car_repository ||= Repositories::Car.new(ROM.env)
      end

      def trip_repository
        @trip_repository ||= Repositories::Trip.new(ROM.env)
      end

      def redis
        @redis ||= Redis.current
      end
    end
  end
end
