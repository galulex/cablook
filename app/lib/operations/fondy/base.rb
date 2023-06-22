module Operations
  module Fondy
    class Base
      FONDY_FEE = 0.024

      private

      def settings
        @settings ||= Settings
      end

      def payout_amount
        @payout_amount ||= payment.amount - (payment.amount * FONDY_FEE)
      end
    end
  end
end
