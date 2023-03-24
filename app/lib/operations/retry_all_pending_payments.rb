module Operations
  class RetryAllPendingPayments
    def self.call
      new.call
    end

    def call
      Payment.where(status: Constants::Payments::PENDING).joins(:trip).where(trips: {status: Constants::Trip::STATUS_CODES[Constants::Trip::FINISHED]}).find_each do |payment|
        begin
          card = payment.card || payment.user.cards.last
          if card
            Operations::Fondy::DoPayment.new(payment.trip_id, payment.type, payment.amount).call
          end
        end
      end
    end
  end
end
