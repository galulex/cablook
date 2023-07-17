module Operations
  module Fondy
    class Base
      FONDY_FEE = 0.024

      private

      def settings
        @settings ||= Settings
      end

      def payout_amount
        @payout_amount ||= amount - (amount * FONDY_FEE)
      end

      def amount
        payment.amount || amount
      end
    end
  end
end
