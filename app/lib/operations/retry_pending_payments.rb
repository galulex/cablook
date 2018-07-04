module Operations
  class RetryPendingPayments
    def initialize(user_id, card_id)
      @user_id = user_id
      @card_id = card_id
    end

    attr_reader :user_id, :card_id

    def call
      return unless card&.user_id == user_id

      payments.each do |payment|
        Operations::Wayforpay::RetryPayment.new(payment.id, card_id).call
      end
    end

    private

    def card
      @card ||= Card.find(card_id)
    end

    def payments
      @payments ||= Payments::Trip.where(status: Constants::Payments::PENDING, user_id: user_id)
    end
  end
end
