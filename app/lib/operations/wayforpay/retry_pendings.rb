module Operations
  module Wayforpay
    class RetryPendings
      def initialize(user_id, card_id)
        @user_id = user_id
        @card_id = card_id
      end

      attr_reader :user_id, :card_id

      def call
        return unless card&.user_id == user_id

        payments.each do |payment|
          settle = ::Wayforpay::Payments.settle(
            orderReference: payment.order_reference,
            merchantTransactionType: 'SALE',
            amount: payment.amount,
            currency: 'UAH',
            recToken: card.token
          )
          response = JSON.parse(settle.body)

          if response['reasonCode'] == Constants::Payments::WAYFORPAY_SUCCESS
            payment_repository.update(payment.id, status: Constants::Payments::SUCCESS)
          end
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
end
