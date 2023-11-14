module Events
  module Trips
    module Concerns
      module PaymentsTypes
        private

        def trip_payment
          @trip_payment ||= trip.trip_payment
        end

        def cash_trip?
          trip_payment&.payment_method == Constants::Payments::METHOD_CASH
        end

        def mobile_pay?
          trip_payment&.payment_method == Constants::Payments::METHOD_MOBILE
        end
      end
    end
  end
end
