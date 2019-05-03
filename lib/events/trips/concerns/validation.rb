module Events
  module Trips
    module Concerns
      module Validation
        private

        def validate_distance!
          return if data[:distance] < Constants::Trip::MAX_DISTANCE
          invalid!([I18n.t('trips.to_far')])
        end
      end
    end
  end
end
