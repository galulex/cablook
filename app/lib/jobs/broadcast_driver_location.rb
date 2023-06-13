module Jobs
  class BroadcastDriverLocation < ActiveJob::Base
    queue_as :broadcast_location

    def perform
        Car.for_map.ids.each do |id|
          coords = Redis.current.get("car_#{id}").split(',')
          car = JSON.parse(Redis.current.get("car_data_#{id}")).symbolize_keys
          broadcast_to_map_channel(id, coords, car[:speed])
          broadcast_to_trip_channel(id, car[:current_trips], coords) unless car[:current_trips].empty?
        end
    end

    private

    def broadcast_to_map_channel(car_id, coords, speed)
      ActionCable.server.broadcast(
        Constants::Channels::DRIVER_MAP,
        action: Constants::BroadcastActions::SEND_LOCATION,
        car_id: car_id,
        location: coords,
        speed: speed
      )
    end

    def broadcast_to_trip_channel(car_id, current_trips, coords)
      current_trips.each do |trip_id|
        ActionCable.server.broadcast(
          "#{Constants::Channels::TRIP}_#{trip_id}",
          action: Constants::BroadcastActions::DRIVER_LOCATION_UPDATED,
          body: {
            car_id: car_id,
            location: {
              latitude: coords[0],
              longitude: coords[1]
            }
          }
        )
      end
    end
  end
end
