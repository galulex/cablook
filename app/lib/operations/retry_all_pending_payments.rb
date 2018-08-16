module Operations
  class RetryAllPendingPayments
    def self.call
      new.call
    end

    def call
      Payment.where(status: Constans::Payments::PENDING).find_each do |payment|
        begin
          card_id = payment.card_id || payment.user.cards.last.id
          Operations::Wayforpay::RetryPayment.new(payment.id, card_id).call
        end
      end
    end
  end
end
