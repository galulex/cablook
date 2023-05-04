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
      settings = Settings.get
      response = Operations::Payments::RetryPayment.new(payment_id, card_id).call
      settings.wayforpay? ? wayforpay_success?(response) : fondy_success?(response)
    end

    def wayforpay_success?(response)
      response['reasonCode'] == Constants::Payments::WAYFORPAY_SUCCESS
    end

    def fondy_success?(response)
      response[:response_status] == Constants::Payments::FONDY_SUCCESS
    end
  end
end
