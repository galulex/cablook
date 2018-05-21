module Operations
  class TipForTrip
    def initialize(trip_id, amount)
      @trip_id = trip_id
      @amount = amount
    end

    attr_reader :trip_id, :amount

    def call
      create_tip
      send_payment
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

    def create_tip
      Repositories::Tip.new(ROM.env).create(
        trip_id: data[:trip_id],
        amount: data[:tip]
      )
    end

    def card
      @card ||= Repositories::Payment.new(ROM.env).card_token_by_trip(trip_id)
    end

    def trip
      @trip ||= Repositories::Trip.new(ROM.env).by_id(trip_id)
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
