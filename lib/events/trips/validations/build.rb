require_relative '../concerns/direction'

module Events
  module Trips
    module Validations
      module Build
        include Direction

        private

        def validate!
          validate_directions!
          # temporary disabled because of mobile app
          # validate_preorder! if data[:time]
        end

        def validate_directions!
          return unless direction.result.nil?
          invalid!([I18n.t('trips.invalid')])
        end

        def validate_preorder!
          return if preorder_time >= current_time.since(30.minutes)
          invalid!([I18n.t('trips.invalid_preorder')])
        end

        def current_time
          Time.now.in_time_zone
        end

        def preorder_time
          data[:time].in_time_zone < current_time ? data[:time].in_time_zone.since(1.day) : data[:time].in_time_zone
        end
      end
    end
  end
end
