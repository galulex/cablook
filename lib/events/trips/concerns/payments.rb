module Events
  module Trips
    module Concerns
      module Payments
        def order_reference
          secure_code = SecureRandom.base58(6)
          @order_reference ||= if Rails.env.production?
                                 "cablook_#{@trip.id}_payments_trip_#{secure_code}"
                               else
                                 "cablook_#{Rails.env}_#{@trip.id}_payments_trip_#{secure_code}"
                               end
        end
      end
    end
  end
end
