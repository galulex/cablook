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
        status = if response['reasonCode'] == Constants::Payments::WAYFORPAY_SUCCESS
                   Constants::Payments::HOLD
                 else
                   send_sms
                   Constants::Payments::PENDING
                 end
        create_trip_payment(status, response)
        broadcast_status_to_trip_channel(status)
        response
      end

      private

      def broadcast_status_to_trip_channel(status)
        ActionCable.server.broadcast(
          "#{Constants::Channels::TRIP}_#{trip.id}",
          action: Constants::BroadcastActions::PAYMENT_RESPONSE,
          payment_status: status
        )
      end

      def create_trip_payment(status, wayforpay_data)
        @payment ||= Payment.create(
          status: status,
          amount: trip.cost,
          user_id: trip.user_id,
          card_id: card_id,
          trip_id: trip_id,
          order_reference: order_reference,
          response: wayforpay_data
        )
      end

      def hold_payment
        card = Card.find(card_id)
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

      def send_sms
        user = trip.user
        Jobs::Sms.perform_later(user.phone_number, I18n.t('sms.payment_failed'))
      end

      def trip
        @trip ||= Trip.find(trip_id)
      end

      def order_reference
        @order_reference ||= if Rails.env.production?
                               "cablook_trip_#{trip_id}"
                             else
                               "cablook_#{Rails.env}_trip_#{trip_id}"
                             end
      end
    end
  end
end
