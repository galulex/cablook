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
            return Operations::Wayforpay::RetryPayment.new(payment.id, card.id).call if settings.wayforpay?
            return Operations::Fondy::RetryPayment.new(payment.id, card.id).call if settings.fondy?
          end
        end
      end
    end

    private

    def settings
      @settings ||= Settings.get
    end
  end
end
