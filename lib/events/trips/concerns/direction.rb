module Events
  module Trips
    module Concerns
      module Direction
        def direction
          @direction ||= directions_provider.new(
            data[:departure],
            data[:destination],
            data[:waypoints] || []
          )
        end

        def directions_provider
          data[:osrm].present? ? OsrmDirections : Directions
        end
      end
    end
  end
end
