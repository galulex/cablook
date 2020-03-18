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
        Jobs::SearchCarForTrip.perform_later(trip.id)
        @trip
      end

      private

      def trip
        @trip ||= Trip.find(data[:trip_id])
      end
    end
  end
end
