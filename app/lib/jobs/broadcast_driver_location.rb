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
        {
          action: Constants::BroadcastActions::SEND_LOCATION,
          payload: cars
        }
      )
    end

    def broadcast_to_trip_channel
      cars.each do |car|
        next if car['current_trips'].empty?

        car['current_trips'].each do |trip_id|
          ActionCable.server.broadcast(
            "#{Constants::Channels::TRIP}_#{trip_id}",
            {
              action: Constants::BroadcastActions::DRIVER_LOCATION_UPDATED,
              body: {
                car_id: car['id'],
                location: {
                  latitude: car['location'][0],
                  longitude: car['location'][1]
                }
              }
            }
          )
        end
      end
    end

    def cars
      @cars ||= Car.for_broadcast.as_json(only: :id, methods: %i[speed current_trips location])
    end

    def redis
      @redis ||= Redis.new
    end
  end
end
