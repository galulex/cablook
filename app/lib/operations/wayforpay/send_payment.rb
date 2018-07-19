module Operations
    module Wayforpay
      class SendPayment
        def initialize(card, amount, productName, orderReference)
          @card = card
          @amount = amount
          @productName = productName
          @orderReference = orderReference
        end
  
        attr_reader :card, :amount, :productName, :orderReference
  
        def call
          hold = ::Wayforpay::Payments.hold( 
            recToken: card.token,
            amount: amount,
            currency: 'UAH',
            productName: [productName],
            productPrice: [amount.to_s],
            productCount: [1],
            orderDate: Time.now.to_i,
            merchantTransactionType: 'SALE',
            orderReference: orderReference,
            clientEmail: card.user.email,
            clientPhone: card.user.phone_number
          )
          JSON.parse(hold.body)
        end
      end
    end
  end