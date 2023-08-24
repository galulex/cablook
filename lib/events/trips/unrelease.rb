module Events
  module Trips
    class Unrelease < BaseEvent
      include Concerns::Direction
      include Validations::Create

      def schema
        Dry::Validation.Schema do
          configure { config.messages = :i18n }
          required(:trip_id).filled(:int?)
        end
      end

      def run
        trip.pending!
        broadcast
        broadcast_to_trip_channel
        Jobs::SearchCarForTrip.perform_later(trip.id)
        drivers_notify
        @trip
      end

      private

      def drivers_notify
        Jobs::DriversNotification.perform_later(trip)
      end

      def trip
        @trip ||= Trip.find(data[:trip_id])
      end

      def broadcast
        ActionCable.server.broadcast(
          Constants::Channels::DRIVER_MAP,
          action: Constants::BroadcastActions::TRIP_FINISHED,
          trip_id: trip.id
        )
      end

      def broadcast_to_trip_channel
        ActionCable.server.broadcast(
          "#{Constants::Channels::TRIP}_#{trip.id}",
          action: Constants::BroadcastActions::TRIP_UNRELEASE
        )
      end
    end
  end
end
