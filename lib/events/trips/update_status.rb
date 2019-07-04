module Events
  module Trips
    class UpdateStatus < BaseEvent
      def schema
        Dry::Validation.Schema do
          configure { config.messages = :i18n }

          required(:trip_id).filled(:int?)
        end
      end

      def run
        update_trip_status
        create_trip_job(data[:trip_id])
      end

      private

      def update_trip_status
        Trip.find_by(id: data[:trip_id]).update(status: Constants::Trip::PENDING)
      end

      def create_trip_job(trip_id)
        Jobs::SearchCarForTrip.perform_later(trip_id)
      end
    end
  end
end

