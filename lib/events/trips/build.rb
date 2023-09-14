module Events
  module Trips
    class Build < BaseEvent
      include Concerns::Direction
      include Validations::Build

      FIELDS = %i[duration distance path].freeze
      OSRM_FIELDS = %i[departure destination waypoints].freeze

      def schema
        Dry::Schema.Params do
          # configure { config.messages = :i18n }

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
        validate!
        assign_attrs
        trip
      end

      private

      def assign_attrs
        trip.assign_attributes(trip_params)
        assign_fields
        assign_osrm_fields if data[:osrm].blank? # TODO, remove it after we migrate to OSRM completely
        trip.cost = Operations::V2TripCalculation.new(trip).cost
      end

      def assign_fields
        FIELDS.each { |field| trip[field] = direction.send(field) }
      end

      def assign_osrm_fields
        OSRM_FIELDS.each { |field| trip[field] = direction.send(field) }
      end

      def trip
        @trip ||= trip_params[:id].present? ? Trip.find(trip_params.delete(:id)) : Trip.new
      end

      def trip_params
        @trip_params ||= data.slice(:id, :path, :cost, :departure, :destination,
                                    :departure_address, :destination_address,
                                    :duration, :distance, :stops, :waypoints,
                                    :comment, :user_id, :no_call, :pre_order,
                                    :vip, :osrm, :time, :entrance)
      end
    end
  end
end
