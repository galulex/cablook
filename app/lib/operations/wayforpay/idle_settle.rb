module Operations
    module Wayforpay
      class IdleSettle
        def initialize(trip_id, idle)
          @trip_id = trip_id
          @idle = idle
        end

        attr_reader :trip_id, :idle

        def call
          wayforpay_response = settle_payment_idle
          status = if wayforpay_response['reasonCode'] == Constants::Payments::WAYFORPAY_SUCCESS
                          Constants::Payments::SUCCESS
                        else
                          Constants::Payments::PENDING
                        end
          create_idle_payment(status, wayforpay_response)
        end

        private

        def settle_payment_idle
            order_reference = "#{payment.order_reference}_idle_#{SecureRandom.base58(6)}"
            hold = ::Wayforpay::Payments.hold(
            orderReference:  order_reference,
            amount: set_idle,
            currency: 'UAH',
            recToken: card.token,
            productName: ['Idle'],
            productPrice: [set_idle],
            productCount: [1],
            orderDate: Time.now.to_i,
            merchantTransactionType: 'SALE',
            clientEmail: card.user.email,
            clientPhone: card.user.phone_number
            )
            JSON.parse(hold.body)
        end

        def create_idle_payment(status, wayforpay_response)
          Payments::Idle.create(
            trip_id: trip_id,
            user_id: trip.user_id,
            amount: set_idle,
            response: wayforpay_response,
            status: status
          )
        end

        def set_idle
          return idle/60*Constants::Payments::IDLE_PRICE
        end

        def trip
          @trip ||= Trip.find(trip_id)
        end

        def card
          trip.trip_payment.card || Card.where(user: trip.user_id).last
        end

        def payment
          @payment ||= Payment.find_by(trip_id: trip_id)
        end
      end
    end
end
