module Events
  module Trips
    module Concerns
      module Fondy
        def order_reference(trip_id)
          secure_code = SecureRandom.base58(6)
          @order_reference ||= if Rails.env.production?
                                 "cablook_#{trip_id}_payments_trip_#{secure_code}"
                               else
                                 "cablook_#{Rails.env}_#{trip_id}_payments_trip_#{secure_code}"
                               end
        end
      end
    end
  end
end
