module Events
  module Cars
    class Broadcast < BaseEvent
      def schema
        Dry::Validation.Schema do
          configure { config.messages = :i18n }

          required(:trip)
        end
      end

      private

      def run
        fetch
        return if @info.blank?

        trip.car.location = location
        broadcast_to_trip
        broadcast_to_map
      end

      def fetch
        @info = JSON.parse(RestClient.get("https://owner-api.teslamotors.com/api/1/vehicles/#{trip.driver.address}/data", { Authorization: "Bearer #{trip.driver.auth_token}" }).body)['response']
      rescue StandardError
        @info = {}
      end

      def location
        state = @info['drive_state']
        [state['native_latitude'] || state['latitude'], state['native_longitude'] || state['longitude']]
      end

      def broadcast_to_trip
        ActionCable.server.broadcast(
          "#{Constants::Channels::TRIP}_#{trip.id}",
          action: Constants::BroadcastActions::DRIVER_LOCATION_UPDATED,
          body: {
            car_id: trip.car_id,
            location: { latitude: location[0], longitude: location[1] },
            car: Presenters::Cars::Single.new(trip.car).as_json
          }
        )
      end

      def broadcast_to_map
        ActionCable.server.broadcast(
          Constants::Channels::DRIVER_MAP,
          action: Constants::BroadcastActions::SEND_LOCATION,
          car_id: trip.car_id,
          location: location,
          speed: 0,
          car: Presenters::Cars::Single.new(trip.car).as_json
        )
      end

      def trip
        @trip ||= data[:trip]
      end
    end
  end
end
