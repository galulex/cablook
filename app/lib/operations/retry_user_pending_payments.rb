module Operations
  class RetryUserPendingPayments
    def initialize(user_id, card_id)
      @user_id = user_id
      @card_id = card_id
    end

    attr_reader :user_id, :card_id

    def call
      return unless card&.user_id == user_id

      payments.each do |payment|
        next if retry_payment(payment.id, card_id)

        user.cards.where.not(id: card_id).each do |card|
          break if retry_payment(payment.id, card.id)
        end
      end
    end

    private

    def user
      @user ||= User.find(user_id)
    end

    def card
      @card ||= Card.find(card_id)
    end

    def payments
      @payments ||= Payment.pending(user_id)
    end

    def retry_payment(payment_id, card_id)
      response = Operations::Wayforpay::RetryPayment.new(payment_id, card_id).call
      response['reasonCode'] == Constants::Payments::WAYFORPAY_SUCCESS
    end
  end
end
