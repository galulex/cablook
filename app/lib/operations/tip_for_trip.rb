module Operations
  class TipForTrip
    def initialize(trip_id, amount)
      @trip_id = trip_id
      @amount = amount
    end

    attr_reader :trip_id, :amount

    def call
      response = send_payment
      create_tip(response: response)
    end

    private

    def send_payment
      hold = ::Wayforpay::Payments.hold(
        orderReference:  order_reference,
        amount: amount.to_s,
        currency: 'UAH',
        recToken: card.token,
        productName: ['Trip'],
        productPrice: [amount.to_s],
        productCount: [1],
        orderDate: Time.now.to_i,
        merchantTransactionType: 'SALE'
      )
      JSON.parse(hold.body)
    end

    def create_tip(response)
      Tip.create(
        trip_id: trip_id,
        amount: amount,
        response: response
      )
    end

    def card
      trip.payment.card || Card.where(user: trip.user_id).last
    end

    def trip
      @trip ||= Trip.find(trip_id)
    end

    def order_reference
      secure_code = SecureRandom.base58(6)
      @order_reference ||= if Rails.env.production?
                             "cablook_#{trip_id}_tip_#{secure_code}"
                           else
                             "cablook_#{Rails.env}_#{trip_id}_tip_#{secure_code}"
                           end
    end
  end
end
