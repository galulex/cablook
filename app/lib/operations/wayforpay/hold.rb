module Operations
  module Wayforpay
    class Hold
      def initialize(trip_id:, card_id:)
        @trip_id = trip_id
        @card_id = card_id
      end

      attr_reader :trip_id, :card_id

      def call
        response = hold_payment
        if response['reasonCode'] == '1100'
          create_trip_payment(Constants::Payments::HOLD)
        end
        response
      end

      def hold_payment
        card = Repositories::Card.new(ROM.env).by_id(card_id)
        response = ::Wayforpay::Payments.hold(
          recToken: card.token,
          amount: trip.cost,
          currency: 'UAH',
          productName: ['Trip'],
          productPrice: [trip.cost],
          productCount: [1],
          orderDate: Time.now.to_i,
          orderReference: order_reference
        )
        JSON.parse(response.body)
      end

      def create_trip_payment(status)
        Repositories::Payment.new(ROM.env).create(
          status: status,
          amount: trip.cost,
          card_id: card_id,
          trip_id: trip_id,
          order_reference: order_reference
        )
      end

      def trip
        @trip ||= Repositories::Trip.new(ROM.env).by_id(trip_id)
      end

      def order_reference
        @order_reference ||= "trip_#{Rails.env}_#{trip_id}"
      end
    end
  end
end
