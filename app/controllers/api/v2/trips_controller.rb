module Api
  module V2
    class TripsController < ApiApplicationController
      before_action :authorize!

      def new
        trip = Events::Trips::Build.(trip_params)
        render json: Presenters::Trips::Single.new(trip).to_json, status: 200
      end

      private

      def trip_params
        params.require(:trip).permit(:departure_address, :destination_address, :comment, :departure, :time, :destination, departure: [], destination: [], waypoints: [], stops: [])
      end
    end
  end
end
