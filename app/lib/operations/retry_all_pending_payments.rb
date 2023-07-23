module Operations
  class RetryAllPendingPayments
    def self.call
      new.call
    end

    def call
      Payment.pending.payments.find_each do |payment|
        begin
          card = payment.card || payment.user.cards.last
          if card
            Operations::Payments::RetryPayment.new(payment.id, card.id).call
          end
        end
      end
    end
  end
end
