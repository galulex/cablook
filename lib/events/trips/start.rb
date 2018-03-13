module Events
  module Trips
    class Start < Events::BaseEvent
      def schema
        Dry::Validation.Schema do
          configure { config.messages = :i18n }

          required(:trip_id).filled(:int?)
        end
      end

      def run
        update_trip
        broadcast
      end

      private

      def update_trip
        Repositories::Trip.new(ROM.env).update(
          data[:trip_id],
          status: Constants::Trip::DRIVING,
          started_at: Time.now
        )
      end

      def broadcast
        ActionCable.server.broadcast(
          trip_channel,
          action: Constants::BroadcastActions::TRIP_START_ACTION,
          body: { action: Constants::BroadcastActions::TRIP_STARTED }
        )
      end

      def trip_channel
        "#{Constants::Channels::TRIP}_#{data[:trip_id]}"
      end
    end
  end
end
