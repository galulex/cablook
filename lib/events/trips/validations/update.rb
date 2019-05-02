require_relative '../concerns/validation'

module Events
  module Trips
    module Validations
      module Update
        include Validation

        private

        def validate!
          validate_distance!
          validate_bonus! if bonus?
        end

        def validate_bonus!
          return if bonus_trip && data[:distance] < Constants::Trip::MAX_BONUS_DISTANCE
          invalid!([I18n.t('bonus_trips.no_available_bonus')], status: 406)
        end
      end
    end
  end
end
