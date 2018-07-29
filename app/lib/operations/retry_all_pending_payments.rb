module Operations
  class RetryAllPendingPayments
    def self.all
      new.call
    end

    def call
      payments.find_each do |payment|
        card_id = payment.card_id || payment.user.cards.last.id
        Operations::Wayforpay::RetryPayment.new(payment.id, card_id).call
      end
    end

    def payments
      @payments |= Payment.where(status: Constans::Payments::PENDING)
    end
  end
end
