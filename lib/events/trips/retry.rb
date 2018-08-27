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
        Operations::BroadcastTripProposal.(cars: cars, trip_id: data[:trip_id])
        Jobs::DeclineTrip.set(wait: Constants::Trip::EXPIRES_IN).perform_later(data[:trip_id])
        trip
      end

      private

      def update_trip
        trip.update(status: Constants::Trip::PENDING)
      end

      def trip
        @trip ||= Trip.find(data[:trip_id])
      end

      def cars
        cars = Car.where.not(status: Constants::Car::OFFLINE).pluck(:id)
      end
    end
  end
end
