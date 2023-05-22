module Operations
  module Payments
    class Base
      private

      def payment_system
        determine_payment_method.to_s.camelcase
      end

      def determine_payment_method
        settings.fondy? ? :fondy : :wayforpay
      end

      def settings
        Settings.get
      end
    end
  end
end
