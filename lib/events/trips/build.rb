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
          optional(:osrm)
          optional(:comment) { str? }
        end
      end

      def run
        validate_directions
        # temporary disabled because of mobile app
        #validate_preorder if data[:time]
        build_trip
        @trip
      end

      private

      def validate_directions
        return unless directions.result.nil?
        invalid!([I18n.t('trips.invalid')])
      end

      def validate_preorder
        return if preorder_time >= current_time.since(30.minutes)
        invalid!([I18n.t('trips.invalid_preorder')])
      end

      def build_trip
        @trip = Trip.new(data.except(:feedbacks, :driver_id, :car_id, :finished_at, :created_at, :start_at, :started_at))
        FIELDS.each { |field| @trip[field] = directions.send(field) }
        # TODO, remove it after we migrate to OSRM completely
        if data[:osrm].blank?
          @trip.departure = directions.departure
          @trip.destination = directions.destination
          @trip.waypoints = directions.waypoints
        end
        @trip.cost = Operations::V2TripCalculation.new(@trip).cost
      end

      def directions
        @directions ||= directions_provider.new(data[:departure], data[:destination], data[:waypoints] || [])
      end

      def directions_provider
        data[:osrm].present? ? OsrmDirections : Directions
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
