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
        Jobs::SearchCarForTrip.perform_later(trip.id)
        @trip
      end

      private

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
    end
  end
end
