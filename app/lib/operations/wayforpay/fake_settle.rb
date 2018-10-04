module Operations
  module Wayforpay
    class FakeSettle
      def initialize(trip_id)
        @trip_id = trip_id
      end

      attr_reader :trip_id

      def call
        status = Constants::Payments::PENDING
        if fake_settle_response['reasonCode'] == Constants::Payments::WAYFORPAY_SUCCESS
          status = Constants::Payments::SUCCESS
          update_trip_total
        end
        create_fake_taxi_payment(status)
      end

      private

      def fake_settle_response
        @fake_settle_reponse ||= Operations::Wayforpay::SendPayment.new(payment.card, prices.landing/100, 'Trip', order_reference).call
      end

      def create_fake_taxi_payment(status)
        Payments::FakeTaxi.create(
          trip_id: trip_id,
          user_id: trip.user_id,
          amount: prices.landing/100,
          response: fake_settle_response,
          status: status,
          order_reference: order_reference
        )
      end

      def prices
        @prices ||= Price.last
      end

      def update_trip_total
        trip.update(total: trip.total + prices.landing/100)
      end

      def trip
        @trip ||= Trip.find(trip_id)
      end

      def payment
        @payment ||= Payments::Trip.find_by(trip_id: trip_id)
      end

      def order_reference
        @order_reference ||= "#{payment.order_reference}_fake_#{SecureRandom.base58(6)}"
      end
    end
  end
end
