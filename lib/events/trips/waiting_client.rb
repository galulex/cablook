module Events
  module Trips
    class WaitingClient < Events::BaseEvent
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
        trip.update(status: Constants::Trip::WAITING_CLIENT, arrived_at: Time.now)
        trip.update(start_at: trip.preorder_time, preorder_time: '') if trip.preorder?
      end

      def broadcast
        ActionCable.server.broadcast(
          trip_channel,
          action: Constants::BroadcastActions::TRIP_WAITING_ACTION,
          body: { action: Constants::BroadcastActions::TRIP_WAITING }
        )
      end

      def trip_channel
        "#{Constants::Channels::TRIP}_#{data[:trip_id]}"
      end

      def trip
        @trip = Trip.find(data[:trip_id])
      end
    end
  end
end
