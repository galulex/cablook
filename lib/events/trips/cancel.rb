module Events
  module Trips
    class Cancel < Events::BaseEvent
      def schema
        Dry::Validation.Schema do
          configure { config.messages = :i18n }

          required(:trip_id).filled(:int?)
        end
      end

      def run
        if trip.status.in?([Constants::Trip::PENDING, Constants::Trip::ON_THE_WAY])
          update_trip
          delete_from_jobs
          refund_payment
        else
          invalid!([I18n.t('trips.cancel_impossible')])
        end
      end

      private

      def update_trip
        Repositories::Trip.new(ROM.env).update(
          data[:trip_id],
          status: Constants::Trip::CANCELED
        )
      end

      def delete_from_jobs
        trip_job = Repositories::TripJob.new(ROM.env).by_trip_id(data[:trip_id])
        Jobs::SearchCarForTrip.cancel(trip_job.activejob_id) if trip_job
      end

      def refund_payment
        Jobs::PaymentRefund.perform_later(data[:trip_id])
      end

      def trip
        @trip ||= Repositories::Trip.new(ROM.env).by_id(data[:trip_id])
      end
    end
  end
end
