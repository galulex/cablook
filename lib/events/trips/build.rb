module Events
  module Trips
    class Build < BaseEvent
      FIELDS = %i[duration distance path].freeze

      def schema
        Dry::Validation.Schema do
          configure { config.messages = :i18n }

          required(:departure).filled
          required(:destination).filled
          required(:departure_address).filled(:str?)
          required(:destination_address).filled(:str?)
          optional(:waypoints) { none? | array? }
          optional(:stops) { none? | array? }
          optional(:osrm) { none? | str? }
          optional(:comment) { str? }
        end
      end

      def run
        validate_directions
        build_trip
        @trip
      end

      private

      def validate_directions
        return unless directions.result.nil?
        invalid!([I18n.t('trips.invalid')])
      end

      def build_trip
        @trip = Trip.new(data)
        FIELDS.each { |field| @trip[field] = directions.send(field) }
        @trip.cost = Operations::V2TripCalculation.new(@trip).cost
      end

      def directions
        @directions ||= directions_provider.new(data[:departure], data[:destination], data[:waypoints] || [])
      end

      def directions_provider
        data[:osrm].present? ? OsrmDirections : Directions
      end
    end
  end
end
