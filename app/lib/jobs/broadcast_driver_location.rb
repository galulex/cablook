module Jobs
  class BroadcastDriverLocation < ActiveJob::Base
    queue_as :broadcast_location

    def perform
      broadcast_to_map_channel
      broadcast_to_trip_channel
    end

    private

    def broadcast_to_map_channel
      ActionCable.server.broadcast(
        Constants::Channels::DRIVER_MAP,
        action: Constants::BroadcastActions::SEND_LOCATION,
        payload: cars
      )
    end

    def broadcast_to_trip_channel
      cars.each do |car|
        next if car[:current_trips].empty?

        car[:current_trips].each do |trip_id|
          ActionCable.server.broadcast(
            "#{Constants::Channels::TRIP}_#{trip_id}",
            action: Constants::BroadcastActions::DRIVER_LOCATION_UPDATED,
            body: {
              car_id: car[:id],
              location: {
                latitude: car[:location][0],
                longitude: car[:location][1]
              }
            }
          )
        end
      end
    end

    def cars
      @cars ||= Car.for_map.reduce([]) do |cars, car|
        car_data = redis.get("car_data_#{car.id}")
        next car unless car_data

        cars.push(JSON.parse(car_data).symbolize_keys.to_h.merge(id: car.id, location: car.location))
      end
    end

    def redis
      @redis ||= Redis.current
    end
  end
end
