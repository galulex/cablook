module Api
  module V2
    class TripsController < ApiApplicationController
      before_action :authorize!

      def new
        trip = Trip.prepare(trip_params)
        render json: Presenters::Trips::Single.new(trip).to_json, status: 200
      rescue
        render json: { errors: [I18n.t('trips.invalid')] }, status: :unprocessable_entity
      end

      private

      def trip_params
        params.require(:trip).permit(:departure_address, :destination_address, :comment, :departure, :destination, waypoints: [], stops: [])
      end
    end
  end
end
