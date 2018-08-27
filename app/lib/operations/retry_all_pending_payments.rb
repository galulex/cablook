module Operations
  class RetryAllPendingPayments
    def self.call
      new.call
    end

    def call
      Payment.where(status: Constants::Payments::PENDING).find_each do |payment|
        begin
          card = payment.card || payment.user.cards.last
          if card
            Operations::Wayforpay::RetryPayment.new(payment.id, card.id).call
          end
        end
      end
    end
  end
end
