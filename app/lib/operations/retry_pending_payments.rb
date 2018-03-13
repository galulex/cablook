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
      @card ||= Repositories::Card.new(ROM.env).by_id(card_id)
    end

    def payments
      @payments ||= payment_repository.pending_by_user(user_id)
    end

    def payment_repository
      @payment_repository ||= Repositories::Payment.new(ROM.env)
    end
  end
end
