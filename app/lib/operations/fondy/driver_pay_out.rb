module Operations
  module Fondy
    class DriverPayOut < Base
      def initialize(driver, amount)
        @driver = driver
        @amount = amount
      end

      def call
        return false unless validate_balance_result
        payout_driver
      end

      private
      attr_reader :driver, :amount

      def payout_driver
        update_driver_balance if payout_response[:status]
        Payment.create!(
          type: Constants::Payments::PAYOUT,
          response: payout_response,
          status: pay_out_status,
          amount: payout_amount,
          order_reference: payout_response[:order_id]
        )
      end

      def pay_out_status
        payout_response[:status] ? Constants::Payments::SUCCESS : Constants::Payments::PENDING
      end

      def payout_response
        @payout_response ||= ::Fondy::ChargeCard.new(driver, payout_amount).call
      end

      def update_driver_balance
        driver.update!(balance: balance_result)
      end

      def validate_balance_result
        balance_result.positive? || balance_result.zero?
      end

      def balance_result
        driver.balance - amount
      end
    end
  end
end
