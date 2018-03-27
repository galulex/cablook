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
        trip = update_trip
        SearchEngine.(trip_id: data[:trip_id]) # broadcast
        trip
      end

      private

      def update_trip
        Repositories::Trip.new(ROM.env).update(data[:trip_id], status: Constants::Trip::PENDING)
      end
    end
  end
end
