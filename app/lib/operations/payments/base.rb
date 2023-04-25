module Operations
  module Payments
    class Base
      private

      def payment_system
        Settings.get.payment_system.humanize
      end
    end
  end
end
