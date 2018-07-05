module Operations
    module Wayforpay
      class IddleSettle
        def initialize(trip_id, idle)
          @trip_id = trip_id
          @idle = idle
        end
  
        attr_reader :trip_id, :idle

        def call
          if trip.nil? || trip.status == Constants::Trip::FINISHED
            wayforpay_response = JSON.parse(settle_payment_idle.body)
          payment.status = if wayforpay_response['reasonCode'] == Constants::Payments::WAYFORPAY_SUCCESS
                          Constants::Payments::SUCCESS
                        else
                          Constants::Payments::PENDING
                        end
        end
  
        private
  
        def settle_payment_idle
            #order_reference = "#{payment.order_reference}_retry_#{SecureRandom.base58(6)}"
            order_reference = "#{payment.order_reference}_idle_#{SecureRandom.base58(6)}"
            hold = ::Wayforpay::Payments.hold(
            orderReference:  order_reference,
            amount: idle*2,
            currency: 'UAH',
            recToken: card.token,
            productName: ['Idle'],
            productPrice: [idle*2],
            productCount: [1],
            orderDate: Time.now.to_i,
            merchantTransactionType: 'SALE',
            clientEmail: card.user.email,
            clientPhone: card.user.phone_number
            )
            JSON.parse(hold.body)
        end

        def trip
          @trip ||= Trip.find(trip_id)
        end

        def card
          @card || = Card.find(trip.payments[0].card_id)
        end

        def payment 
          @payment ||= Payments::Trip.find_by(trip_id: trip_id)
        end
      end
    end
  end
  