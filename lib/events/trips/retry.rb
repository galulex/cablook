module Events
  module Trips
    class Retry < Events::BaseEvent
      def schema
        Dry::Validation.Schema do
          configure { config.messages = :i18n }

          required(:trip_id).filled(:int?)
        end
      end

      def run
        update_trip
        retry_trip_job(trip.id)
        trip
      end

      private

      def retry_trip_job(trip_id)
        Jobs::SearchCarForTrip.perform_now(trip_id) #broadcast
        Jobs::DeclineTrip.set(wait: Constants::Trip::EXPIRES_IN).perform_later(trip_id)
      end

      def update_trip
        trip.update(status: Constants::Trip::PENDING)
      end

      def trip
        @trip ||= Trip.find(data[:trip_id])
      end
    end
  end
end
