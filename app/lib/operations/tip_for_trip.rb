module Operations
  class TipForTrip
    def initialize(trip_id, amount)
      @trip_id = trip_id
      @amount = amount
    end

    attr_reader :trip_id, :amount

    def call
      status = if tip_response['reasonCode'] == Constants::Payments::WAYFORPAY_SUCCESS
                 Constants::Payments::SUCCESS
               else
                 Constants::Payments::PENDING
               end
      create_tip(status)
    end

    private

    def tip_response
      @tip_response ||= Operations::Wayforpay::SendPayment.new(card, amount, 'Trip', order_reference).call
    end

    def create_tip(status)
      Payments::Tip.create(
        trip_id: trip_id,
        user_id: trip.user_id,
        amount: amount,
        card_id: card.id,
        response: tip_response,
        order_reference: order_reference,
        status: status
      )
    end

    def card
      trip.trip_payment.card || Card.where(user: trip.user_id).last
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
