module Events
  module Trips
    class Build < BaseEvent
      FIELDS = %i[duration distance departure destination path waypoints].freeze

      def schema
        Dry::Validation.Schema do
          configure { config.messages = :i18n }

          required(:departure).filled
          required(:destination).filled
          required(:departure_address).filled(:str?)
          required(:destination_address).filled(:str?)
          optional(:waypoints) { none? | array? }
          optional(:stops) { none? | array? }

          optional(:start_at) { str? }
          optional(:comment) { str? }
        end
      end

      def run
        validate_start_at
        validate_directions
        build_trip
        @trip
      end

      private

      def validate_directions
        return unless directions.result.nil?
        invalid!([I18n.t('trips.invalid')])
      end

      def validate_start_at
        return if data[:start_at] == 'undefined' || Time.now < data[:start_at].to_time
        invalid!([I18n.t('trips.start_at_invalid')])
      end

      def build_trip
        @trip = Trip.new(data)
        FIELDS.each { |field| @trip[field] = directions.send(field) }
        @trip.cost = Operations::V2TripCalculation.new(@trip).cost
      end

      def directions
        @directions ||= Directions.new(data[:departure], data[:destination], data[:waypoints] || [])
      end
    end
  end
end
