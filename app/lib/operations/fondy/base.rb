module Operations
  module Fondy
    class Base

      private

      def settings
        @settings ||= Settings.get
      end

      def order_reference(trip_id, type)
        secure_code = SecureRandom.base58(6)
        @order_reference ||= if Rails.env.production?
                               "cablook_#{trip_id}_payments_#{type}_#{secure_code}"
                             else
                               "cablook_#{Rails.env}_#{trip_id}_payments_#{type}_#{secure_code}"
                             end
      end
    end
  end
end
